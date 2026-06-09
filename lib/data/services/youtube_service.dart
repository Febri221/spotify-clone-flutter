import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtSearchResult {
  final String videoId;
  final String title;
  final String artist;
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

  Future<List<YtSearchResult>> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _yt.search.search('$query audio');
      return results
          .whereType<Video>()
          .take(limit)
          .map((video) => YtSearchResult(
                videoId: video.id.value,
                title: video.title,
                artist: video.author,
                thumbnailUrl:
                    'https://i.ytimg.com/vi/${video.id.value}/hqdefault.jpg',
                duration: video.duration,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() => _yt.close();
}