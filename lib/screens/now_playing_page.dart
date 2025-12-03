import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percobaan/screens/search_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
        backgroundColor: Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: IconButton(
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: EdgeInsetsGeometry.only(top: 20.0),
            child: Text('Now Playing', style: TextStyle(color: Colors.white))),
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
      
                        const SizedBox(height: 30),
      
                        // JUDUL (Udah dipasang ban serep)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            displayTitle, // <-- Pake variabel baru ini
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
      
                        const SizedBox(height: 10),
      
                        // ARTIS
                        Text(
                          currentSong.artist == "<unknown>"
                              ? "Unknown Artist"
                              : (currentSong.artist ?? "Unknown Artist"),
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
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
                          StreamBuilder<SequenceState?>(
                            stream: widget.player.sequenceStateStream,
                            builder: (context, snapshot) {
                              final  sequenceState = snapshot.data;
      
                              // FIX: Hitung manual. Can go back kalau currentIndex lebih besar dari 0 (lagu pertama).
                              final bool canGoBack =
                                  (sequenceState?.currentIndex ?? 0) > 0;
      
                              return IconButton(
                                onPressed: canGoBack ? widget.player.seekToPrevious : null,
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
                                  (sequenceState?.currentIndex ?? 0) < (widget.songs.length - 1);
                              return IconButton(
                                onPressed: canGoNext ? widget.player.seekToNext : null,
                                icon: Icon(
                                  Icons.skip_next_rounded,
                                  color: canGoNext ? Colors.white : Colors.grey,
                                  size: 50,
                                ),
                              );
                            }
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
      );
  }
}
