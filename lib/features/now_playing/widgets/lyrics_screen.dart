import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';
import 'package:percobaan/data/models/position_data.dart';
import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';

class LyricsScreen extends StatefulWidget {
  final dynamic currentSong;

  const LyricsScreen({super.key, required this.currentSong});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen>
    with AutomaticKeepAliveClientMixin {

  List<Map<String, dynamic>> _lyrics = [];
  bool _isLoading = true;
  int _lastAutoScrollIndex = -1;
  Duration _lastKnownPosition = Duration.zero;

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
    if (widget.currentSong.id != oldWidget.currentSong.id) {
      _loadLyrics();
      _lastKnownPosition = Duration.zero;
    }
  }

  Future<void> _loadLyrics() async {
    setState(() => _isLoading = true);

    final lrcString = await LyricsManager.getLyrics(
      widget.currentSong.artist ?? '',
      widget.currentSong.title,
    );

    final parsed = LyricsManager.parseLrc(lrcString);

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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_lyrics.isEmpty) {
      return Center(
        child: Text(
          'Lirik tidak ditemukan',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    final vm = context.read<AudioViewModel>();

    return StreamBuilder<PositionData>(
      stream: vm.positionDataStream,
      initialData: vm.currentPositionData,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.position != null) {
          _lastKnownPosition = snapshot.data!.position;
        }

        final currentMillis = _lastKnownPosition.inMilliseconds;

        int activeIndex = 0;
        for (int i = 0; i < _lyrics.length; i++) {
          if (currentMillis >= _lyrics[i]['time']) {
            activeIndex = i;
          } else {
            break;
          }
        }

        if (activeIndex != _lastAutoScrollIndex &&
            _itemScrollController.isAttached) {
          _lastAutoScrollIndex = activeIndex;
          final total = _lyrics.length;

          if (activeIndex == 0) {
            _itemScrollController.jumpTo(index: 0);
          } else if (activeIndex > 8 && activeIndex < (total - 10)) {
            _itemScrollController.scrollTo(
              index: activeIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
        }

        return ScrollablePositionedList.builder(
          itemCount: _lyrics.length,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (_, index) {
            final isPast = index <= activeIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isPast ? Colors.white : Colors.white.withOpacity(0.3),
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