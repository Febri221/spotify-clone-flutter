import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percobaan/widgets/bottom_navbar.dart';
import 'package:percobaan/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    print("DEBUG: Stempel Onboarding berhasil dicetak!");
    setState(() {
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }
        if (snapshot.hasData) {
          return BottomNavbar();
        }

        if (_hasSeenOnboarding) {
          return LoginPage();
        } else {
          return OnboardingScreen();
        }
      },
    );
  }
}
