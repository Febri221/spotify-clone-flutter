import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:percobaan/screens/auth/login_screen.dart';
import 'package:percobaan/screens/auth/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              // LAYAR 1
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 24.66, top: 70),
                      child: InkWell(
                        onTap: () async {
                          final pref = await SharedPreferences.getInstance();
                          await pref.setBool('hasSeenOnboarding', true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),

                    SvgPicture.asset(
                      'images/undraw_happy-music_na4p.svg',
                      width: 232,
                      height: 238,
                    ),
                    SizedBox(height: 50.57),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Jelajahi Semesta Musik Mu',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 18.48),
                          Text(
                            'Temukan berbagai lagu dari\nmusisi favorit mu ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 70),
                          TextButton(
                            onPressed: () {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.2,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LAYAR 2
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 24.66, top: 70),
                      child: InkWell(
                        onTap: () async {
                          final pref = await SharedPreferences.getInstance();
                          await pref.setBool('hasSeenOnboarding', true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),

                    SvgPicture.asset(
                      'images/undraw_playlist_lwhi.svg',
                      width: 232,
                      height: 238,
                    ),
                    SizedBox(height: 50.57),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Buat Playlist Terbaik Kamu',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 18.48),
                          Text(
                            'Atur lagu sesuka hati. Dari yang santai\nsampai yang sad, intinya Enjoy setiap momen',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 70),
                          TextButton(
                            onPressed: () {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.2,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LAYAR 3
              SafeArea(
                child: Column(
                  children: [
                    Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24.66, top: 70),
                        child: InkWell(
                          onTap: () async {
                            final pref = await SharedPreferences.getInstance();
                            await pref.setBool('hasSeenOnboarding', true);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.keyboard_double_arrow_right,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),

                    SvgPicture.asset(
                      'images/undraw_audio-player_7uwh.svg',
                      width: 232,
                      height: 238,
                    ),
                    SizedBox(height: 50.57),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Lirik Mengudara, Nyanyi Terus',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 18.48),
                          Text(
                            'Fitur lirik ngambang\nsiap menemani di layar HP mu',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 70),
                          TextButton(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.2,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                axisDirection: Axis.horizontal,
                effect: ExpandingDotsEffect(
                  spacing: 5.55,
                  radius: 4.0,
                  dotWidth: 6.47,
                  dotHeight: 4.62,
                  paintStyle: PaintingStyle.fill,
                  strokeWidth: 1.5,
                  dotColor: Colors.black,
                  activeDotColor: Colors.black,
                  offset: 16.0,
                  expansionFactor: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
