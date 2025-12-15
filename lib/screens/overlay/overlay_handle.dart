// import 'package:flutter/material.dart';
// import 'package:flutter_overlay_window/flutter_overlay_window.dart';

// class OverlayHandler {
  
//   // Method untuk Toggle (Buka/Tutup) - Bisa dipanggil dari mana saja
//   static Future<void> toggleFloatingLyrics(BuildContext context) async {
//     try {
//       // 1. Cek & Minta Izin
//       final bool status = await FlutterOverlayWindow.isPermissionGranted();
//       if (!status) {
//         final bool? result = await FlutterOverlayWindow.requestPermission();
//         if (result != true) return;
//       }

//       // 2. Cek Status Overlay
//       final bool isActive = await FlutterOverlayWindow.isActive();

//       if (isActive) {
//         // Kalau Aktif -> Tutup
//         await FlutterOverlayWindow.closeOverlay();
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Lyrics closed"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 1),
//             ),
//           );
//         }
//       } else {
//         // Kalau Mati -> Buka
//         await showOverlayNow();
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Lyrics opened"),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 1),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print("ERROR TOGGLE OVERLAY: $e");
//     }
//   }

//   // Method Khusus Buka Overlay (Static)
//   static Future<void> showOverlayNow() async {
//     try {
//       await FlutterOverlayWindow.showOverlay(
//         enableDrag: false, 
//         overlayTitle: "Lyrics",
//         overlayContent: "Lyrics Overlay",
//         flag: OverlayFlag.defaultFlag,
//         visibility: NotificationVisibility.visibilitySecret,
//         positionGravity: PositionGravity.none,
//         height: 300, 
//         width: 360,
//       );
//     } catch (e) {
//       print("Error showOverlay: $e");
//     }
//   }
// }