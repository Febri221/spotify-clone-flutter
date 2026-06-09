import 'package:flutter/material.dart';
import 'package:percobaan/data/services/favorites_service.dart';

class PlaylistViewModel with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  List<dynamic> _favoriteIds = [];
  List<dynamic> get favoriteIds => _favoriteIds;

  PlaylistViewModel() {
    _favoriteIds = _favoritesService.loadFavoriteIds();
  }

  bool toggleFavorite(int songId) {
    final isLikedNow = _favoritesService.toggleFavorite(songId);

    if (isLikedNow) {
      _favoriteIds.add(songId);
    } else {
      _favoriteIds.remove(songId);
    }

    notifyListeners();
    return isLikedNow;
  }

  bool isFavorite(int songId) => _favoritesService.isFavorite(songId);
}