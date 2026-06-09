import 'package:flutter/material.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';
import 'package:provider/provider.dart';

class NextControll extends StatelessWidget {
  const NextControll({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioViewModel>();
    return IconButton(
      onPressed: () async {
        await audioProvider.player.seekToNext();
        audioProvider.resume();
        
      },
      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 50),
    );
  }
}
