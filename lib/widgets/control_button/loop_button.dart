import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class LoopButton extends StatelessWidget {
  const LoopButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    
    return StreamBuilder<LoopMode>(
      stream: audioProvider.player.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        IconData icon = (loopMode == LoopMode.one)
            ? Icons.repeat_one_rounded
            : Icons.repeat_rounded;
        Color color = (loopMode == LoopMode.off) ? Colors.grey : Colors.white;
        return IconButton(
          onPressed: () async {
            LoopMode newMode = LoopMode.off;
            if (loopMode == LoopMode.off) {
              newMode = LoopMode.all;
            } else if (loopMode == LoopMode.all) {
              newMode = LoopMode.one;
            }
            await audioProvider.player.setLoopMode(newMode);
            audioProvider.resetPlaybackTimer();
          },
          icon: Icon(icon, color: color, size: 25),
        );
      },
    );
  }
}
