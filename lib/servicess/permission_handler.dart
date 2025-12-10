import 'package:permission_handler/permission_handler.dart';

Future<bool> requestAudioPermission() async {
  final status = await Permission.audio.status;

  if (status.isDenied || status.isRestricted) {
    final result = await Permission.audio.request();
    return result.isGranted;
  }

  return status.isGranted;
}
