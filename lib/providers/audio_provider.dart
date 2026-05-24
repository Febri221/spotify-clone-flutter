import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';
import 'dart:async';

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

  AudioPlayer get player => _player;
  List<SongModel> get playlist => _playlist;
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPlayerExpanded => _isPlayerExpanded;
  bool get isTrueOneRound => _isTrueOneRound;
  int get purePlaybackSeconds => _purePlaybackSeconds;
  

  Stream<PositionData> get positionDataStream => _positionDataStream;
  late Stream<PositionData> _positionDataStream;

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

        // LOGIKA PENYELAMAT: Cek dulu, apakah lagunya BENERAN ganti?
        // Biar timer gak dibunuh pas mesin cuma lagi loading lirik
        if (_currentSong == null || _currentSong!.id != newSong.id) {
          _currentSong = newSong;
          
          resetPlaybackTimer(); // Balikin ke 0 karena ini beneran lagu baru
          
          // NAPAS BUATAN: Kalau lagunya ganti secara otomatis (auto-next), 
          // status lagu kan masih 'Playing', jadi timernya WAJIB dinyalain lagi manual di sini!
          if (_player.playing) {
            startPlaybackTimer();
          }
        }
        
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((playerState) {
      final isPlayingNow = playerState.playing;
      final processingState = playerState.processingState;

      if (_isPlaying != isPlayingNow) {
        _isPlaying = isPlayingNow;

        if (_isPlaying) {
          startPlaybackTimer();
        } else {
          stopPlaybackTimer();
        }

        notifyListeners();
      }

      

      if (processingState == ProcessingState.completed) {
        _isPlaying = false;
        _player.seek(Duration.zero);
        _player.pause();
        stopPlaybackTimer();
        notifyListeners();
      }
    });

    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState.currentSource == null) return;

      final item = sequenceState.currentSource!.tag as MediaItem;

      _fetchAndSendLyrics(item.artist ?? "unkown", item.title);
    });
  }

  void startPlaybackTimer() {
    // TODO A: Keamanan. Pastikan timer yang lama dimatikan dulu (cancel) sebelum bikin baru, 
    // biar nggak ada kejadian "timer dobel" yang bikin hitungan jadi 2x lipat lebih cepet.
    _playbackTimer?.cancel();

    
    // Bikin stopwatch berdetak setiap 1 detik
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      // TODO B: Setiap 1 detik, tambahin variabel _purePlaybackSeconds dengan angka 1.
      _purePlaybackSeconds++;
      print("🔥 DETIK MESIN JALAN: $_purePlaybackSeconds");
      // TODO C: Bikin logika IF. Kalau _purePlaybackSeconds udah mencapai 60:
      // 1. Eksekusi fungsi simpan ke database (buat sekarang, print("1 Menit Tercatat!") aja dulu)
      // 2. Reset _purePlaybackSeconds balik ke 0 (biar dia ngitung menit ke-2).
      if (_purePlaybackSeconds >= 60 && !_isTrueOneRound) {
        _isTrueOneRound = true;
        print("1 Menit Tercatat!");
        
      }

      if (player.position.inSeconds < 2 && _isTrueOneRound) {
        _isTrueOneRound = false;
        _purePlaybackSeconds = 0;
        print("Putaran baru, status gembok di-reset!");
      }
      notifyListeners();
    });
  }

  void stopPlaybackTimer() {
    // TODO D: Matikan _playbackTimer (cancel). 
    // Catatan: JANGAN mereset _purePlaybackSeconds ke 0 di sini! 
    // Biarin angkanya menggantung (misal di 45 detik) biar pas di-play lagi, dia ngelanjutin.
    _playbackTimer?.cancel();
  }
  
  // === 4. FUNGSI RESET TOTAL (GANTI LAGU) ===
  void resetPlaybackTimer() {
    // TODO E: Matikan timer (cancel), DAN reset _purePlaybackSeconds jadi 0.
    // Ini dieksekusi HANYA kalau user ganti ke lagu lain.
    _playbackTimer?.cancel();
    _purePlaybackSeconds = 0;
    _isTrueOneRound = false;

  }

  Future<void> playPlaylist(List<SongModel> songs, int index) async {
    resetPlaybackTimer();
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

  void pause() {
    _player.pause();
  }
  void resume() {
    _player.play();
  }

  
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
