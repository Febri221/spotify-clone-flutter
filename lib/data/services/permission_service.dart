import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+ pakai Permission.audio
      if (await Permission.audio.isGranted) return true;

      final statuses = await [Permission.audio, Permission.photos].request();
      return statuses[Permission.audio]?.isGranted ?? false;
    } else {
      // Android < 13 pakai Permission.storage
      if (await Permission.storage.isGranted) return true;

      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
}