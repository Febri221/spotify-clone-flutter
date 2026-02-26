import 'package:flutter/material.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:percobaan/providers/playlist_provider.dart';
import 'package:percobaan/providers/song_provider.dart';
import 'package:percobaan/widgets/bottom_navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/screens/auth/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:percobaan/screens/overlay/lyrics_overlay.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox('Playlists');
  await Hive.openBox('HiddenSongs');
  await Hive.openBox('Favorites');

  print("DEBUG: 3. Mulai Init Firebase");
  try {
    await Firebase.initializeApp();
    print("DEBUG: 3. Selesai Init Firebase");
  } catch (e) {
    print("ERROR FIREBASE: $e");
    // Pastikan file google-services.json sudah ada di android/app/
  }

  await Future.delayed(const Duration(seconds: 1));

  FlutterNativeSplash.remove();

  runApp(MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LyricsOverlay()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => SongProvider()..fetchGlobalSongs()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Container(color: Colors.black, child: child);
        },
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          dialogBackgroundColor: Colors.black,
          cardColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: Colors.black,
            secondary: Colors.black,
          ),
          useMaterial3: true,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        // LOGIC NOTE: Kamu punya AuthWrapper tapi gak dipake di sini?
        // Harusnya home: AuthWrapper() kalau mau cek login otomatis.
        // Tapi kalau emang mau SplashScreen dulu, pastikan SplashScreen punya navigasi.
        home: BottomNavbar(),
      ),
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
