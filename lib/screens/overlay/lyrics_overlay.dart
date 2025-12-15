import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class LyricsOverlay extends StatefulWidget {
  const LyricsOverlay({super.key});

  @override
  State<LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends State<LyricsOverlay> {
  // GUA UBAH JADI 450 (Tadi 50 kekecilan bro, nanti teksnya jadi gepeng)
  final double widthWindow = 450; 

  StreamSubscription? _listener;
  int currentIndex = 0;
  bool isTouching = false;

  // Data Lirik (Sesuai kode lu)
  final List<Map<String, dynamic>> lyrics = [
    {'time': 0, 'text': '...'}, 
    {'time': 44852, 'text': 'I know a place'},
    {'time': 53985, 'text': 'It\'s somewhere I go when I need to remember your face'},
    {'time': 64208, 'text': 'We get married in our heads'},
    {'time': 73830, 'text': 'Something to do while we try to recall how we met'},
    {'time': 83728, 'text': 'Do you think I have forgotten?'},
    {'time': 89226, 'text': 'Do you think I have forgotten?'},
    {'time': 93533, 'text': 'Do you think I have forgotten'},
    {'time': 98661, 'text': 'About you?'},
    {'time': 103833, 'text': 'You and I (Don\'t let go)'},
    {'time': 107733, 'text': 'We\'re alive (Don\'t let go)'},
    {'time': 113235, 'text': 'With nothing to do, I could lay and just look in your eyes'},
    {'time': 123723, 'text': 'Wait (Don\'t let go)'},
    {'time': 127650, 'text': 'And pretend (Don\'t let go, oh)'},
    {'time': 133890, 'text': 'Hold on and hope that we\'ll find our way back in the end (In the end)'},
    {'time': 143059, 'text': 'Do you think I havе forgotten?'},
    {'time': 148883, 'text': 'Do you think I have forgotten?'},
    {'time': 154248, 'text': 'Do you think I havе forgotten'},
    {'time': 159152, 'text': 'About you?'},
    {'time': 164497, 'text': 'Do you think I have forgotten?'},
    {'time': 168712, 'text': 'Do you think I have forgotten?'},
    {'time': 173694, 'text': 'Do you think I have forgotten'},
    {'time': 178659, 'text': 'About you?'},
    {'time': 183639, 'text': 'And there was something about you that now I can\'t remember'},
    {'time': 188244, 'text': 'It\'s the same damn thing that made my heart surrender'},
    {'time': 193285, 'text': 'And I\'ll miss you on a train, I\'ll miss you in the mornin\''},
    {'time': 199255, 'text': 'I never know what to think about'},
    {'time': 202634, 'text': 'I think about you (Don\'t let go)'},
    {'time': 209423, 'text': 'About you (Don\'t let go)'},
    {'time': 214427, 'text': 'Do you think I have forgotten'},
    {'time': 219395, 'text': 'About you?'},
    {'time': 224604, 'text': 'About you (Don\'t let go, oh)'},
    {'time': 229298, 'text': 'About you'},
    {'time': 234685, 'text': 'Do you think I have forgotten'},
    {'time': 239248, 'text': 'About you (Don\'t let go)'},
    {'time': 242390, 'text': '...'},
  ];

  @override
  void initState() {
    super.initState();
    _listener = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is int) {
        _syncLyrics(data);
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  void _syncLyrics(int position) {
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

  // --- RAHASIA MULUSNYA ADA DI SINI ---
  Widget _buildAnimatedText(String text, TextStyle style) {
    return AnimatedSwitcher(
      // 600ms itu sweet spot. Gak kecepetan, gak kelambatan.
      duration: const Duration(milliseconds: 600),
      
      // Menggunakan curve 'Standard' yang dipakai Apple/Google buat animasi UI
      // Awalnya pelan, tengahnya cepet, akhirnya ngerem halus.
      switchInCurve: Curves.easeInOutCubic, 
      switchOutCurve: Curves.easeInOutCubic,

      // INI KUNCINYA: layoutBuilder
      // Kita paksa widget Lama dan Baru bertumpuk (Stack) di tengah.
      // Tanpa ini, widget lama kadang "dorong" widget baru, jadi getar.
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
        // Cek: Ini teks baru (Masuk) atau teks lama (Keluar)?
        final bool isNewText = (child.key as ValueKey<String>).value == text;

        // ANIMASI POSISI:
        // Kalau BARU: Muncul dari Bawah (Offset 0.0, 1.0) naik ke Tengah (0,0)
        // Kalau LAMA: Dari Tengah (0,0) naik ke Atas (Offset 0.0, -1.0)
        final offsetAnimation = Tween<Offset>(
          begin: isNewText ? const Offset(0.0, 1.0) : const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(animation);

        // Gabungan Fade + Slide biar liquid
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      
      child: Container(
        // Kunci width biar text center-nya konsisten
        width: widthWindow, 
        key: ValueKey<String>(text), // Key wajib unik
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3, 
          overflow: TextOverflow.ellipsis,
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
            color: isTouching ? Colors.black.withOpacity(0.9) : Colors.transparent, 
            borderRadius: BorderRadius.circular(20),
            border: isTouching ? Border.all(color: Colors.white24, width: 1) : null,
          ),
          
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                // 1. LIRIK LAMPAU (Previous)
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
                
                // 2. LIRIK SAAT INI (Current)
                _buildAnimatedText(
                  getLyricSafe(currentIndex),
                  const TextStyle(
                    color: Colors.white, 
                    fontSize: 13, // Gua gedein dikit biar kebaca
                    fontWeight: FontWeight.bold, 
                    height: 1.0,
                  ),
                ),
            
                const SizedBox(height: 16), 
            
                // 3. LIRIK AKAN DATANG (Upcoming)
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