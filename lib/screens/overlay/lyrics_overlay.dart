import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class LyricsOverlay extends StatefulWidget {
  const LyricsOverlay({super.key});

  @override
  State<LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends State<LyricsOverlay> {
  final double widthWindow = 450;

  StreamSubscription? _listener;
  int currentIndex = 0;
  bool isTouching = false;

  // --- PERBAIKAN 1: HAPUS 'final' DI SINI ---
  // Biar variabel ini bisa diisi ulang pas ganti lagu
  List<Map<String, dynamic>> lyrics = []; 

  @override
  void initState() {
    super.initState();
    _listener = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is int) {
        _syncLyrics(data);
      } else if (data is List) {
        try  {
          // Parsing data dari List dynamic ke List Map
          final newLyrics = List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
          
          setState(() {
            // --- PERBAIKAN 2: HAPUS 'final' DI SINI ---
            // Langsung timpa variabel utama, jangan bikin variabel baru!
            lyrics = newLyrics; 
            currentIndex = 0;
          });
        } catch (e) {
          print('Error parsing lyrics: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  void _syncLyrics(int position) {
    // Cegah crash kalau lirik masih kosong
    if (lyrics.isEmpty) return; 

    int newIndex = 0;
    for (int i = 0; i < lyrics.length; i++) {
      if (position >= lyrics[i]['time']) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != currentIndex) {
      setState(() {
        currentIndex = newIndex;
      });
    }
  }

  String getLyricSafe(int index) {
    if (index >= 0 && index < lyrics.length) {
      return lyrics[index]['text'];
    }
    return "";
  }

  Widget _buildAnimatedText(String text, TextStyle style) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final bool isNewText = (child.key as ValueKey<String>).value == text;
        final offsetAnimation = Tween<Offset>(
          begin: isNewText ? const Offset(0.0, 1.0) : const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: Container(
        width: widthWindow,
        key: ValueKey<String>(text),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Listener(
        onPointerDown: (_) => setState(() => isTouching = true),
        onPointerUp: (_) => setState(() => isTouching = false),
        onPointerCancel: (_) => setState(() => isTouching = false),

        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isTouching
                ? Colors.black.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAnimatedText(
                  getLyricSafe(currentIndex - 1),
                  const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),

                const SizedBox(height: 16),

                _buildAnimatedText(
                  getLyricSafe(currentIndex),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),

                const SizedBox(height: 16),

                _buildAnimatedText(
                  getLyricSafe(currentIndex + 1),
                  const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}