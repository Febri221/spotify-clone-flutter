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
  int currentIndex = 0;
  bool isTouching = false;
  List<Map<String, dynamic>> lyrics = [];

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

          if (mounted) {
            bool isSameSong = false;
            if (lyrics.isNotEmpty && newLyrics.isNotEmpty) {
              if (lyrics.length == newLyrics.length &&
                  lyrics[0]['text'] == newLyrics[0]['text']) {
                isSameSong = true;
              }
            }

            setState(() {
              lyrics = newLyrics;
              if (!isSameSong) {
                currentIndex = 0;
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
              }
            });
          }
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
    if (lyrics.isEmpty) return;

    int newIndex = 0;
    for (int i = 0; i < lyrics.length; i++) {
      if (position >= lyrics[i]['time']) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex < currentIndex) {
      final int currentLyricStartTime = lyrics[currentIndex]['time'];
      final int diff = currentLyricStartTime - position;
      if (diff < 1500) return;
    }

    if (newIndex == currentIndex) return;

    setState(() {
      currentIndex = newIndex;
    });

    if (_pageController.hasClients) {
      int diffIndex = (newIndex - currentIndex).abs();
      if (diffIndex > 2) {
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
        builder: (context, constraints) {
          // Ambil lebar window (misal 550)
          final double overlayWidth = constraints.maxWidth;

          return Listener(
            onPointerDown: (_) => setState(() => isTouching = true),
            onPointerUp: (_) => setState(() => isTouching = false),
            onPointerCancel: (_) => setState(() => isTouching = false),
            

            child: GestureDetector(
              onDoubleTap: () async {
                await FlutterOverlayWindow.closeOverlay();
              },

              behavior: HitTestBehavior.translucent,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isTouching
                      ? Colors.black.withOpacity(0.9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
              
                child: lyrics.isEmpty
                    ? const SizedBox()
                    : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lyrics.length,
                        itemBuilder: (context, index) {
                          final bool isActive = index == currentIndex;
                          final String textContent = lyrics[index]['text'] ?? "";
              
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
              
                            // 1. EFEK PUDAR
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: isActive ? 1.0 : 0.5,
              
                              // 2. EFEK MENGECIL (Scale)
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 400),
                                scale: isActive ? 1.0 : 0.85,
                                curve: Curves.easeOutBack,
              
                                // 3. SAFETY NET (FittedBox)
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
              
                                  child: Container(
                                    // Constraint Lebar (Biar turun baris)
                                    constraints: BoxConstraints(
                                      maxWidth: overlayWidth - 20,
                                    ),
              
                                    // 4. ANTI LOMPAT (Stack Ghost Text)
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // LAYER A: GHOST TEXT (HANTU)
                                        Text(
                                          textContent,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.transparent, // Gak kelihatan
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
              
                                        // LAYER B: REAL TEXT (ASLI)
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            fontFamily: 'Roboto',
                                          ),
                                          textAlign: TextAlign.center,
                                          child: Text(
                                            textContent,
                                            textAlign: TextAlign.center,
                                          ),
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