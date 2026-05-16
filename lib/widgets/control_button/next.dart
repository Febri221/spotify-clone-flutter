import 'package:flutter/material.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class NextControll extends StatelessWidget {
  const NextControll({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    return IconButton(
      onPressed: () async {
        await audioProvider.player.seekToNext();
        audioProvider.resume();
      },
      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 50),
    );
  }
}
