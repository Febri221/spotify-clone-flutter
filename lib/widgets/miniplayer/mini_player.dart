import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:percobaan/screens/nowplaying_screens/now_playing_page.dart';
//Providers
import 'package:provider/provider.dart';
import 'package:percobaan/providers/audio_provider.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic: Dengerin status Player Expanded (Aktif/Gak)
    final audioProvider = context.read<AudioProvider>();

    return Selector<AudioProvider, SongModel?>(
      selector: (_, provider) => provider.currentSong,

      builder: (context, currentSong, child) {
        if (currentSong == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: const Color(0xFF191414),
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),

                pageBuilder: (_, __, ___) => const NowPlayingPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.fastOutSlowIn;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
          child: Selector<AudioProvider, int>(
            selector: (_, provider) => provider.currentTabIndex,

            builder: (context, currentTabIndex, child) {
              

              final bool isLibraryTab = currentTabIndex == 2;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
       
                height: 72, // Tambah 2 pixel buat tempat garis
                width: double.infinity,
                clipBehavior: Clip.antiAlias,

                margin: EdgeInsets.only(
                  left:  8,
                  right: 8,
                  bottom: 8,
                ),

                decoration: BoxDecoration(
                  color: Color(0xFF0DBDE6),
                  borderRadius: BorderRadius.circular(8),
                ),

                
                // === DI SINI PERUBAHANNYA: KITA PAKE COLUMN ===
                child: Column(
                  children: [
                    
                    // --- BAGIAN 1: KONTEN UTAMA (FOTO, JUDUL, TOMBOL) ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // === JUDUL & ARTIS ===
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Judul (Marquee)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final textStyle = const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      );
                                      final textPainter = TextPainter(
                                        text: TextSpan(
                                          text: currentSong.title,
                                          style: textStyle,
                                        ),
                                        maxLines: 1,
                                        textDirection: TextDirection.ltr,
                                      )..layout(minWidth: 0, maxWidth: double.infinity);

                                      if (textPainter.size.width >
                                          constraints.maxWidth) {
                                        return SizedBox(
                                          height: 20,
                                          child: Marquee(
                                            text: currentSong.title,
                                            style: textStyle,
                                            scrollAxis: Axis.horizontal,
                                            blankSpace: 50.0,
                                            velocity: 30.0,
                                            pauseAfterRound: const Duration(seconds: 2),
                                            startPadding: 0.0,
                                            accelerationDuration: Duration.zero,
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          height: 20,
                                          width: double.infinity,
                                          child: Text(
                                            currentSong.title,
                                            style: textStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 2),
                                  // Artis
                                  Text(
                                    currentSong.artist ?? "Unknown",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // === TOMBOL CONTROLS (PREV - PLAY - NEXT) ===
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- TOMBOL PREVIOUS ---
                                StreamBuilder<SequenceState?>(
                                  stream: audioProvider.player.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    final sequenceState = snapshot.data;
                                    final bool canGoBack =
                                        (sequenceState?.currentIndex ?? 0) > 0;

                                    return IconButton(
                                      onPressed: canGoBack
                                          ? () {
                                              audioProvider.player.seekToPrevious();
                                              audioProvider.player.play();
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: canGoBack ? Colors.white : Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),

                                // --- TOMBOL PLAY/PAUSE ---
                                Selector<AudioProvider, bool>(
                                  selector: (_, provider) => provider.isPlaying,
                                  builder: (context, isPlaying, child) {
                                    return IconButton(
                                      onPressed: () {
                                        audioProvider.togglePlay();
                                      },
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),

                                // --- TOMBOL NEXT ---
                                StreamBuilder<SequenceState?>(
                                  stream: audioProvider.player.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    final sequenceState = snapshot.data;
                                    final bool canGoNext =
                                        (sequenceState?.currentIndex ?? 0) <
                                        ((sequenceState?.sequence.length ?? 0) - 1);

                                    return IconButton(
                                      onPressed: canGoNext
                                          ? () {
                                              audioProvider.player.seekToNext();
                                              audioProvider.player.play();
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: canGoNext ? Colors.white : Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BAGIAN 2: GARIS PROGRESS TIPIS DI BAWAH ---
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: StreamBuilder<Duration>(
                        stream: audioProvider.player.positionStream,
                        builder: (context, snapshotPosition) {
                          final position = snapshotPosition.data ?? Duration.zero;
                      
                          return StreamBuilder<Duration?>(
                            stream: audioProvider.player.durationStream,
                            builder: (context, snapshotDuration) {
                              final duration = snapshotDuration.data ?? const Duration(seconds: 1);
                      
                              double progress = 0.0;
                              // Cegah error pembagian dengan nol atau durasi kosong
                              if (duration.inMilliseconds > 0) {
                                progress = position.inMilliseconds / duration.inMilliseconds;
                              }
                              if (progress > 1.0) progress = 1.0;
                              if (progress < 0.0 || progress.isNaN) progress = 0.0;
                      
                              return LinearProgressIndicator(
                                value: progress,
                                minHeight: 2, // Garisnya setipis 2 piksel
                                backgroundColor: Colors.transparent, // Background tembus pandang
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0071BA)), // Garis nyalanya warna teal
                              );
                            },
                          );
                        },
                      ),
                    ),

                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}