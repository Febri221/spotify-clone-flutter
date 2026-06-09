import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percobaan/core/constants/app_constants.dart';
import 'package:percobaan/data/models/rekap_model.dart';
import 'package:percobaan/features/home/viewmodel/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _viewModel = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Rekap Meraki'),
          backgroundColor: Colors.teal,
         
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
          valueListenable:
              Hive.box<DailyLog>(AppConstants.dailyLogsBox).listenable(),
          builder: (context, box, _) {
            final rawData = box.values;
            return TabBarView(
              children: [
                _buildTabContent(rawData, 'Harian'),
                _buildTabContent(rawData, 'Mingguan'),
                _buildTabContent(rawData, 'Bulanan'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(Iterable<DailyLog> rawData, String mode) {
    final listRekap = _viewModel.prosesDataRekap(rawData, mode);
    final totalPutaran = _viewModel.hitungTotalPutaran(listRekap);

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
        _buildHeaderCard(mode, totalPutaran),
        Expanded(child: _buildSongList(listRekap)),
      ],
    );
  }

  Widget _buildHeaderCard(String mode, int totalPutaran) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total $mode',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              const Text(
                'Lagu Diputar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '${totalPutaran}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(List<Map<String, dynamic>> listRekap) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: listRekap.length,
      itemBuilder: (context, index) {
        final lagu = listRekap[index];
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.music_note, color: Colors.white),
            ),
            title: Text(
              lagu['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              lagu['artist'],
              style: const TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.tealAccent),
              ),
              child: Text(
                '${lagu['jumlah']}x',
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
  }
}