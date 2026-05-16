import 'package:flutter/material.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class ShuffleControll extends StatelessWidget {
  const ShuffleControll({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    return StreamBuilder<bool>(
      stream: audioProvider.player.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final shuffleEnabled = snapshot.data ?? false;
        return IconButton(
          onPressed: () async {
            final enable = !shuffleEnabled;
            if (enable) await audioProvider.player.shuffle();
            await audioProvider.player.setShuffleModeEnabled(enable);
          },
          icon: Icon(
            Icons.shuffle,
            color: shuffleEnabled ? Colors.white : Colors.grey,
            size: 25,
          ),
        );
      },
    );
  }
}
