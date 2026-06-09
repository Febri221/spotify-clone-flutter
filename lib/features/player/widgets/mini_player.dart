import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:percobaan/features/now_playing/view/now_playing_view.dart';
import 'package:percobaan/features/player/widgets/seek_bar_miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioViewModel>();

    // ✅ Selector baru: pantau hasActiveTrack (lokal ATAU YouTube)
    return Selector<AudioViewModel, bool>(
      selector: (_, p) => p.hasActiveTrack,
      builder: (context, hasTrack, _) {
        if (!hasTrack) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: const Color(0xFF191414),
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, __, ___) => const NowPlayingPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.fastOutSlowIn)).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Selector<AudioViewModel, int>(
            selector: (_, p) => p.currentTabIndex,
            builder: (context, _, __) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 78,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0DBDE6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // ── Seek Bar ────────────────────────────────────────────
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: StreamBuilder<Duration>(
                        stream: audioProvider.player.positionStream,
                        builder: (_, snapPos) {
                          return StreamBuilder<Duration?>(
                            stream: audioProvider.player.durationStream,
                            builder: (_, snapDur) {
                              return MiniSeekBar(
                                duration: snapDur.data ?? const Duration(seconds: 1),
                                position: snapPos.data ?? Duration.zero,
                                onChangeEnd: (pos) => audioProvider.player.seek(pos),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // ── Konten Utama ─────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // ── Artwork: lokal pakai QueryArtwork, YT pakai Image.network ──
                            _buildArtwork(context),
                            const SizedBox(width: 3),

                            // ── Judul & Artis ─────────────────────────────────
                            Expanded(
                              child: Selector<AudioViewModel, (String, String)>(
                                selector: (_, p) => (p.displayTitle, p.displayArtist),
                                builder: (_, titles, __) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Judul dengan Marquee
                                      LayoutBuilder(
                                        builder: (ctx, constraints) {
                                          const style = TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          );
                                          final painter = TextPainter(
                                            text: TextSpan(text: titles.$1, style: style),
                                            maxLines: 1,
                                            textDirection: TextDirection.ltr,
                                          )..layout(minWidth: 0, maxWidth: double.infinity);

                                          return SizedBox(
                                            height: 20,
                                            child: painter.size.width > constraints.maxWidth
                                                ? Marquee(
                                                    text: titles.$1,
                                                    style: style,
                                                    blankSpace: 50,
                                                    velocity: 30,
                                                    accelerationDuration: Duration.zero,
                                                  )
                                                : Text(
                                                    titles.$1,
                                                    style: style,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        titles.$2,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // ── Controls ──────────────────────────────────────
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Prev
                                StreamBuilder<SequenceState?>(
                                  stream: audioProvider.player.sequenceStateStream,
                                  builder: (_, snap) {
                                    final canBack = (snap.data?.currentIndex ?? 0) > 0;
                                    return IconButton(
                                      onPressed: canBack
                                          ? () {
                                              audioProvider.player.seekToPrevious();
                                              audioProvider.player.play();
                                              audioProvider.resetPlaybackTimer();
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: canBack ? Colors.white : Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),

                                // Play/Pause
                                Selector<AudioViewModel, bool>(
                                  selector: (_, p) => p.isPlaying,
                                  builder: (_, isPlaying, __) {
                                    return IconButton(
                                      onPressed: audioProvider.togglePlay,
                                      icon: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),

                                // Next
                                StreamBuilder<SequenceState?>(
                                  stream: audioProvider.player.sequenceStateStream,
                                  builder: (_, snap) {
                                    final canNext =
                                        (snap.data?.currentIndex ?? 0) <
                                        ((snap.data?.sequence.length ?? 0) - 1);
                                    return IconButton(
                                      onPressed: canNext
                                          ? () {
                                              audioProvider.player.seekToNext();
                                              audioProvider.player.play();
                                              audioProvider.resetPlaybackTimer();
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: canNext ? Colors.white : Colors.grey,
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Artwork Builder ──────────────────────────────────────────────────────────
  Widget _buildArtwork(BuildContext context) {
    return Selector<AudioViewModel, (int?, Uri?)>(
      selector: (_, p) => (p.currentSong?.id, p.displayArtUri),
      builder: (_, data, __) {
        final localId = data.$1;
        final ytArtUri = data.$2;

        // Kalau ada ID lokal → pakai QueryArtworkWidget
        if (localId != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: QueryArtworkWidget(
              id: localId,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: _defaultArtwork(),
              artworkFit: BoxFit.cover,
              size: 200,
            ),
          );
        }

        // Kalau YouTube → pakai thumbnail dari URL
        if (ytArtUri != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              ytArtUri.toString(),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultArtwork(),
            ),
          );
        }

        return _defaultArtwork();
      },
    );
  }

  Widget _defaultArtwork() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}