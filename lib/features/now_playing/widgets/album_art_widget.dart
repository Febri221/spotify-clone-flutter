import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Widget ini berdiri sendiri — hanya rebuild kalau songId berubah
class AlbumArtWidget extends StatelessWidget {
  final int songId;
  final double size;

  const AlbumArtWidget({
    super.key,
    required this.songId,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: QueryArtworkWidget(
        key: ValueKey(songId), // Hanya rebuild kalau songId beda
        id: songId,
        type: ArtworkType.AUDIO,
        artworkHeight: size,
        artworkWidth: size,
        artworkFit: BoxFit.cover,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          color: Colors.grey[900],
          child: const Icon(Icons.music_note, size: 80, color: Colors.white),
        ),
      ),
    );
  }
}