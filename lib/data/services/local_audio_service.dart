import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/data/services/permission_service.dart';


class LocalAudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final PermissionService _permissionService = PermissionService();

  Future<List<SongModel>> fetchSongs() async {
    final hasPermission = await _permissionService.requestAudioPermission();
    if (!hasPermission) return [];

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return _filterSongs(songs);
  }

  List<SongModel> _filterSongs(List<SongModel> songs) {
    return songs.where((song) {
      final name = song.displayName.toLowerCase();
      final duration = song.duration ?? 0;
      final path = song.data.toLowerCase();

      return name.endsWith('.mp3') &&
          duration > 4500 &&
          !path.contains('whatsapp');
    }).toList();
  }
}