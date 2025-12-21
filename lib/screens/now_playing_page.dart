import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:percobaan/servicess/audio_manager.dart';
import 'package:percobaan/screens/player/seek_bar.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with WidgetsBindingObserver {
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- PERBAIKAN LOGIC RESUME ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Kita "Senggol" UI biar rebuild.
      // Karena kita pake 'initialData' di StreamBuilder bawah,
      // Rebuild ini akan memaksa UI ngambil data posisi TERBARU langsung dari Player.
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  // ... (Bagian _toggleFloatingLyrics dan logic UI lain gak perlu diubah) ...
  void _toggleFloatingLyrics() async {
      // ... (Code lu yang lama) ...
      // copy paste aja function toggle lyrics lu yang lama kesini
      try {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        final bool? result = await FlutterOverlayWindow.requestPermission();
        if (result != true) return;
      }
      final bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Lyrics closed"),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 1)),
          );
        }
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Lyrics",
          overlayContent: "Lyrics Overlay",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilitySecret,
          positionGravity: PositionGravity.none,
          height: 400,
          width: 550,
        );
      }
    } catch (e) {
      debugPrint("ERROR TOGGLE OVERLAY: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dismissible(
      key: const Key('play_screen_dismiss'),
      direction: DismissDirection.down,
      onDismissed: (direction) => Navigator.pop(context),
      background: const ColoredBox(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Song', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                Text('|', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                Text('Lyrics', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (Bagian Gambar Album / QueryArtworkWidget Code lu gak perlu diubah) ...
               Expanded(
                flex: 6,
                child: ValueListenableBuilder<SongModel?>(
                  valueListenable: _audioManager.currentSongNotifier,
                  builder: (context, currentSong, _) {
                    if (currentSong == null) return const SizedBox();
                    final displayTitle = currentSong.title.trim().isNotEmpty
                        ? currentSong.title
                        : currentSong.displayNameWOExt;

                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: screenWidth - 50,
                              height: screenWidth - 50,
                              child: QueryArtworkWidget(
                                id: currentSong.id,
                                type: ArtworkType.AUDIO,
                                artworkHeight: double.infinity,
                                artworkWidth: double.infinity,
                                artworkFit: BoxFit.fill,
                                nullArtworkWidget: Container(
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.music_note,
                                        size: 80, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: _toggleFloatingLyrics,
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.layers,
                                        color: Colors.tealAccent, size: 24),
                                  ),
                                ),
                              ]),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const textStyle = TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold);
                              final textPainter = TextPainter(
                                text: TextSpan(
                                    text: displayTitle, style: textStyle),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                                textScaler: MediaQuery.of(context).textScaler,
                              )..layout(minWidth: 0, maxWidth: double.infinity);
                              return SizedBox(
                                height: 30,
                                width: constraints.maxWidth,
                                child: textPainter.size.width >
                                        (constraints.maxWidth - 5)
                                    ? Marquee(
                                        text: displayTitle,
                                        style: textStyle,
                                        scrollAxis: Axis.horizontal,
                                        blankSpace: 50.0,
                                        velocity: 30.0,
                                        pauseAfterRound:
                                            const Duration(seconds: 2),
                                        startPadding: 10.0,
                                        accelerationDuration: Duration.zero,
                                        decelerationDuration:
                                            const Duration(milliseconds: 500))
                                    : Align(
                                        alignment: Alignment.center,
                                        child: Text(displayTitle,
                                            style: textStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            currentSong.artist == "<unknown>"
                                ? "Unknown Artist"
                                : (currentSong.artist ?? "Unknown Artist"),
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16)),
                      ],
                    );
                  },
                ),
              ),

              // --- BAGIAN SEEKBAR YANG PENTING ---
              StreamBuilder<PositionData>(
                stream: _audioManager.positionDataStream, // Pake stream gabungan baru
                initialData: _audioManager.currentPositionData, // PENTING: Data awal ambil dari Hardware
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: (newPosition) {
                      _audioManager.seek(newPosition);
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
              // ... (Sisa tombol control gak perlu diubah) ...
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<bool>(
                    stream: _audioManager.player.shuffleModeEnabledStream,
                    builder: (context, snapshot) {
                      final shuffleEnabled = snapshot.data ?? false;
                      return IconButton(
                        onPressed: () async {
                          final enable = !shuffleEnabled;
                          if (enable) await _audioManager.player.shuffle();
                          await _audioManager.player
                              .setShuffleModeEnabled(enable);
                        },
                        icon: Icon(Icons.shuffle,
                            color: shuffleEnabled ? Colors.white : Colors.grey,
                            size: 25),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => _audioManager.player.seekToPrevious(),
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white, size: 50),
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: _audioManager.isPlayingNotifier,
                      builder: (context, isPlaying, _) {
                        return Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                            onPressed: () => isPlaying
                                ? _audioManager.pause()
                                : _audioManager.resume(),
                            icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 40),
                          ),
                        );
                      }),
                  IconButton(
                    onPressed: () => _audioManager.player.seekToNext(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white, size: 50),
                  ),
                  StreamBuilder<LoopMode>(
                    stream: _audioManager.player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      IconData icon = (loopMode == LoopMode.one)
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded;
                      Color color = (loopMode == LoopMode.off)
                          ? Colors.grey
                          : Colors.white;
                      return IconButton(
                        onPressed: () async {
                          LoopMode newMode = LoopMode.off;
                          if (loopMode == LoopMode.off) {
                            newMode = LoopMode.all;
                          } else if (loopMode == LoopMode.all) {
                            newMode = LoopMode.one;
                          }
                          await _audioManager.player.setLoopMode(newMode);
                        },
                        icon: Icon(icon, color: color, size: 25),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}