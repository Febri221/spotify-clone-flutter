import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percobaan/providers/audio_provider.dart'; 
import 'package:percobaan/models/rekap_model.dart'; // Pastikan path ini benar

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
      body: Column(
        children: [
          // ==========================================
          // BAGIAN ATAS: LIVE TRACKER (CONSUMER)
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.grey[900], // Beda warna dikit biar misah
            child: Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                final detik = audioProvider.purePlaybackSeconds;
                final statusGembok = audioProvider.isTrueOneRound;

                return Column(
                  children: [
                    const Text(
                      '⏱️ Live Tracker Stopwatch',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white70
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$detik Detik',
                      style: const TextStyle(
                        fontSize: 50, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 15),
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
                          fontSize: 16,
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

          // Garis Pemisah
          const Divider(height: 1, color: Colors.teal),

          // ==========================================
          // BAGIAN BAWAH: CCTV DATABASE HIVE (LIST LAGU)
          // ==========================================
          // Expanded wajib dipakai biar ListView gak error kepanjangan
          Expanded(
            child: ValueListenableBuilder<Box<DailyLog>>(
              valueListenable: Hive.box<DailyLog>('daily_logs').listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada lagu yang diputar 1 menit penuh. \nCoba play lagu sekarang!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                Map<String, Map <String, dynamic>> rekapMap = {};

                for (var lagu in box.values) {
                  if (rekapMap.containsKey(lagu.songId)) {
                    rekapMap[lagu.songId]!['jumlah'] += 1;
                  } else {
                    rekapMap[lagu.songId] = {
                      'title': lagu.title,
                      'artist': lagu.artist,
                      'jumlah': 1,
                    };
                  }
                }
                // Reverse biar lagu yang baru masuk ada di paling atas
                final listRekap = rekapMap.values.toList();

                listRekap.sort((a, b) => b['jumlah'].compareTo(a['jumlah']));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: listRekap.length,
                  itemBuilder: (context, index) {
                    final dataLagu = listRekap[index];
                    
                
                   
                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.music_note, color: Colors.white),
                        ),
                        title: Text(
                          dataLagu['title'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          dataLagu['artist'], 
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.tealAccent)
                          ),
                          child: Text(
                            '${dataLagu['jumlah']}x', // Nampilin jumlah 1x, 2x, 3x, dst
                            style: const TextStyle(
                              color: Colors.tealAccent, 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ),
                    ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}