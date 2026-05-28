import 'dart:io';
 
/// Factory untuk membuat HTTP client dengan header anti-403.
/// Header ini meniru browser Chrome biasa agar tidak dikenali sebagai bot.
class HttpClientFactory {
  static HttpClient create() {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 30);
    return client;
  }
 
  /// Header wajib untuk menembus 403 Forbidden dari server Google/YouTube.
  /// Tanpa header ini, request akan ditolak atau di-rate limit.
  static Map<String, String> get antiBlockHeaders => {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/125.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'identity', // ← PENTING: jangan gzip, biar byte range akurat
        'Origin': 'https://www.youtube.com',
        'Referer': 'https://www.youtube.com/',
        'Sec-Fetch-Dest': 'audio',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site',
        'Connection': 'keep-alive',
      };
}