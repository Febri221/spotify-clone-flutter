import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';
import 'package:percobaan/models/rekap_model.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// // Tambah import di atas file
import 'package:percobaan/services/yt_stream.dart';

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
  Timer? _playbackTimer;
  int _purePlaybackSeconds = 0;
  bool _isTrueOneRound = false;

  final YoutubeExplode _yt = YoutubeExplode();

  AudioPlayer get player => _player;
  List<SongModel> get playlist => _playlist;
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPlayerExpanded => _isPlayerExpanded;
  bool get isTrueOneRound => _isTrueOneRound;
  int get purePlaybackSeconds => _purePlaybackSeconds;

  Stream<PositionData> get positionDataStream => _positionDataStream;
  late Stream<PositionData> _positionDataStream;

  late ConcatenatingAudioSource _playlistSource;


  MediaItem? _currentYtItem;

// 2. Getter universal untuk miniplayer
bool get hasActiveTrack => _currentSong != null || _currentYtItem != null;
String get displayTitle => _currentSong?.title ?? _currentYtItem?.title ?? '';
String get displayArtist => _currentSong?.artist ?? _currentYtItem?.artist ?? '';
Uri? get displayArtUri => _currentYtItem?.artUri;

  PositionData get currentPositionData => PositionData(
    player.position,
    player.bufferedPosition,
    player.duration ?? Duration.zero,
  );

  bool _isSetup = false;
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  AudioProvider() {
    _initSmartStream();
  }

  void updateTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
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
        final newSong = _playlist[index];

        if (_currentSong == null || _currentSong!.id != newSong.id) {
          _currentSong = newSong;
          resetPlaybackTimer(); 

          if (_player.playing) {
            startPlaybackTimer();
          }
        }
        notifyListeners();
      }
    });

    // =======================================================
    // 🔥 UPGRADE: LOGIKA SINKRONISASI MUTLAK STATE TIMER 🔥
    // =======================================================
    _player.playerStateStream.listen((playerState) {
      final isPlayingNow = playerState.playing;
      final processingState = playerState.processingState;

      // Samakan status lokal dengan mesin audio native secara mutlak
      _isPlaying = isPlayingNow;

      // Jika lagu sedang dimainkan DAN belum berstatus tamat (completed)
      if (_isPlaying && processingState != ProcessingState.completed) {
        startPlaybackTimer(); // Jalankan/pastikan timer hidup (otomatis handle cancel timer lama)
      } else {
        stopPlaybackTimer();  // Matikan timer jika di-pause atau buffering/completed
      }

      if (processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }

    

      notifyListeners();
    });

    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState.currentSource == null) return;
      final item = sequenceState.currentSource!.tag as MediaItem;
      _fetchAndSendLyrics(item.artist ?? "unkown", item.title);
    });
  }


Future<void>_playFirstSong(String title, String startVideoId, String artist, String thumbnailUrl) async{
  try {
    _playlistSource = ConcatenatingAudioSource(children: []);
    
  } catch (e) {
    print('Gagal memutar YouTube: $e');
  }

}

Future<YtStreamSource?> _createYtAudioSource(String videoId, String title, String artist, String thumbnailUrl) async {
  try {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId, ytClients: [
      YoutubeApiClient.androidVr,
      YoutubeApiClient.ios,
      YoutubeApiClient.android,
    ]); 
    final audioStreams = manifest.audioOnly.toList();
    final selectedStream = audioStreams.first;

    final mediaItem = MediaItem(id: videoId, title: title, artist: artist, artUri: Uri.parse(thumbnailUrl));
    return YtStreamSource(
      selectedStream, tag: mediaItem
    );
  } catch (e) {
    print('Gagal buat YtStreamSource: $e');
    return null;
  }
}


Future<void> playYoutubeSong(
  String videoId,
  String title,
  String artist,
  String thumbnailUrl,
) async {
  print('Streaming YouTube: $title...');
  try {
    _playlistSource = ConcatenatingAudioSource(children: []);

    final firstSong = await _createYtAudioSource(videoId, title, artist, thumbnailUrl);
    if (firstSong != null) {
      await _playlistSource.add(firstSong);
      await _player.setAudioSource(_playlistSource);
      await _player.play();
    }

  _currentYtItem = firstSong?.tag as MediaItem;
  _isPlayerExpanded = true;
  notifyListeners();

  _fetchRelatedSong(videoId);

   } catch (e) {
    print('Gagal memutar YouTube: $e');
  }
}

// 3. FUNGSI INTEL: Jalan di background buat nyari lagu Next
  Future<void> _fetchRelatedSong(String currentVideoId) async {
    try {
      print("Intel lagi nyari lagu rekomendasi...");
      
  
      var fullVideo = await _yt.videos.get(currentVideoId);

      var relatedVideos = await _yt.videos.getRelatedVideos(fullVideo);
      
      if (relatedVideos != null && relatedVideos.isNotEmpty) {
        var nextVideo = relatedVideos.first; // Ambil lagu pertama dari rekomendasi
        String nextThumb = "https://i.ytimg.com/vi/${nextVideo.id.value}/hqdefault.jpg";

        // Suruh Koki masakin lagu rekomendasi ini
        final laguKedua = await _createYtAudioSource(
          nextVideo.id.value, 
          nextVideo.title, 
          nextVideo.author, 
          nextThumb
        );

        if (laguKedua != null) {
          // 🔥 TAMBAHIN KE MEJA PRASMANAN YANG LAGI JALAN!
          await _playlistSource.add(laguKedua);
          print("Sah! Lagu ${nextVideo.title} masuk ke antrean Next!");
          // Tombol Next di MiniPlayer lu otomatis bakal NYALA!
        }
      }
    } catch (e) {
      print("Intel gagal nyari lagu: $e");
    }
  }

  void startPlaybackTimer() {
    // Amankan dari dobel instansi timer
    _playbackTimer?.cancel();

    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _purePlaybackSeconds++;
      print("🔥 DETIK MESIN JALAN: $_purePlaybackSeconds");

      // Menggunakan 10 detik buat testing
      if (_purePlaybackSeconds >= 60 && !_isTrueOneRound) {
        _isTrueOneRound = true;
        if (_currentSong != null) {
          _saveDailyLogDatabase(_currentSong!);
          print("🔥 SAH! Lagu ${_currentSong!.title} masuk ke Kardus Harian!");
        }
      }
      
      // Logika deteksi loop kesukaan lu tetep aman di sini
      if (player.position.inSeconds < 2 && _isTrueOneRound) {
        print("🔄 Lagu Ngulang! Reset gembok & timer buat putaran berikutnya...");
        _isTrueOneRound = false;
        _purePlaybackSeconds = 0; 
      }
      notifyListeners();
    });
  }

  void _saveDailyLogDatabase(SongModel song) {
    final box = Hive.box<DailyLog>('daily_logs');
    final logBaru = DailyLog(
      songId: song.id.toString(),
      title: song.title,
      artist: song.artist ?? "Unknown Artist",
      playDate: DateTime.now(),
    );
    box.add(logBaru);
    print("💾 Berhasil diconvert! Bersiap menyimpan ${logBaru.title} ke database.");
  }

  void stopPlaybackTimer() {
    _playbackTimer?.cancel();
  }

  void resetPlaybackTimer() {
    _playbackTimer?.cancel();
    _purePlaybackSeconds = 0;
    _isTrueOneRound = false;
  }

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
        children: songs.map((s) {
          String pathAtauUrl = s.data;
          String pathAuthUrlMatang = pathAtauUrl;

          if (pathAtauUrl.contains('/lagu/')) {
            int startIdx = pathAtauUrl.indexOf('/lagu/');
            String sisaUrl = pathAtauUrl.substring(startIdx);
            pathAuthUrlMatang =
                'https://jann-undeclaiming-unrhythmically.ngrok-free.dev$sisaUrl';
          }

          final Uri audioUri = pathAuthUrlMatang.startsWith('http')
              ? Uri.parse(pathAuthUrlMatang)
              : Uri.file(pathAuthUrlMatang);

          final Map<String, String>? myHeaders =
              pathAuthUrlMatang.startsWith('http')
              ? {
                  "ngrok-skip-browser-warning": "true",
                  "User-Agent": "MerakiApp/1.0",
                }
              : null;

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
