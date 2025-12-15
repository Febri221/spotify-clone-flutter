import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percobaan/screens/search_page.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/data/running_teks.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class NowPlayingPage extends StatefulWidget {
  final List<SongModel> songs;
  final AudioPlayer player;
  

  NowPlayingPage({super.key, required this.player, required this.songs});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  void _toggleFloatingLyrics() async {
    try {
      // 1. Cek & Minta Izin dulu (Wajib)
      final bool status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        final bool? result = await FlutterOverlayWindow.requestPermission();
        if (result != true) {
            // Jika user nolak, stop di sini
            return; 
        }
      }

      // 2. Cek Status Overlay
      final bool isActive = await FlutterOverlayWindow.isActive();
      
      if (isActive) {
        // Kalau Aktif -> Tutup
        await FlutterOverlayWindow.closeOverlay();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Lyrics closed"), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)),
           );
        }
      } else {
        // Kalau Mati -> Buka
        await _showOverlayNow();
      }
      
    } catch (e) {
      print("ERROR TOGGLE OVERLAY: $e");
    }
  }

  // --- TARUH FUNGSI INI DI BAWAH _toggleFloatingLyrics ---
  
  Future<void> _showOverlayNow() async {
    try {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true, // Default false, nanti diatur sama LongPress di Overlay
        overlayTitle: "Lyrics",
        overlayContent: "Lyrics Overlay",
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilitySecret, // Biar gakuh notif
        positionGravity: PositionGravity.none, // Biar posisi bebas (bisa digeser)
        height: 400, // Tinggi Mode Mini
        width: 550,  // Lebar Mode Mini
      );
    } catch (e) {
      print("Error showOverlay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Dismissible(
      key: const Key('play_screen_dismiss'),
      direction: DismissDirection.down,

      onDismissed: (direction) {
        Navigator.pop(context);
      },

      background: const ColoredBox(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(
            padding: EdgeInsets.only(top: 30.0, left: 20),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
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
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- BAGIAN 1: DATA LAGU (GAMBAR, JUDUL, ARTIS) ---
              Expanded(
                flex: 6,
                child: StreamBuilder<SequenceState?>(
                  stream: widget.player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.currentSource == null) return const SizedBox();

                    final currentIndex = state!.currentIndex;
                    final currentSong = widget.songs[currentIndex];

                    // LOGIKA BAN SEREP:
                    // Kalau Title kosong, pake displayNameWOExt (Nama file tanpa .mp3)
                    final displayTitle = currentSong.title.trim().isNotEmpty
                        ? currentSong.title
                        : currentSong.displayNameWOExt;

                    return Column(
                      children: [
                        // GAMBAR
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
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(top: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                // ==================================
                                onTap: _toggleFloatingLyrics,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.layers,
                                    color: Colors.tealAccent,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // JUDUL
                        // JUDUL
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // 1. Definisikan Style SEKALI saja agar konsisten (Hitungan & Tampilan sama)
                              final textStyle = const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              );

                              // 2. Hitung Lebar Teks pakai displayTitle
                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: displayTitle,
                                  style: textStyle,
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                                // Wajib: Ikuti skala font HP user
                                textScaleFactor: MediaQuery.of(
                                  context,
                                ).textScaleFactor,
                              )..layout(minWidth: 0, maxWidth: double.infinity);

                              // 3. LOGIKA AKURAT + BUFFER
                              // Kita kurangi lebar layar 5 pixel (-5).
                              // Artinya: Kalau teksnya PAS-PASAN atau MEPET, anggap kepanjangan & jalankan Marquee.
                              final bool isOverflowing =
                                  textPainter.size.width >
                                  (constraints.maxWidth - 5);

                              return SizedBox(
                                height: 30,
                                width: constraints.maxWidth,
                                child: isOverflowing
                                    ? Marquee(
                                        text: displayTitle,
                                        style: textStyle,
                                        scrollAxis: Axis.horizontal,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        blankSpace: 50.0,
                                        velocity: 30.0,
                                        pauseAfterRound: const Duration(
                                          seconds: 2,
                                        ),
                                        startPadding: 10.0,
                                        accelerationDuration: Duration.zero,
                                        decelerationDuration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      )
                                    : Align(
                                        // Pakai Align/Center untuk teks diam
                                        alignment: Alignment.center,
                                        child: Text(
                                          displayTitle,
                                          style:
                                              textStyle, // Style harus sama persis dengan Marquee
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ARTIS
                        Text(
                          currentSong.artist == "<unknown>"
                              ? "Unknown Artist"
                              : (currentSong.artist ?? "Unknown Artist"),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              StreamBuilder<Duration>(
                stream: widget.player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = widget.player.duration ?? Duration.zero;

                  final maxDuration = duration.inMilliseconds.toDouble();
                  final validMax = maxDuration > 0 ? maxDuration : 1.0;
                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        value: position.inMilliseconds.toDouble().clamp(
                          0,
                          validMax,
                        ),
                        activeColor: Colors.teal,
                        inactiveColor: Colors.grey[800],
                        max: validMax,
                        onChanged: (value) {
                          widget.player.seek(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              _formatDuration(position),
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // SHUFFLE BUTTON
                          StreamBuilder<bool>(
                            stream: widget.player.shuffleModeEnabledStream,
                            builder: (context, snapshot) {
                              final shuffleenabled = snapshot.data ?? false;

                              return IconButton(
                                onPressed: () async {
                                  final enable = !shuffleenabled;

                                  if (enable) {
                                    await widget.player.shuffle();
                                    widget.player.play();
                                  }
                                  await widget.player.setShuffleModeEnabled(
                                    enable,
                                  );
                                },
                                icon: Icon(
                                  Icons.shuffle,
                                  color: shuffleenabled
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 25,
                                ),
                              );
                            },
                          ),
                          StreamBuilder<SequenceState?>(
                            stream: widget.player.sequenceStateStream,
                            builder: (context, snapshot) {
                              final sequenceState = snapshot.data;

                              // FIX: Hitung manual. Can go back kalau currentIndex lebih besar dari 0 (lagu pertama).
                              final bool canGoBack =
                                  (sequenceState?.currentIndex ?? 0) > 0;

                              return IconButton(
                                onPressed: canGoBack
                                    ? () {
                                        widget.player.seekToPrevious();
                                        widget.player.play();
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.skip_previous_rounded,
                                  color: canGoBack ? Colors.white : Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                          StreamBuilder<PlayerState>(
                            stream: widget.player.playerStateStream,
                            builder: (context, snapshot) {
                              final playing = snapshot.data?.playing;

                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (playing == true) {
                                      widget.player.pause();
                                    } else {
                                      widget.player.play();
                                    }
                                  },
                                  icon: Icon(
                                    playing == true
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),

                          StreamBuilder<SequenceState?>(
                            stream: widget.player.sequenceStateStream,
                            builder: (context, snapshot) {
                              final sequenceState = snapshot.data;
                              final bool canGoNext =
                                  (sequenceState?.currentIndex ?? 0) <
                                  (widget.songs.length - 1);
                              return IconButton(
                                onPressed: canGoNext
                                    ? () async {
                                        await widget.player.seekToNext();
                                        widget.player.play();
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.skip_next_rounded,
                                  color: canGoNext ? Colors.white : Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          ),

                          // LOOP BUTTON
                          StreamBuilder<LoopMode>(
                            stream: widget.player.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data ?? LoopMode.off;

                              IconData icon;
                              Color color;
                              if (loopMode == LoopMode.one) {
                                icon = Icons.repeat_one_rounded;
                                color = Colors.white;
                              } else if (loopMode == LoopMode.all) {
                                icon = Icons.repeat_rounded;
                                color = Colors.white;
                              } else {
                                icon = Icons.repeat_rounded;
                                color = Colors.grey;
                              }

                              return IconButton(
                                onPressed: () async {
                                  LoopMode newMode = LoopMode.off;

                                  if (loopMode == LoopMode.off) {
                                    newMode = LoopMode.all;
                                  } else if (loopMode == LoopMode.all) {
                                    newMode = LoopMode.one;
                                  } else {
                                    newMode = LoopMode.off;
                                  }
                                  await widget.player.setLoopMode(newMode);
                                },
                                icon: Icon(icon, color: color, size: 25),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
