import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/features/library/widgets/library_item.dart';
import 'package:flutter/material.dart';

class LibraryViewModel with ChangeNotifier {
  static const List<String> systemFolders = [
    'Downloads',
    'Liked Songs',
    'New Episodes',
    'Your Episodes',
  ];

  // Bersihkan nama playlist dari unique ID hive (misal: "Galau__123" → "Galau")
  String cleanTitle(String rawTitle) {
    return rawTitle.contains('__') ? rawTitle.split('__')[0] : rawTitle;
  }

  bool isSystemFolder(String title) => systemFolders.contains(cleanTitle(title));

  // Build item sistem (Liked Songs, Downloads, dll)
  List<LibraryItem> buildSystemItems({
    required List<dynamic> allSongs,
    required List<dynamic> favoriteIds,
  }) {
    final likedCount = allSongs.where((s) => favoriteIds.contains(s.id)).length;

    return [
      LibraryItem(
        title: 'Liked Songs',
        containerGradient: LinearGradient(
          colors: [Colors.deepPurpleAccent.shade400, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        iconInContainer: const Icon(Icons.favorite, size: 30, color: Colors.white),
        titleColor: Colors.white,
        subtitle: 'Playlists • $likedCount songs',
        containerColor: null,
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'New Episodes',
        iconInContainer: const Icon(Icons.notifications, size: 30, color: Color(0xFF1ED760)),
        titleColor: Colors.white,
        subtitle: 'Updated Jan 25, 2025',
        containerColor: const Color(0xFF5E3DB3),
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'Your Episodes',
        iconInContainer: const Icon(Icons.bookmark, size: 30, color: Color(0xFF1ED760)),
        titleColor: Colors.white,
        subtitle: 'Playlists • Saved & downloaded episodes',
        containerColor: Colors.green.shade900,
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'Downloads',
        iconInContainer: const Icon(Icons.download, size: 30, color: Color(0xFF1ED760)),
        titleColor: Colors.white,
        subtitle: 'Playlists • ${allSongs.length} songs',
        containerColor: Colors.green.shade900,
        category: 'Downloads',
      ),
    ];
  }

  // Build item dari Hive
  List<LibraryItem> buildHiveItems(Box box, Set<String> pinnedPlaylists) {
    return box.keys.cast<String>().map((key) {
      final songs = box.get(key, defaultValue: []) as List;
      return LibraryItem(
        title: key,
        iconInContainer: const Icon(Icons.music_note, color: Colors.white),
        titleColor: Colors.white,
        subtitle: 'Playlist • ${songs.length} songs',
        containerColor: Colors.grey[900],
        category: 'Playlists',
        isPinned: pinnedPlaylists.contains(key),
      );
    }).toList();
  }

  // Filter & sort semua item
  List<LibraryItem> filterAndSort({
    required List<LibraryItem> systemItems,
    required List<LibraryItem> hiveItems,
    required String selectedCategory,
  }) {
    final all = [...systemItems, ...hiveItems.reversed];

    List<LibraryItem> filtered;
    if (selectedCategory == 'All') {
      filtered = all;
    } else if (selectedCategory == 'Playlists') {
      filtered = all.where((item) => item.category == 'Playlists').toList();
    } else {
      filtered = all.where((item) => item.category == selectedCategory).toList();
    }

    // Pin di atas
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return filtered;
  }

  // Ambil lagu dari Hive playlist
  List<SongModel> getSongsFromHive(String key) {
    final box = Hive.box('Playlists');
    final raw = box.get(key, defaultValue: []) as List;

    return raw.map((data) {
      if (data is SongModel) return data;
      if (data is Map) return SongModel(data.cast<String, dynamic>());
      return null;
    }).whereType<SongModel>().toList();
  }

  // Rename playlist di Hive
  Future<void> renamePlaylist(String oldKey, String newName) async {
    final box = Hive.box('Playlists');
    final songs = box.get(oldKey, defaultValue: []);
    final newKey = '${newName}__${DateTime.now().millisecondsSinceEpoch}';

    await box.put(newKey, songs);
    await box.delete(oldKey);
  }

  // Buat playlist baru
  Future<void> createPlaylist(String title) async {
    if (title.trim().isEmpty) return;

    if (!Hive.isBoxOpen('Playlists')) await Hive.openBox('Playlists');
    final box = Hive.box('Playlists');
    final key = '${title}__${DateTime.now().millisecondsSinceEpoch}';
    await box.put(key, []);
  }
}