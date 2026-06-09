import 'package:percobaan/data/models/rekap_model.dart';

class HomeViewModel {
  // Filter & agregasi data log berdasarkan mode waktu
  List<Map<String, dynamic>> prosesDataRekap(
    Iterable<DailyLog> rawData,
    String mode,
  ) {
    final sekarang = DateTime.now();
    final Map<String, Map<String, dynamic>> rekapMap = {};

    for (final lagu in rawData) {
      if (!_lolosFilter(lagu, mode, sekarang)) continue;

      if (rekapMap.containsKey(lagu.songId)) {
        rekapMap[lagu.songId]!['jumlah'] += 1;
      } else {
        rekapMap[lagu.songId] = {
          'title': lagu.title,
          'artist': lagu.artist,
          'jumlah': 1,
        };
      }
    }

    final result = rekapMap.values.toList();
    result.sort((a, b) => b['jumlah'].compareTo(a['jumlah']));
    return result;
  }

  int hitungTotalPutaran(List<Map<String, dynamic>> listRekap) {
    return listRekap.fold(0, (sum, item) => sum + (item['jumlah'] as int));
  }

  bool _lolosFilter(DailyLog lagu, String mode, DateTime sekarang) {
    switch (mode) {
      case 'Harian':
        return lagu.playDate.year == sekarang.year &&
            lagu.playDate.month == sekarang.month &&
            lagu.playDate.day == sekarang.day;
      case 'Mingguan':
        return sekarang.difference(lagu.playDate).inDays <= 7;
      case 'Bulanan':
        return lagu.playDate.year == sekarang.year &&
            lagu.playDate.month == sekarang.month;
      case 'Semua':
        return true;
      default:
        return false;
    }
  }
}