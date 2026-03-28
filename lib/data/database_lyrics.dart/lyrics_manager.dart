import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:flutter/foundation.dart'; // Buat debugPrint

class LyricsManager {

  // Fungsi ini sekarang jadi 'Detektif' yang pintar
  static Future<String> getLyrics(String audioArtist, String audioTitle) async {
    
    // 1. SIAPKAN BAHAN PENCARIAN (DARI MP3)
    // Gabungkan Artis & Judul dari MP3, lalu bersihkan simbol aneh.
    // Contoh MP3: "Hindia - Cincin (Official Lyric Video)"
    // Hasil: "hindia cincin official lyric video"
    String searchInput = "$audioArtist $audioTitle".toLowerCase();
    searchInput = searchInput.replaceAll(RegExp(r'[^a-z0-9 ]'), ''); // Hapus simbol kayak [] () -

    try {
      // 2. AMBIL DAFTAR SEMUA FILE LIRIK DI FOLDER ASSETS
      // Kita "ngintip" isi folder assets/lyrics/ lewat AssetManifest
      final AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      // Ambil file yang akhiran .lrc aja
      final List<String> lrcFiles = assetManifest.listAssets()
          .where((String key) => key.contains('assets/lyrics/') && key.endsWith('.lrc'))
          .toList();

      // 3. LOGIKA DETEKTIF (LOOPING PINTAR)
      String? bestMatchFile;

      // Kita cek satu-satu file lirik yang lu punya di folder
      for (var filePath in lrcFiles) {
        // Contoh filePath: "assets/lyrics/hindia_cincin.lrc"
        
        // Kita ambil nama filenya doang & bersihin
        // Jadi: "hindia cincin"
        String filenameClean = filePath.split('/').last; // Ambil yang paling belakang
        filenameClean = filenameClean.replaceAll('.lrc', ''); // Buang .lrc
        filenameClean = filenameClean.replaceAll('_', ' ');   // Ganti _ jadi spasi

        // Pecah jadi kata-kata kunci: ["hindia", "cincin"]
        List<String> fileKeywords = filenameClean.split(' ');

        // --- PENGECEKAN AJAIB DI SINI ---
        // Kita cek: Apakah SEMUA kata di nama file gua, ADA di Judul MP3?
        
        bool isMatch = true;
        for (var keyword in fileKeywords) {
          // Kalau ada satu kata aja yang gak ketemu, berarti bukan ini lagunya
          if (!searchInput.contains(keyword)) {
            isMatch = false;
            break;
          }
        }

        // Kalau SEMUA kata ketemu, berarti INI LIRIKNYA!
        if (isMatch) {
          bestMatchFile = filePath;
          break; // Stop nyari, udah ketemu
        }
      }

      // 4. EKSEKUSI BACA FILE
      if (bestMatchFile != null) {
        debugPrint("Lirik Ditemukan: $bestMatchFile untuk input: $searchInput");
        return await rootBundle.loadString(bestMatchFile);
      } else {
        debugPrint("Lirik GAK ketemu buat: $searchInput");
        return "";
      }

    } catch (e) {
      debugPrint("Error nyari lirik: $e");
      return "";
    }
  }

  
  static List<Map<String, dynamic>> parseLrc(String lrcContent) {
    List<Map<String, dynamic>> lyrics = [];
    // Regex buat nyari pola waktu [00:12.34]
    final RegExp regex = RegExp(r"^\[(\d{2}):(\d{2})\.(\d{2})\](.*)");

    List<String> lines = lrcContent.split('\n');

    for (var line in lines) {
      line = line.trim();
      final match = regex.firstMatch(line);
      
      if (match != null) {
        // Ambil menit, detik, milidetik
        final int minutes = int.parse(match.group(1)!);
        final int seconds = int.parse(match.group(2)!);
        final int milliseconds = int.parse(match.group(3)!);
        final String text = match.group(4)?.trim() ?? "";

        // Hitung total durasi dalam milidetik
        final Duration time = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds * 10, // .xx di lirik itu biasanya puluhan ms
        );

        lyrics.add({
          "time": time.inMilliseconds, // Simpan angka mentahnya
          "text": text,
        });
      }
    }
    return lyrics;
  }
}