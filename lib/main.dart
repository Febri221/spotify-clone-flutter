import 'package:flutter/material.dart';
import 'package:percobaan/screens/auth/register_page.dart';
import 'package:percobaan/screens/splash_screen.dart';
import 'package:percobaan/widget/bottom_navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/screens/auth/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  

  await Hive.initFlutter();
  await Hive.openBox('Playlists');
  

  print("DEBUG: 3. Mulai Init Firebase");
  try {
    await Firebase.initializeApp();
    print("DEBUG: 3. Selesai Init Firebase");
  } catch (e) {
    print("ERROR FIREBASE: $e");
    // Pastikan file google-services.json sudah ada di android/app/
  }

  print("DEBUG: 4. Menjalankan App");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // LOGIC NOTE: Kamu punya AuthWrapper tapi gak dipake di sini?
      // Harusnya home: AuthWrapper() kalau mau cek login otomatis.
      // Tapi kalau emang mau SplashScreen dulu, pastikan SplashScreen punya navigasi.
      home: SplashScreen(), 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        return LoginPage();
      },
    );
  }
}