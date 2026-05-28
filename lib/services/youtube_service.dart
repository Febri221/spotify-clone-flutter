import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Model sederhana untuk hasil pencarian YouTube
class YtSearchResult {
  final String videoId;
  final String title;
  final String artist; // channel name
  final String thumbnailUrl;
  final Duration? duration;

  const YtSearchResult({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.duration,
  });
}

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Cari lagu di YouTube, return max [limit] hasil.
  /// Query otomatis ditambah "audio" agar hasil lebih relevan untuk musik.
  Future<List<YtSearchResult>> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _yt.search.search('$query audio');

      return results
          .whereType<Video>() // filter hanya Video, bukan Playlist/Channel
          .take(limit)
          .map(
            (video) => YtSearchResult(
              videoId: video.id.value,
              title: video.title,
              artist: video.author,
              thumbnailUrl:
                  'https://i.ytimg.com/vi/${video.id.value}/hqdefault.jpg',
              duration: video.duration,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() => _yt.close();
}