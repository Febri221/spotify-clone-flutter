import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/data/models/position_data.dart';
import 'package:percobaan/features/now_playing/widgets/album_art_widget.dart';
import 'package:percobaan/features/now_playing/widgets/lyrics_screen.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';
import 'package:percobaan/features/library/viewmodel/playlist_viewmodel.dart';
import 'package:percobaan/features/player/widgets/seek_bar.dart';
import 'package:percobaan/features/player/widgets/control_button/loop_button.dart';
import 'package:percobaan/features/player/widgets/control_button/next.dart';
import 'package:percobaan/features/player/widgets/control_button/previous.dart';
import 'package:percobaan/features/player/widgets/control_button/shuffle.dart';

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
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  Future<void> _toggleFloatingLyrics() async {
    try {
      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        final granted = await FlutterOverlayWindow.requestPermission();
        if (granted != true) return;
      }

      final isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lyrics Off'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: 'Lyrics',
          overlayContent: 'Lyrics Overlay',
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilitySecret,
          positionGravity: PositionGravity.none,
          height: 400,
          width: 550,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lyrics On'),
              backgroundColor: Colors.greenAccent,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggle overlay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hanya dengerin perubahan currentSong — bukan isPlaying
    final currentSong = context.select<AudioViewModel, SongModel?>(
      (vm) => vm.currentSong,
    );
    final vm = context.read<AudioViewModel>();

    return Dismissible(
      key: const Key('now_playing_dismiss'),
      direction: DismissDirection.down,
      onDismissed: (_) => Navigator.pop(context),
      background: const ColoredBox(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabLabel('Song', 0),
                const SizedBox(width: 20),
                const Text('|', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 20),
                _buildTabLabel('Lyrics', 1),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            if (currentSong != null)
              _buildPlayerUI(context, currentSong, vm)
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

  Widget _buildTabLabel(String label, int page) {
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: AnimatedOpacity(
        opacity: _currentPage == page ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerUI(
    BuildContext context,
    SongModel currentSong,
    AudioViewModel vm,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final artSize = screenWidth - 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // ✅ Album art pakai widget terpisah — tidak ikut rebuild
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: artSize,
                      height: artSize,
                      child: AlbumArtWidget(
                        songId: currentSong.id,
                        size: artSize,
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ Selector hanya rebuild bagian favorit
                      Selector<PlaylistViewModel, bool>(
                        selector: (_, vm) => vm.isFavorite(currentSong.id),
                        builder: (context, isFav, _) {
                          return InkWell(
                            onTap: () {
                              final isLiked = context
                                  .read<PlaylistViewModel>()
                                  .toggleFavorite(currentSong.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isLiked
                                      ? '${currentSong.title} ditambahkan ke Favorit'
                                      : '${currentSong.title} dihapus dari Favorit'),
                                  backgroundColor:
                                      isLiked ? Colors.green : Colors.red,
                                  duration: const Duration(seconds: 1),
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
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.green : Colors.white,
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
                          child: const Icon(Icons.layers,
                              color: Colors.tealAccent, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Song title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final title = currentSong.title.trim().isNotEmpty
                          ? currentSong.title
                          : currentSong.displayNameWOExt;
                      const style = TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      );
                      final painter = TextPainter(
                        text: TextSpan(text: title, style: style),
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                        textScaler: MediaQuery.of(context).textScaler,
                      )..layout(minWidth: 0, maxWidth: double.infinity);

                      return SizedBox(
                        height: 30,
                        width: constraints.maxWidth,
                        child: painter.size.width > (constraints.maxWidth - 5)
                            ? Marquee(
                                text: title,
                                style: style,
                                blankSpace: 50,
                                velocity: 30,
                                pauseAfterRound: const Duration(seconds: 2),
                                startPadding: 10,
                                accelerationDuration: Duration.zero,
                                decelerationDuration:
                                    const Duration(milliseconds: 500),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: Text(title,
                                    style: style,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Artist
                Text(
                  currentSong.artist == '<unknown>'
                      ? 'Unknown Artist'
                      : (currentSong.artist ?? 'Unknown Artist'),
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),

          // Seekbar
          StreamBuilder<PositionData>(
            stream: vm.positionDataStream,
            initialData: vm.currentPositionData,
            builder: (_, snapshot) {
              final pos = snapshot.data;
              var duration = pos?.duration ?? Duration.zero;
              if (duration == Duration.zero && currentSong.duration != null) {
                duration = Duration(milliseconds: currentSong.duration!);
              }
              return SeekBar(
                duration: duration,
                position: pos?.position ?? Duration.zero,
                bufferedPosition: pos?.bufferedPosition ?? Duration.zero,
                onChangeEnd: vm.seek,
              );
            },
          ),
          const SizedBox(height: 30),

          // ✅ Controls — Selector hanya rebuild tombol play/pause
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const ShuffleControll(),
              const PreviousControll(),
              Selector<AudioViewModel, bool>(
                selector: (_, vm) => vm.isPlaying,
                builder: (_, isPlaying, __) {
                  return IconButton(
                    onPressed: vm.togglePlay,
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
              const NextControll(),
              const LoopButton(),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}