import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<bool> requestPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // Cek jika Android 13 atau lebih baru (SDK 33+)
    if (androidInfo.version.sdkInt >= 33) {
      // Minta izin AUDIO dan PHOTOS (Images) sekaligus
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.photos, // <--- INI KUNCINYA (Sering lupa di sini)
      ].request();

      // Pastikan keduanya diizinkan
      if (statuses[Permission.audio]!.isGranted && statuses[Permission.photos]!.isGranted) {
        return true;
      }
    } else {
      // Untuk Android 12 ke bawah
      var status = await Permission.storage.request();
      if (status.isGranted) return true;
    }
  }
  return false;
}