import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

class AudioProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _playlist = [];
  SongModel? _currentSong;
  bool _isPlaying = false;
  bool _isPlayerExpanded = false;

  AudioPlayer get player => _player;
  List<SongModel> get playlist => _playlist;
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPlayerExpanded => _isPlayerExpanded;

  Stream<PositionData> get positionDataStream => _positionDataStream;
  late Stream<PositionData> _positionDataStream;

  PositionData get currentPositionData => PositionData(
    player.position,
    player.bufferedPosition,
    player.duration ?? Duration.zero,
  );

  bool _isSetup = false;

  AudioProvider() {
    _initSmartStream();
  }

  void _initSmartStream() {
    _positionDataStream =
        Rx.combineLatest4<
              Duration,
              Duration,
              Duration?,
              PlayerState,
              PositionData
            >(
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
                return PositionData(
                  position,
                  bufferedPosition,
                  duration ?? Duration.zero,
                );
              },
            )
            .asBroadcastStream();

    _positionDataStream.listen((event) {
      FlutterOverlayWindow.shareData(event.position.inMilliseconds);
    });
  }

  void _attachListeners() {
    if (_isSetup) return;
    _isSetup = true;

    _player.currentIndexStream.listen((index) {
      if (index != null && _playlist.isNotEmpty && index < _playlist.length) {
        _currentSong = _playlist[index];
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((playerState) {
      final isPlayingNow = playerState.playing;
      final processingState = playerState.processingState;

      if (_isPlaying != isPlayingNow) {
        _isPlaying = isPlayingNow;
        notifyListeners();
      }

      if (processingState == ProcessingState.completed) {
        _isPlaying = false;
        _player.seek(Duration.zero);
        _player.pause();
        notifyListeners();
      }
    });

    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource == null) return;

      final item = sequenceState!.currentSource!.tag as MediaItem;

      _fetchAndSendLyrics(item.artist ?? "unkown", item.title);
    });
  }

  Future<void> playPlaylist(List<SongModel> songs, int index) async {
    _playlist = songs;
    _currentSong = songs[index];
    _isPlayerExpanded = true;
    notifyListeners();

    _attachListeners();

    try {
      final playlistSource = ConcatenatingAudioSource(
        children: songs.map((s) {
          String pathAtauUrl = s.data;
         // String pathAuthUrlMatang = pathAtauUrl;
            String pathAuthUrlMatang = pathAtauUrl;

            if (pathAtauUrl.contains('/lagu/')) {
    // Cari index posisi tulisan '/lagu/'
    int startIdx = pathAtauUrl.indexOf('/lagu/');
    
    // Ambil sisa tulisan di belakangnya (misal: '/lagu/lany_xxl.mp3')
    String sisaUrl = pathAtauUrl.substring(startIdx);
    
    // Gabungin paksa!
    pathAuthUrlMatang = 'https://jann-undeclaiming-unrhythmically.ngrok-free.dev$sisaUrl';
}
          
          
          print('DEBUG FINAL: URL Mateng =$pathAuthUrlMatang');
          
          // ONLINE / OFFLINE
          final Uri audioUri = pathAuthUrlMatang.startsWith('http')
              ? Uri.parse(pathAuthUrlMatang)
              : Uri.file(pathAuthUrlMatang);

          final Map<String, String>? myHeaders = pathAuthUrlMatang.startsWith('http')
          ? {
            "ngrok-skip-browser-warning": "true",
                  "User-Agent": "MerakiApp/1.0",
          } : null;

          return AudioSource.uri(
            audioUri,
            headers: myHeaders,
            tag: MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist ?? "Unknown Artist",
              album: s.album ?? "Unkown Album",
              artUri: null,
              duration: Duration(milliseconds: s.duration ?? 0),
            ),
          );
        }).toList(),
      );

      await _player.setAudioSource(playlistSource, initialIndex: index);
      _player.play();
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void seek(Duration position) => _player.seek(position);

  void togglePlayerExpanded() {
    _isPlayerExpanded = !_isPlayerExpanded;
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> _fetchAndSendLyrics(String artis, String title) async {
    String rawLrc = await LyricsManager.getLyrics(artis, title);
    List<Map<String, dynamic>> overlayData = [];

    if (rawLrc.isNotEmpty) {
      overlayData = LyricsManager.parseLrc(rawLrc);
    } else {
      overlayData = [
        {'time': 0, 'text': 'Lirik belum tersedia'},
        {'time': 5000, 'text': 'Request yee kalo mau :)'},
      ];
    }
    await FlutterOverlayWindow.shareData(overlayData);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
