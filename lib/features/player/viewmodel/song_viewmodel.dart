import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/core/constants/app_constants.dart';
import 'package:percobaan/data/services/local_audio_service.dart';

class SongViewModel with ChangeNotifier {
  final LocalAudioService _localAudioService = LocalAudioService();

  List<SongModel> _songs = [];
  List<SongModel> _recentSearches = [];
  bool _isLoading = true;

  List<SongModel> get songs => _songs;
  List<SongModel> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading;

  Future<void> fetchSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _songs = await _localAudioService.fetchSongs();
    } catch (e) {
      debugPrint('Gagal fetch lagu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToRecentSearch(SongModel song) {
    _recentSearches.removeWhere((s) => s.id == song.id);
    _recentSearches.insert(0, song);

    if (_recentSearches.length > AppConstants.maxRecentSearchItems) {
      _recentSearches.removeLast();
    }

    notifyListeners();
  }
}