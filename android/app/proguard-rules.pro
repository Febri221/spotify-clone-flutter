# Pertahankan class dari plugin overlay window
-keep class flutter.overlay.window.** { *; }

# Pertahankan class audio service (karena lu pake just_audio/audio_service)
-keep class com.ryanheise.audioservice.** { *; }

# Pertahankan semua entry point Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.engine.renderer.FlutterRenderer { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**