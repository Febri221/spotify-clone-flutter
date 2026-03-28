// import 'package:flutter/foundation.dart';
// import 'package:flutter_overlay_window/flutter_overlay_window.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';
// import 'package:on_audio_query/on_audio_query.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;
//   PositionData(this.position, this.bufferedPosition, this.duration);
// }

// class AudioManager {
//   static final AudioManager _instance = AudioManager._internal();
//   factory AudioManager() => _instance;

//   final AudioPlayer player = AudioPlayer();
//   static const int lyricsOffset = 0;

//   // --- RYAN HEISE STYLE: PURE STREAM ---
//   // Hapus BehaviorSubject. Stream ini adalah 'Kebenaran Tunggal'
//   Stream<PositionData> get positionDataStream => _positionDataStream;
//   late Stream<PositionData> _positionDataStream;

//   // Getter Helper untuk UI (Initial Data)
//   PositionData get currentPositionData => PositionData(
//         player.position,
//         player.bufferedPosition,
//         player.duration ?? Duration.zero,
//       );

//   final ValueNotifier<SongModel?> currentSongNotifier = ValueNotifier(null);
//   final ValueNotifier<bool> isPlayerExpanded = ValueNotifier(false);
//   final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

//   List<SongModel> _currentPlaylist = [];
//   List<SongModel> get currentPlaylist => _currentPlaylist;
//   bool _listenersAttached = false;

//   AudioManager._internal() {
//     _initSmartStream();
//   }

//   void _initSmartStream() {
//     // Sync player position & state
//     _positionDataStream = Rx.combineLatest4<Duration, Duration, Duration?, PlayerState, PositionData>(
//         player.positionStream,
//         player.bufferedPositionStream,
//         player.durationStream,
//         player.playerStateStream, // Kita butuh state Playing/Paused
//         (position, bufferedPosition, duration, playerState) {
          
//       // LOGIC: Kalo lagi PAUSE/STOP, jangan percaya stream posisi (karena delay).
//       // Ambil langsung dari Hardware (player.position).
//       if (!playerState.playing) {
//         return PositionData(
//           player.position, 
//           bufferedPosition,
//           duration ?? Duration.zero,
//         );
//       }
      
//       // Kalo lagi PLAYING, aman pake stream biasa.
//       return PositionData(
//         position,
//         bufferedPosition,
//         duration ?? Duration.zero,
//       );
//     }).asBroadcastStream(); // Broadcast biar bisa didengar UI + Overlay barengan

//     // Listener Terpisah untuk Overlay (Side Effect)
//     _positionDataStream.listen((event) {
//       FlutterOverlayWindow.shareData(event.position.inMilliseconds + lyricsOffset);
//     });
//   }

//   Future<void> playPlaylist(List<SongModel> songs, int index) async {
//     _currentPlaylist = songs;
//     currentSongNotifier.value = songs[index];
//     isPlayerExpanded.value = true;

//     if (!_listenersAttached) {
//       _attachListeners();
//       _listenersAttached = true;
//     }

//     try {
//       final playlistSource = ConcatenatingAudioSource(
//         children: songs.map((s) {
//           return AudioSource.uri(
//             Uri.parse(s.uri!),
//             tag: MediaItem(
//               id: s.id.toString(),
//               album: s.album ?? 'Unknown Album',
//               title: s.title,
//               artist: s.artist ?? 'Unknown Artist',
//               duration: Duration(milliseconds: s.duration ?? 0),
//             ),
//           );
//         }).toList(),
//       );

//       await player.setAudioSource(playlistSource, initialIndex: index);
//       player.play();
//     } catch (e) {
//       debugPrint("AUDIO ERROR: $e");
//     }
//   }

//   void _attachListeners() {
//     player.currentIndexStream.listen((idx) {
//       if (idx != null &&
//           _currentPlaylist.isNotEmpty &&
//           idx < _currentPlaylist.length) {
//         currentSongNotifier.value = _currentPlaylist[idx];
//       }
//     });

//     player.playerStateStream.listen((playerState) {
//       final isPlaying = playerState.playing;
//       final processingState = playerState.processingState;

//       if (isPlayingNotifier.value != isPlaying) {
//         isPlayingNotifier.value = isPlaying;
//       }

//       if (processingState == ProcessingState.completed) {
//         isPlayingNotifier.value = false;
//         player.seek(Duration.zero);
//         player.pause();
//       }
//     });

//     _listenToSequenceState();
//   }

//   void _listenToSequenceState() {
//     player.sequenceStateStream.listen((sequenceState) async {
//       if (sequenceState?.currentSource == null) return;
//       final item = sequenceState!.currentSource!.tag as MediaItem;
//       final String currentTitle = item.title;
//       final String currentArtist = item.artist ?? 'Unknown Artist';

//       String rawLrc = await LyricsManager.getLyrics(currentArtist, currentTitle);

//       List<Map<String, dynamic>> overlayData = [];

//       if (rawLrc.isNotEmpty) {
//         overlayData = convertLrcToList(rawLrc);
//       } else {
//         overlayData = [
//           {'time': 0, 'text': 'Lirik belum tersedia'},
//           {'time': 5000, 'text': 'Silakan request yaa :)'}
//         ];
//       }
//       await FlutterOverlayWindow.shareData(overlayData);
//     });
//   }

//   List<Map<String, dynamic>> convertLrcToList(String lrcContent) {
//     List<Map<String, dynamic>> output = [];
//     final RegExp regex = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)');
//     final lines = lrcContent.split('\n');
//     for (var line in lines) {
//       final match = regex.firstMatch(line);
//       if (match != null) {
//         final int minutes = int.parse(match.group(1)!);
//         final int seconds = int.parse(match.group(2)!);
//         final int milliseconds = int.parse(match.group(3)!);
//         final String text = match.group(4)!.trim();
//         final int totalTime =
//             (minutes * 60 * 1000) + (seconds * 1000) + (milliseconds * 10);
//         output.add({'time': totalTime, 'text': text});
//       }
//     }
//     return output;
//   }

//   void pause() => player.pause();
//   void resume() => player.play();
//   void seek(Duration position) => player.seek(position);
// }