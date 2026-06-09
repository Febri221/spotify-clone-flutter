import 'dart:math';
import 'package:flutter/material.dart';

class MiniSeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;

  const MiniSeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.onChangeEnd,
  });

  @override
  State<MiniSeekBar> createState() => _MiniSeekBarState();
}

class _MiniSeekBarState extends State<MiniSeekBar> {
  double? _dragValue;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final totalDurationMs = widget.duration.inMilliseconds.toDouble();

    if (totalDurationMs <= 0) {
      return const Slider(value: 0, onChanged: null, max: 1.0, activeColor: Colors.grey);
    }

    final currentMs = widget.position.inMilliseconds.toDouble();
    final value = min(_isDragging ? _dragValue! : currentMs, totalDurationMs);

    // LANGSUNG RETURN SLIDERNYA AJA (TANPA COLUMN & TEKS)
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2, // Tipis biar estetik di mini player
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3), 
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        thumbColor: Colors.white,
      ),
      child: Slider(
        min: 0.0,
        max: totalDurationMs,
        value: value.clamp(0.0, totalDurationMs),
        onChanged: (newValue) {
          setState(() {
            _isDragging = true;
            _dragValue = newValue;
          });
        },
        onChangeEnd: (newValue) {
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(Duration(milliseconds: newValue.round()));
          }
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            }
          });
        },
      ),
    );
  }
}