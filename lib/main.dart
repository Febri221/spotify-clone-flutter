import 'package:flutter/material.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:percobaan/providers/playlist_provider.dart';
import 'package:percobaan/providers/song_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:percobaan/screens/overlay/lyrics_overlay.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/auth_wrapper.dart';
import 'package:percobaan/providers/auth_google_provider.dart';


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
        ChangeNotifierProvider(
          create: (_) => SongProvider()..fetchGlobalSongs()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => AuthGoogleProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF2962FF), // Biru malam pekat

          // dialogBackgroundColor: const Color(0xFF1E293B),

          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF38BDF8), // Aksen biru muda
            secondary: Color(0xFF94A3B8),

          ),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: UnderlineInputBorder(

            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade800),
            ),
          ),
          useMaterial3: true,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}