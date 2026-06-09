import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percobaan/core/constants/app_constants.dart';
import 'package:percobaan/data/models/position_data.dart';
import 'package:percobaan/data/services/daily_log_service.dart';
import 'package:percobaan/data/services/lyrics_service.dart';
import 'package:percobaan/data/services/youtube_audio_service.dart';
import 'package:percobaan/core/network/yt_stream.dart';

class AudioViewModel with ChangeNotifier {
  // ── Services ──────────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  final YoutubeAudioService _ytService = YoutubeAudioService();
  final DailyLogService _dailyLogService = DailyLogService();
  final LyricsService _lyricsService = LyricsService();

  // ── State ─────────────────────────────────────────────────
  List<SongModel> _playlist = [];
  SongModel? _currentSong;
  MediaItem? _currentYtItem;
  bool _isPlaying = false;
  bool _isPlayerExpanded = false;
  bool _isYtLoading = false;
  String? _loadingVideoId;
  int _currentTabIndex = 0;

  // Playback tracking
  Timer? _playbackTimer;
  int _purePlaybackSeconds = 0;
  bool _isTrueOneRound = false;

  late final Stream<PositionData> _positionDataStream;
  bool _isListenerAttached = false;

  // ── Getters ───────────────────────────────────────────────
  AudioPlayer get player => _player;
  List<SongModel> get playlist => _playlist;
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPlayerExpanded => _isPlayerExpanded;
  bool get isYtLoading => _isYtLoading;
  String? get loadingVideoId => _loadingVideoId;
  bool get isTrueOneRound => _isTrueOneRound;
  int get purePlaybackSeconds => _purePlaybackSeconds;
  int get currentTabIndex => _currentTabIndex;

  bool get hasActiveTrack => _currentSong != null || _currentYtItem != null;
  String get displayTitle =>
      _currentSong?.title ?? _currentYtItem?.title ?? '';
  String get displayArtist =>
      _currentSong?.artist ?? _currentYtItem?.artist ?? '';
  Uri? get displayArtUri => _currentYtItem?.artUri;

  Stream<PositionData> get positionDataStream => _positionDataStream;

  PositionData get currentPositionData => PositionData(
    _player.position,
    _player.bufferedPosition,
    _player.duration ?? Duration.zero,
  );

  // ── Constructor ───────────────────────────────────────────
  AudioViewModel() {
    _initPositionStream();
  }

  // ── Init ──────────────────────────────────────────────────
  void _initPositionStream() {
    _positionDataStream = Rx.combineLatest4<Duration, Duration, Duration?,
        PlayerState, PositionData>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
      _player.playerStateStream,
      (position, bufferedPosition, duration, playerState) {
        if (!playerState.playing) {
          return PositionData(
            _player.position,
            bufferedPosition,
            duration ?? Duration.zero,
          );
        }
        return PositionData(position, bufferedPosition, duration ?? Duration.zero);
      },
    ).asBroadcastStream();

    _positionDataStream.listen((event) {
      FlutterOverlayWindow.shareData(event.position.inMilliseconds);
    });
  }

  void _attachListeners() {
    if (_isListenerAttached) return;
    _isListenerAttached = true;

    _player.currentIndexStream.listen((index) {
      if (index != null && _playlist.isNotEmpty && index < _playlist.length) {
        final newSong = _playlist[index];
        if (_currentSong?.id != newSong.id) {
          _currentSong = newSong;
          resetPlaybackTimer();
          if (_player.playing) _startPlaybackTimer();
        }
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;

      if (_isPlaying &&
          playerState.processingState != ProcessingState.completed) {
        _startPlaybackTimer();
      } else {
        _stopPlaybackTimer();
      }

      if (playerState.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }

      notifyListeners();
    });

    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState.currentSource == null) return;
      final item = sequenceState.currentSource!.tag as MediaItem;
      _fetchAndSendLyrics(item.artist ?? 'Unknown', item.title);
    });
  }

  // ── Public Actions ─────────────────────────────────────────
  void updateTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void togglePlayerExpanded() {
    _isPlayerExpanded = !_isPlayerExpanded;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying ? _player.pause() : _player.play();
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void seek(Duration position) => _player.seek(position);

  Future<void> playPlaylist(List<SongModel> songs, int index) async {
    resetPlaybackTimer();
    _currentYtItem = null;
    _playlist = songs;
    _currentSong = songs[index];
    _isPlayerExpanded = true;
    notifyListeners();

    _attachListeners();

    try {
      final playlistSource = ConcatenatingAudioSource(
        children: songs.map((s) => _buildAudioSource(s)).toList(),
      );

      await _player.setAudioSource(playlistSource, initialIndex: index);
      _player.play();
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  Future<void> playYoutubeSong({
    required String videoId,
    required String title,
    required String artist,
    required String thumbnailUrl,
  }) async {
    if (_isYtLoading) return;

    _isYtLoading = true;
    _loadingVideoId = videoId;
    notifyListeners();

    try {
      final streamSource = await _ytService.createStreamSource(
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnailUrl: thumbnailUrl,
      );

      if (streamSource == null) throw Exception('Gagal buat stream source');

      _currentSong = null;
      _currentYtItem = MediaItem(
        id: videoId,
        title: title,
        artist: artist,
        artUri: Uri.parse(thumbnailUrl),
      );
      _isPlayerExpanded = true;
      notifyListeners();

      await _player.setAudioSource(streamSource, preload: true);
      await _player.play();
    } on AudioLoadException catch (e) {
      debugPrint('Stream error: ${e.message}');
    } on TimeoutException {
      debugPrint('Timeout saat fetch manifest.');
    } catch (e) {
      debugPrint('Gagal memutar YouTube: $e');
    } finally {
      _isYtLoading = false;
      _loadingVideoId = null;
      notifyListeners();
    }
  }

  void prefetchYoutube(String videoId) => _ytService.prefetch(videoId);

  // ── Private Helpers ────────────────────────────────────────
  AudioSource _buildAudioSource(SongModel song) {
    String path = song.data;

    if (path.contains(AppConstants.ngrokPathPrefix)) {
      final startIdx = path.indexOf(AppConstants.ngrokPathPrefix);
      path = AppConstants.ngrokBaseUrl + path.substring(startIdx);
    }

    final uri = path.startsWith('http') ? Uri.parse(path) : Uri.file(path);
    final headers = path.startsWith('http')
        ? {
            'ngrok-skip-browser-warning': 'true',
            'User-Agent': 'MerakiApp/1.0',
          }
        : null;

    return AudioSource.uri(
      uri,
      headers: headers,
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        duration: Duration(milliseconds: song.duration ?? 0),
      ),
    );
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _purePlaybackSeconds++;

      if (_purePlaybackSeconds >= AppConstants.minPlaybackSecondsToLog &&
          !_isTrueOneRound) {
        _isTrueOneRound = true;
        if (_currentSong != null) {
          _dailyLogService.saveLog(_currentSong!);
        }
      }

      if (_player.position.inSeconds < 2 && _isTrueOneRound) {
        _isTrueOneRound = false;
        _purePlaybackSeconds = 0;
      }

      notifyListeners();
    });
  }

  void _stopPlaybackTimer() => _playbackTimer?.cancel();

  void resetPlaybackTimer() {
    _playbackTimer?.cancel();
    _purePlaybackSeconds = 0;
    _isTrueOneRound = false;
  }

  Future<void> _fetchAndSendLyrics(String artist, String title) async {
    final overlayData = await _lyricsService.getLyricsForOverlay(
      artist: artist,
      title: title,
    );
    await FlutterOverlayWindow.shareData(overlayData);
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _player.dispose();
    _ytService.dispose();
    super.dispose();
  }
}