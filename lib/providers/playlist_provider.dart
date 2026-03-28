import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlaylistProvider with ChangeNotifier {
  List<dynamic> _favoriteIds = [];

  List<dynamic> get favoriteIds => _favoriteIds;

  PlaylistProvider() {
    _loadFavorites();
  }

  void _loadFavorites() {
    final box = Hive.box('Favorites');

    _favoriteIds = box.keys.toList();
    notifyListeners();
  }

  bool toggleFavorite(int songId) {
    final box = Hive.box('Favorites');
    bool isLikedNow = false;

    if (box.containsKey(songId)) {
      
      box.delete(songId);
      _favoriteIds.remove(songId);
      isLikedNow = false;
    } else {
      box.put(songId, true);
      _favoriteIds.add(songId);
      isLikedNow = true;
    }
    notifyListeners();
    return isLikedNow;
  }

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

}