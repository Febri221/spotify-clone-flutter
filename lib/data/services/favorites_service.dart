import 'package:hive_flutter/hive_flutter.dart';
import 'package:percobaan/core/constants/app_constants.dart';

class FavoritesService {
  Box get _box => Hive.box(AppConstants.favoritesBox);

  List<dynamic> loadFavoriteIds() {
    return _box.keys.toList();
  }

  // Return true kalau sekarang jadi favorit, false kalau dihapus
  bool toggleFavorite(int songId) {
    if (_box.containsKey(songId)) {
      _box.delete(songId);
      return false;
    } else {
      _box.put(songId, true);
      return true;
    }
  }

  bool isFavorite(int songId) => _box.containsKey(songId);
}