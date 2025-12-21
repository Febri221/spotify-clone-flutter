import 'dart:math';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue; // Nilai posisi saat user menggeser
  bool _isDragging = false; // Status apakah user sedang menyentuh slider?

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final totalDurationMs = widget.duration.inMilliseconds.toDouble();

    // SAFETY CHECK: Kalau durasi 0 (lagu belum load), jangan render slider aktif
    if (totalDurationMs <= 0) {
      return Column(
        children: [
          const Slider(
              value: 0, onChanged: null, max: 1.0, activeColor: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("--:--", style: TextStyle(color: Colors.white70)),
                Text("--:--", style: TextStyle(color: Colors.white70))
              ],
            ),
          )
        ],
      );
    }

    // LOGIC "GHOST TOUCH":
    // Kalau _isDragging == true (user pegang), pakai nilai _dragValue.
    // Kalau _isDragging == false (dilepas), pakai nilai widget.position (dari stream).
    final currentMs = widget.position.inMilliseconds.toDouble();
    final value = min(
      _isDragging ? _dragValue! : currentMs,
      totalDurationMs,
    );

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: Colors.tealAccent,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
          ),
          child: Slider(
            min: 0.0,
            max: totalDurationMs,
            value: value.clamp(0.0, totalDurationMs),
            onChanged: (newValue) {
              setState(() {
                _isDragging = true; // PUTUS KONEKSI DARI STREAM SEMENTARA
                _dragValue = newValue;
              });
            },
            onChangeEnd: (newValue) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: newValue.round()));
              }
              // TRICK PENTING:
              // Jangan langsung set false. Kasih waktu 200ms buat audio engine "lompat".
              // Ini mencegah slider mental balik ke posisi lama sebelum posisi baru ready.
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() {
                    _isDragging = false; // SAMBUNG KONEKSI STREAM LAGI
                    _dragValue = null;
                  });
                }
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(milliseconds: value.round())),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _formatDuration(widget.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}