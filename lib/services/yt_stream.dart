import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class YtStreamSource extends StreamAudioSource {
  final AudioOnlyStreamInfo streamInfo;
  final int maxRetries;
  final Duration retryDelay;

  final http.Client _httpClient = http.Client();
  static const int _chunkSize = 64 * 1024;

  YtStreamSource(
    this.streamInfo, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    super.tag,
  });

  Uri get _streamUri => streamInfo.url;
  int get _totalBytes => streamInfo.size.totalBytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int rangeStart = start ?? 0;
    final int rangeEnd = (end != null) ? end - 1 : _totalBytes - 1;
    final int contentLength = rangeEnd - rangeStart + 1;

    return StreamAudioResponse(
      sourceLength: _totalBytes,
      contentLength: contentLength,
      offset: rangeStart,
      stream: _fetchWithRetry(rangeStart, rangeEnd),
      contentType: 'audio/mp4',
    );
  }

  Stream<List<int>> _fetchWithRetry(int start, int end) async* {
    int currentByte = start;
    int attempt = 0;

    while (true) {
      try {
        await for (final chunk in _openStream(currentByte, end)) {
          yield chunk;
          currentByte += chunk.length;
        }
        return;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          throw AudioLoadException(
            'Gagal setelah $maxRetries retry (byte $currentByte): $e',
          );
        }
        final delay = retryDelay * (1 << (attempt - 1));
        await Future.delayed(delay);
      }
    }
  }

  Stream<List<int>> _openStream(int start, int end) async* {
    final request = http.Request('GET', _streamUri);

    request.headers.addAll({
      'Range': 'bytes=$start-$end',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/125.0.0.0 Safari/537.36',
      'Accept': '*/*',
      'Accept-Encoding': 'identity',
      'Origin': 'https://www.youtube.com',
      'Referer': 'https://www.youtube.com/',
      'Sec-Fetch-Dest': 'audio',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
    });

    final streamedResponse = await _httpClient
        .send(request)
        .timeout(const Duration(seconds: 20));

    if (streamedResponse.statusCode == 403) {
      throw AudioLoadException('403 — URL expired, refresh manifest.');
    }
    if (streamedResponse.statusCode == 429) {
      throw AudioLoadException('429 — Rate limited, tunggu sebentar.');
    }
    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 206) {
      throw AudioLoadException(
        'HTTP ${streamedResponse.statusCode} dari YouTube CDN.',
      );
    }

    final buffer = <int>[];
    await for (final bytes in streamedResponse.stream) {
      buffer.addAll(bytes);
      while (buffer.length >= _chunkSize) {
        yield List<int>.from(buffer.sublist(0, _chunkSize));
        buffer.removeRange(0, _chunkSize);
      }
    }
    if (buffer.isNotEmpty) {
      yield List<int>.from(buffer);
    }
  }

  // Bukan override, method biasa untuk tutup client dari luar
  void closeClient() {
    _httpClient.close();
  }
}

class AudioLoadException implements Exception {
  final String message;
  const AudioLoadException(this.message);

  @override
  String toString() => 'AudioLoadException: $message';
}