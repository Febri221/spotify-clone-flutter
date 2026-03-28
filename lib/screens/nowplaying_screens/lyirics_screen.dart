import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';

class LyricsScreen extends StatefulWidget {
  final dynamic currentSong; // Data lagu yang lagi diputar

  const LyricsScreen({super.key, required this.currentSong});

  @override
  State<LyricsScreen> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsScreen>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _lyrics = [];
  bool _isLoading = true;
  int _lastAutoScrollIndex = -1;

  Duration _lastKnownPosition = Duration.zero;

  // Controller buat scroll otomatis
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void didUpdateWidget(covariant LyricsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kalau lagu ganti, muat ulang liriknya
    if (widget.currentSong.id != oldWidget.currentSong.id) {
      _loadLyrics();
      _lastKnownPosition;
    }
  }

  Future<void> _loadLyrics() async {
    setState(() => _isLoading = true);

    // 1. Ambil Lirik Mentah
    String lrcString = await LyricsManager.getLyrics(
      widget.currentSong.artist ?? "",
      widget.currentSong.title,
    );

    // 2. Parse jadi List
    var parsed = LyricsManager.parseLrc(lrcString);

    if (mounted) {
      setState(() {
        _lyrics = parsed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_lyrics.isEmpty) {
      return Center(
        child: Text(
          "Lirik tidak ditemukan",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    // 3. Dengerin Stream Waktu dari AudioProvider
    return StreamBuilder<PositionData>(
      stream: context.read<AudioProvider>().positionDataStream,
      initialData: context.read<AudioProvider>().currentPositionData,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.position != null) {
          _lastKnownPosition = snapshot.data!.position;
        }

        final currentMillis = _lastKnownPosition.inMilliseconds;

        // LOGIC SYNC: Cari lirik mana yang aktif sekarang
        int activeIndex = 0;
        for (int i = 0; i < _lyrics.length; i++) {
          if (currentMillis >= _lyrics[i]['time']) {
            activeIndex = i;
          } else {
            break;
          }
        }

        if (activeIndex != _lastAutoScrollIndex) {
          if (_itemScrollController.isAttached) {
            _lastAutoScrollIndex = activeIndex;

            int totalLyrics = _lyrics.length;

            int bottomThreshold = 10;

            if (activeIndex == 0) {
              _itemScrollController.jumpTo(index: 0);

            } else if (activeIndex > 8 && activeIndex < (totalLyrics - bottomThreshold)) {
              _itemScrollController.scrollTo(
                index: activeIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: 0.5,
              );
            }
          }
        }
        return ScrollablePositionedList.builder(
          itemCount: _lyrics.length,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            bool isPastLyricsColor = index <= activeIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isPastLyricsColor
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                child: Text(
                  _lyrics[index]['text'],
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
