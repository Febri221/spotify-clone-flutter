import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class LyricsOverlay extends StatefulWidget {
  const LyricsOverlay({super.key});

  @override
  State<LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends State<LyricsOverlay> {
  final PageController _pageController = PageController(viewportFraction: 0.35);

  StreamSubscription? _listener;
  int _currentIndex = 0;
  bool _isTouching = false;
  List<Map<String, dynamic>> _lyrics = [];

  @override
  void initState() {
    super.initState();
    _listener = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is int) {
        _syncLyrics(data);
      } else if (data is List) {
        try {
          final newLyrics = List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );

          if (!mounted) return;

          final isSameSong = _lyrics.isNotEmpty &&
              newLyrics.isNotEmpty &&
              _lyrics.length == newLyrics.length &&
              _lyrics[0]['text'] == newLyrics[0]['text'];

          setState(() {
            _lyrics = newLyrics;
            if (!isSameSong) {
              _currentIndex = 0;
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            }
          });
        } catch (e) {
          debugPrint('Error parsing lyrics: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _syncLyrics(int position) {
    if (_lyrics.isEmpty) return;

    int newIndex = 0;
    for (int i = 0; i < _lyrics.length; i++) {
      if (position >= _lyrics[i]['time']) {
        newIndex = i;
      } else {
        break;
      }
    }

    // Jangan mundur kalau selisihnya kecil (< 1.5 detik)
    if (newIndex < _currentIndex) {
      final diff = _lyrics[_currentIndex]['time'] - position;
      if (diff < 1500) return;
    }

    if (newIndex == _currentIndex) return;

    setState(() => _currentIndex = newIndex);

    if (_pageController.hasClients) {
      final diff = (newIndex - _currentIndex).abs();
      if (diff > 2) {
        _pageController.jumpToPage(newIndex);
      } else {
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (_, constraints) {
          final overlayWidth = constraints.maxWidth;

          return Listener(
            onPointerDown: (_) => setState(() => _isTouching = true),
            onPointerUp: (_) => setState(() => _isTouching = false),
            onPointerCancel: (_) => setState(() => _isTouching = false),
            child: GestureDetector(
              onDoubleTap: () async => FlutterOverlayWindow.closeOverlay(),
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _isTouching
                      ? Colors.black.withOpacity(0.9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _lyrics.isEmpty
                    ? const SizedBox()
                    : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lyrics.length,
                        itemBuilder: (_, index) {
                          final isActive = index == _currentIndex;
                          final text = _lyrics[index]['text'] ?? '';

                          return Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: isActive ? 1.0 : 0.5,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 400),
                                scale: isActive ? 1.0 : 0.85,
                                curve: Curves.easeOutBack,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: overlayWidth - 20,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Ghost text buat stabilkan ukuran
                                        Text(
                                          text,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.transparent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            fontFamily: 'Roboto',
                                          ),
                                          textAlign: TextAlign.center,
                                          child: Text(text,
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}