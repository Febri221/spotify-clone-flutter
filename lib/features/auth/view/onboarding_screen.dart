import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percobaan/features/auth/view/sign_up_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  Future<void> _skipToSignUp() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('hasSeenOnboarding', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    }
  }

  // Widget Skip yang tadinya copy-paste 3x, sekarang cukup sekali
  Widget _buildSkipButton({bool visible = true}) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.66, top: 70),
        child: InkWell(
          onTap: _skipToSignUp,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('Skip', style: TextStyle(color: Colors.black, fontSize: 18)),
                SizedBox(width: 5),
                Icon(Icons.keyboard_double_arrow_right, color: Colors.black, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              _buildPage(
                svgPath: 'images/undraw_happy-music_na4p.svg',
                title: 'Jelajahi Semesta Musik Mu',
                subtitle: 'Temukan berbagai lagu dari\nmusisi favorit mu',
                showSkip: true,
                onAction: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                actionLabel: 'Next',
              ),
              _buildPage(
                svgPath: 'images/undraw_playlist_lwhi.svg',
                title: 'Buat Playlist Terbaik Kamu',
                subtitle: 'Atur lagu sesuka hati. Dari yang santai\nsampai yang sad, intinya Enjoy setiap momen',
                showSkip: true,
                onAction: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                actionLabel: 'Next',
              ),
              _buildPage(
                svgPath: 'images/undraw_audio-player_7uwh.svg',
                title: 'Lirik Mengudara, Nyanyi Terus',
                subtitle: 'Fitur lirik ngambang\nsiap menemani di layar HP mu',
                showSkip: false, // Halaman terakhir skip disembunyiin
                onAction: _skipToSignUp,
                actionLabel: 'Get Started',
              ),
            ],
          ),
          Positioned(
            bottom: 220.0,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const ExpandingDotsEffect(
                  spacing: 5.55,
                  radius: 4.0,
                  dotWidth: 6.47,
                  dotHeight: 4.62,
                  dotColor: Colors.black,
                  activeDotColor: Colors.black,
                  expansionFactor: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String svgPath,
    required String title,
    required String subtitle,
    required bool showSkip,
    required VoidCallback onAction,
    required String actionLabel,
  }) {
    return SafeArea(
      child: Column(
        children: [
          _buildSkipButton(visible: showSkip),
          const SizedBox(height: 80),
          SvgPicture.asset(svgPath, width: 232, height: 238),
          const SizedBox(height: 50.57),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18.48),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 70),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22.2,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}