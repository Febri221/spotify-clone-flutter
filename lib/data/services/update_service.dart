import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart'; // <--- PAKE INI SEKARANG

class UpdateService {
  // Pastikan link ini mengarah ke RAW JSON (bukan halaman web GitHub)
  final String jsonUrl = "https://gist.githubusercontent.com/Febri221/515c7ff2170b35c3eb482de3cbe93d22/raw/gistfile1.txt";

  Future<void> checkForUpdate(BuildContext context) async {
    
    try {
      // 1. Cek Versi HP
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // 2. Cek Versi GitHub
      final response = await http.get(Uri.parse(jsonUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['version'];
        String apkUrl = data['url'];
        String changelog = data['changelog'];

        // Debugging di console
        print("Versi HP: $currentVersion | Versi GitHub: $latestVersion");

        // Logic sederhana: Kalau beda, berarti update
        if (currentVersion != latestVersion) {
          if (context.mounted) {
             _showUpdateDialog(context, latestVersion, changelog, apkUrl);
          }
        } else {
          print("Aplikasi sudah paling baru.");
        }
      }
    } catch (e) {
      print("Error cek update: $e");
    }
  }

  void _showUpdateDialog(BuildContext context, String version, String log, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E), // Warna Dark Mode
          title: Text("Update Tersedia! v$version", style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Text(
              log,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nanti Aja", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                _jalankanUpdate(context, url);   // Eksekusi download
              },
              child: const Text("Update Sekarang", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // FUNGSI UPDATE BARU PAKE OTA_UPDATE
  void _jalankanUpdate(BuildContext context, String url) {
  // 1. Setup Notifier
  // 'null' artinya lagi connecting (Buffer). Kalo ada angka, berarti lagi download.
  ValueNotifier<String?> progressNotifier = ValueNotifier<String?>(null);

  // 2. TAMPILKAN DIALOG (Timpa dialog lama, jangan di-pop dulu)
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false, // Biar gak bisa di-back
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: ValueListenableBuilder<String?>(
            valueListenable: progressNotifier,
            builder: (context, value, child) {
              // LOGIKA BUFFER:
              // Kalo value masih null (belum dapet % dari server), munculin Loading Muter
              bool isBuffering = value == null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // Judul Status
                  Text(
                    isBuffering ? "Menghubungkan..." : "Mengunduh Update",
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Visualisasi: Spinner vs Progress Bar
                  if (isBuffering)
                    const CircularProgressIndicator(color: Colors.blueAccent) // Buffer Muter
                  else
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: double.parse(value) / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$value%", // Angka Persen
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      );
    },
  );

  // 3. EKSEKUSI DOWNLOAD
  try {
    OtaUpdate().execute(
      url,
      destinationFilename: 'meraki_update_v2.apk',
    ).listen(
      (OtaEvent event) {
        // Update status download
        if (event.value != null) {
          progressNotifier.value = event.value; // Isi persenan, Buffer ilang otomatis
        }

        // Kalo selesai atau error
        if (event.status == OtaStatus.INSTALLING) {
           // Download kelar, tutup loading, Android bakal ambil alih buat install
           Navigator.pop(context); 
        } else if (event.status == OtaStatus.INTERNAL_ERROR || event.status == OtaStatus.DOWNLOAD_ERROR) {
           Navigator.pop(context);
           print("Gagal download: ${event.status}");
        }
      },
    );
  } catch (e) {
    Navigator.pop(context);
    print('Error Exception: $e');
  }
}
}