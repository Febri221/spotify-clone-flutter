package com.example.percobaan // <--- BIARIN INI SESUAI ASLINYA, JANGAN UBAH BARIS INI

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine // <--- Tambahan
import io.flutter.plugin.common.MethodChannel // <--- Tambahan

class MainActivity: FlutterActivity() {
    // Kita bikin jalur komunikasi namanya "android/back_button"
    private val CHANNEL = "android/back_button"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "minimizeApp") {
                
                this.moveTaskToBack(true)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}