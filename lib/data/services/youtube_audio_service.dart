import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:percobaan/core/network/yt_stream.dart';

class YoutubeAudioService {
  final YoutubeExplode _yt = YoutubeExplode();
  final Map<String, AudioOnlyStreamInfo> _manifestCache = {};

  Future<AudioOnlyStreamInfo> getStreamInfo(String videoId) async {
    if (_manifestCache.containsKey(videoId)) {
      return _manifestCache[videoId]!;
    }

    final manifest = await _yt.videos.streamsClient
        .getManifest(
          videoId,
          ytClients: [
            YoutubeApiClient.androidVr,
            YoutubeApiClient.ios,
            YoutubeApiClient.android,
          ],
        )
        .timeout(const Duration(seconds: 30));

    final audioStreams = manifest.audioOnly.toList();
    final mp4Streams = audioStreams
        .where((s) => s.container.name == 'mp4' || s.container.name == 'm4a')
        .toList();
    final candidates = mp4Streams.isNotEmpty ? mp4Streams : audioStreams;
    candidates.sort(
      (a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
    );

    final selected = candidates.first;
    _manifestCache[videoId] = selected;
    return selected;
  }

  Future<YtStreamSource?> createStreamSource({
    required String videoId,
    required String title,
    required String artist,
    required String thumbnailUrl,
  }) async {
    try {
      final streamInfo = await getStreamInfo(videoId);
      final mediaItem = MediaItem(
        id: videoId,
        title: title,
        artist: artist,
        artUri: Uri.parse(thumbnailUrl),
      );
      return YtStreamSource(
        streamInfo,
        maxRetries: 3,
        retryDelay: const Duration(seconds: 2),
        tag: mediaItem,
      );
    } catch (e) {
      return null;
    }
  }

  // Prefetch manifest di background tanpa throw error
  void prefetch(String videoId) {
    Future.delayed(const Duration(seconds: 2), () {
      getStreamInfo(videoId).catchError((_) {});
    });
  }

  Future<List<Map<String, String>>> getRelatedVideos(
    String videoId,
  ) async {
    try {
      final video = await _yt.videos.get(videoId);
      final related = await _yt.videos.getRelatedVideos(video);
      if (related == null || related.isEmpty) return [];

      return related.map((v) {
        final thumb = 'https://i.ytimg.com/vi/${v.id.value}/hqdefault.jpg';
        return {
          'videoId': v.id.value,
          'title': v.title,
          'artist': v.author,
          'thumbnailUrl': thumb,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() => _yt.close();
}