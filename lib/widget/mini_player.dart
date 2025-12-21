import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:percobaan/servicess/audio_manager.dart';
import 'package:percobaan/screens/now_playing_page.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic: Dengerin status Player Expanded (Aktif/Gak)
    return ValueListenableBuilder<bool>(
      valueListenable: AudioManager().isPlayerExpanded,
      builder: (context, isExpanded, child) {
        if (!isExpanded) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black.withOpacity(0.6),
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),

                pageBuilder: (_, __, ___) => NowPlayingPage(
                ),
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
          child: ValueListenableBuilder<SongModel?>(
            valueListenable: AudioManager().currentSongNotifier,
            builder: (context, currentSong, child) {
              if (currentSong == null) return const SizedBox(height: 70);
              return Container(
                height: 70,
                width: double.infinity,
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // === 2. JUDUL & ARTIS ===
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
                                    key: ValueKey(currentSong.id),
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
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // === 3. TOMBOL CONTROLS (PREV - PLAY - NEXT) ===
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- TOMBOL PREVIOUS ---
                        StreamBuilder<SequenceState?>(
                          stream: AudioManager().player.sequenceStateStream,
                          builder: (context, snapshot) {
                            final sequenceState = snapshot.data;
                            // Logic: Bisa mundur kalau index sekarang > 0
                            final bool canGoBack =
                                (sequenceState?.currentIndex ?? 0) > 0;

                            return IconButton(
                              onPressed: canGoBack
                                  ? () {
                                      AudioManager().player.seekToPrevious();
                                      AudioManager().player.play();
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
                        StreamBuilder<PlayerState>(
                          stream: AudioManager().player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing;

                            return IconButton(
                              onPressed: () {
                                if (playing == true) {
                                  AudioManager().pause();
                                } else {
                                  AudioManager().resume();
                                }
                              },
                              icon: Icon(
                                playing == true
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
                          stream: AudioManager().player.sequenceStateStream,
                          builder: (context, snapshot) {
                            final sequenceState = snapshot.data;
                            // Logic: Bisa maju kalau belum di lagu terakhir
                            final bool canGoNext =
                                (sequenceState?.currentIndex ?? 0) <
                                ((sequenceState?.sequence.length ?? 0) - 1);

                            return IconButton(
                              onPressed: canGoNext
                                  ? () {
                                      AudioManager().player.seekToNext();
                                      AudioManager().player.play();
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
              );
            },
          ),
        );
      },
    );
  }
}