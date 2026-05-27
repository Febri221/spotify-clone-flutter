import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percobaan/providers/audio_provider.dart'; 
import 'package:percobaan/models/rekap_model.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mesin Sakti lu (Tetep sama persis kayak sebelumnya, gak ada yang diubah)
  List<Map<String, dynamic>> _prosesDataRekap(Iterable<DailyLog> rawData, String mode) {
    final sekarang = DateTime.now();
    Map<String, Map<String, dynamic>> rekapMap = {};

    for (var lagu in rawData) {
      bool lolosSaringan = false;
      if (mode == 'Harian') {
        lolosSaringan = (lagu.playDate.year == sekarang.year &&
                         lagu.playDate.month == sekarang.month &&
                         lagu.playDate.day == sekarang.day);
      } else if (mode == 'Mingguan') {
        lolosSaringan = sekarang.difference(lagu.playDate).inDays <= 7;
      } else if (mode == 'Bulanan') {
        lolosSaringan = (lagu.playDate.year == sekarang.year &&
                         lagu.playDate.month == sekarang.month);
      } else if (mode == 'Semua') { 
        lolosSaringan = true;
      }

      if (lolosSaringan) {
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
    }
    final listFinal = rekapMap.values.toList();
    listFinal.sort((a, b) => b['jumlah'].compareTo(a['jumlah'])); 
    return listFinal;
  }

  // ========================================================
  // 🔥 WIDGET PEMBUAT ISI TAB (Biar kode gak diulang-ulang)
  // ========================================================
  Widget _buildTabContent(Iterable<DailyLog> rawData, String mode) {
    // 1. Ambil data yang udah disaring sama mesin
    final listRekap = _prosesDataRekap(rawData, mode);

    // 2. LOGIKA SUM (Ngitung total putaran semua lagu)
    int totalSemuaPutaran = 0;
    for (var data in listRekap) {
      totalSemuaPutaran += data['jumlah'] as int;
    }

    if (listRekap.isEmpty) {
      return Center(
        child: Text(
          'Belum ada lagu di periode $mode ini.',
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        // --- HEADER TOTAL PUTARAN ---
        Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total $mode", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  const Text("Lagu Diputar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                "$totalSemuaPutaran x", // INI HASIL SUM-NYA!
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        // --- LIST LAGU ---
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: listRekap.length,
            itemBuilder: (context, index) {
              final dataLagu = listRekap[index];
              return Card(
                color: Colors.grey[800],
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Text(dataLagu['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(dataLagu['artist'], style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.tealAccent)
                    ),
                    child: Text('${dataLagu['jumlah']}x', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bungkus pakai DefaultTabController buat ngaktifin efek geser-geser (swipe)
    return DefaultTabController(
      length: 3, // Ada 3 Tab
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Rekap Meraki'),
          backgroundColor: Colors.teal,
          actions: [
            // Tombol sapu jagat buat bersih-bersih data pas testing
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: () {
                Hive.box<DailyLog>('daily_logs').clear();
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Harian'),
              Tab(text: 'Mingguan'),
              Tab(text: 'Bulanan'),
            ],
          ),
        ),
        body: ValueListenableBuilder<Box<DailyLog>>(
          // CCTV memantau database dari atas, biar semua tab otomatis ke-update kalau ada lagu baru
          valueListenable: Hive.box<DailyLog>('daily_logs').listenable(),
          builder: (context, box, _) {
            final rawData = box.values;
            
            return TabBarView(
              children: [
                // Isi Tab 1: Panggil UI Harian
                _buildTabContent(rawData, 'Harian'),
                // Isi Tab 2: Panggil UI Mingguan
                _buildTabContent(rawData, 'Mingguan'),
                // Isi Tab 3: Panggil UI Bulanan
                _buildTabContent(rawData, 'Bulanan'),
              ],
            );
          },
        ),
      ),
    );
  }
}