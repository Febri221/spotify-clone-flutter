import 'package:flutter/material.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class PreviousControll extends StatelessWidget {
  const PreviousControll({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    
    return IconButton(
      onPressed: () async {
        await audioProvider.player.seekToPrevious();
        audioProvider.resume(); // Pastikan resume
      },
      icon: const Icon(
        Icons.skip_previous_rounded,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}
