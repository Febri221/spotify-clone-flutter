import 'package:percobaan/data/database_lyrics.dart/lyrics_manager.dart';

class LyricsService {
  // Return data siap pakai buat overlay
  Future<List<Map<String, dynamic>>> getLyricsForOverlay({
    required String artist,
    required String title,
  }) async {
    final rawLrc = await LyricsManager.getLyrics(artist, title);

    if (rawLrc.isNotEmpty) {
      return LyricsManager.parseLrc(rawLrc);
    }

    return [
      {'time': 0, 'text': 'Lirik belum tersedia'},
      {'time': 5000, 'text': 'Request yee kalo mau :)'},
    ];
  }
}