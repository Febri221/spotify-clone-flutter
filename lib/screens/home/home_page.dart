import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/providers/audio_provider.dart'; // Sesuaikan sama lokasi file provider lu

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('Lab Uji Coba Rekap Meraki'),
        backgroundColor: Colors.teal,
      ),
      // Kita panggil CCTV (Consumer) di tengah layar
      body: Center(
        child: Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            // Ambil data langsung dari otak Provider
            final detik = audioProvider.purePlaybackSeconds;
            final statusGembok = audioProvider.isTrueOneRound;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '⏱️ Live Tracker Stopwatch',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white70
                  ),
                ),
                const SizedBox(height: 10),
                
                // Teks Angka Detik
                Text(
                  '$detik Detik',
                  style: const TextStyle(
                    fontSize: 60, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 20),
                
                // Teks Status Gembok Putaran
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusGembok ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: statusGembok ? Colors.greenAccent : Colors.orangeAccent,
                    )
                  ),
                  child: Text(
                    statusGembok ? '🔒 Status: SAH (1 Putaran)' : '🔓 Status: Belum Sah',
                    style: TextStyle(
                      fontSize: 18,
                      color: statusGembok ? Colors.greenAccent : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}