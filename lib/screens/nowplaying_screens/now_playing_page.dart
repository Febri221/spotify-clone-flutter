import 'package:flutter/material.dart';
import 'package:percobaan/screens/nowplaying_screens/lyirics_screen.dart';
import 'package:percobaan/widgets/control_button/loop_button.dart';
import 'package:percobaan/widgets/control_button/next.dart';
import 'package:percobaan/widgets/control_button/previous.dart';
import 'package:percobaan/widgets/control_button/shuffle.dart';
import 'package:provider/provider.dart'; // WAJIB ADA
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:percobaan/screens/player/seek_bar.dart';

// Import Provider Lo
import 'package:percobaan/providers/audio_provider.dart';
import '../../providers/playlist_provider.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController(initialPage: 0);

  int _currentPage = 0;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  void _toggleFloatingLyrics() async {
    // Logic Overlay tetep sama, aman.
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
              content: Text("Lyrics Off"),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 1),
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lyrics On"),
            backgroundColor: Colors.greenAccent,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("ERROR TOGGLE OVERLAY: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // --- CARA BARU AKSES DATA (PROVIDER) ---

    // 1. Ambil Data lagu menggunakan select karena kita cuma butuh currentSong doang, biar gak rebuild semua widget yang dengerin provider ini
    final currentSong = context.select<AudioProvider, SongModel?>((provider)=> provider.currentSong);

    // 2. Ambil Kontrol Player (Pakai read buat tombol-tombol)
    final audioProvider = context.read<AudioProvider>();

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
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedOpacity(
                    opacity: _currentPage == 0 ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: const Text(
                      'Song',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                const Text('|', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedOpacity(
                    opacity: _currentPage == 1 ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: const Text(
                      'Lyrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            if (currentSong != null)
              _buildPlayerUI(context, screenWidth, currentSong, audioProvider)
            else
              const Center(child: CircularProgressIndicator()),

            if (currentSong != null)
              LyricsScreen(currentSong: currentSong)
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  // ==AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
  Widget _buildPlayerUI(
    BuildContext context,
    double screenWidth,
    SongModel currentSong,
    AudioProvider audioProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- GAMBAR ALBUM ---
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: screenWidth - 50,
                      height: screenWidth - 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: QueryArtworkWidget(
                          // berikan id yang unik untuk setiap lagu, biar widget ini gak bingung pas rebuild dan gak reload gambarnya terus-menerus
                          key: ValueKey(currentSong.id),
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          artworkHeight: double.infinity,
                          artworkWidth: double.infinity,
                          artworkFit: BoxFit.cover,
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
                ),
                // --- TOMBOL LIRIK ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Selector<PlaylistProvider, bool>(
                        selector: (_, provider) =>
                            provider.isFavorite(currentSong.id),
                        builder: (context, isFavorite, child) {
                          return InkWell(
                            onTap: () {
                              final bool isliked = context
                                  .read<PlaylistProvider>()
                                  .toggleFavorite(currentSong.id);

                              final String songTitle = currentSong.title;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isliked
                                        ? "$songTitle  Ditambahkan ke Favorit"
                                        : "$songTitle  Dihapus dari Favorit",
                                  ),
                                  backgroundColor: isliked
                                      ? Colors.green
                                      : Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.green : Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      InkWell(
                        onTap: _toggleFloatingLyrics,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
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
                // --- JUDUL LAGU ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final displayTitle = currentSong.title.trim().isNotEmpty
                          ? currentSong.title
                          : currentSong.displayNameWOExt;
                      const textStyle = TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      );
                      final textPainter = TextPainter(
                        text: TextSpan(text: displayTitle, style: textStyle),
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                        textScaler: MediaQuery.of(context).textScaler,
                      )..layout(minWidth: 0, maxWidth: double.infinity);

                      return SizedBox(
                        height: 30,
                        width: constraints.maxWidth,
                        child:
                            textPainter.size.width > (constraints.maxWidth - 5)
                            ? Marquee(
                                text: displayTitle,
                                style: textStyle,
                                scrollAxis: Axis.horizontal,
                                blankSpace: 50.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 2),
                                startPadding: 10.0,
                                accelerationDuration: Duration.zero,
                                decelerationDuration: const Duration(
                                  milliseconds: 500,
                                ),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: Text(
                                  displayTitle,
                                  style: textStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // --- ARTIS ---
                Text(
                  currentSong.artist == "<unknown>"
                      ? "Unknown Artist"
                      : (currentSong.artist ?? "Unknown Artist"),
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),

          // --- SEEKBAR (SLIDER) ---
          // Di sini kita ambil stream dari Provider
          StreamBuilder<PositionData>(
            stream: audioProvider.positionDataStream,
            initialData: audioProvider.currentPositionData,
            builder: (context, snapshot) {
              final positionData = snapshot.data;

              Duration duration = positionData?.duration ?? Duration.zero;

              if (duration == Duration.zero && currentSong.duration != null) {
                duration = Duration(milliseconds: currentSong.duration!);
              }
              return SeekBar(
                duration: duration,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: (value) {
                  // Panggil fungsi seek punya provider
                  audioProvider.seek(value);
                },
              );
            },
          ),
          const SizedBox(height: 30),

          // --- TOMBOL CONTROLS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. SHUFFLE
              ShuffleControll(),

              // 2. PREVIOUS
              PreviousControll(),
              // 3. PLAY / PAUSE (Ini pake logic Provider)
              // Kita pake Selector atau Watch khusus variabel isPlaying
              Builder(
                builder: (context) {
                  final isPlaying = context.watch<AudioProvider>().isPlaying;
                  return IconButton(
                    onPressed: () {
                      // Panggil fungsi togglePlay yang udah lo buat di Provider
                      audioProvider.togglePlay();
                      audioProvider.stopPlaybackTimer();
                    },
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 75,
                    ),
                  );
                },
              ),

              // 4. NEXT Button
              NextControll(),

              // 5. LOOP Button
              LoopButton(),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
