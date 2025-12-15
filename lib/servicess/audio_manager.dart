import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';


class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer player = AudioPlayer();
static const int lyricsOffset = 0;
  final ValueNotifier<SongModel?> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isPlayerExpanded = ValueNotifier(false);

  // Durasi total dan posisi sekarang
  final ValueNotifier<Duration> totalDurationNotifier =
      ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> currentPositionNotifier =
      ValueNotifier(Duration.zero);

  List<SongModel> _currentPlaylist = [];

  List<SongModel> get currentPlaylist => _currentPlaylist;

  bool _listenersAttached = false;

  Future<void> playPlaylist(List<SongModel> songs, int index) async {
    _currentPlaylist = songs;
    currentSongNotifier.value = songs[index];

    // === TAMBAHAN PENTING ===
    // Ini saklar biar Mini Player muncul!
    isPlayerExpanded.value = true; 
    // ========================

    try {
      final playlistSource = ConcatenatingAudioSource(
        children: songs.map((s) {
          return AudioSource.uri(
            Uri.parse(s.uri!),
            tag: MediaItem(
              id: s.id.toString(),
              album: s.album ?? 'Unknown Album',
              title: s.title,
              artist: s.artist ?? 'Unknown Artist',
              duration: Duration(milliseconds: s.duration ?? 0),
            ),
          );
        }).toList(),
      );

      final duration = await player.setAudioSource(
        playlistSource,
        initialIndex: index,
      );

      totalDurationNotifier.value = duration ?? Duration.zero;

      if (!_listenersAttached) {
        _attachListeners();
        _listenersAttached = true;
      }

      player.play();
    } catch (e) {
      print("AUDIO ERROR: $e");
    }
  }

  void _attachListeners() {
    player.durationStream.listen((d) {
      if (d != null) {
        totalDurationNotifier.value = d;
      }
    });

    player.positionStream.listen((p) {
      currentPositionNotifier.value = p;
      FlutterOverlayWindow.shareData(p.inMilliseconds + lyricsOffset);
      
    });

    player.currentIndexStream.listen((idx) {
      if (idx != null && idx < _currentPlaylist.length) {
        currentSongNotifier.value = _currentPlaylist[idx];
      }
    });
  }

  void pause() => player.pause();
  void resume() => player.play();
  void seek(Duration position) => player.seek(position);
}