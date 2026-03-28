import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:marquee/marquee.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:provider/provider.dart';
// Pastikan path import ini sesuai dengan folder kamu (services vs servicess)
//import 'package:percobaan/services/audio_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistTitle;
  final List<SongModel> songs;
  final String? playlistKey;

  const PlaylistDetailPage({
    super.key,
    required this.playlistTitle,
    required this.songs,
    this.playlistKey,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  // HAPUS: final AudioPlayer _player = AudioPlayer();
  // Kita gak butuh player lokal, kita pake AudioManager.

  // Data lagu lokal buat dihapus/dimainkan
  late List<SongModel> _currentSongs;

  @override
  void initState() {
    super.initState();
    _currentSongs = List.from(widget.songs);

    searchDataSong();
  }

  @override
  void dispose() {
    // HAPUS: _player.dispose();
    // Jangan dispose player global di sini, nanti musik mati pas back.
    super.dispose();
  }

    Future<void> searchDataSong() async {
    //ambil data dari API
    final url = Uri.parse('https://jann-undeclaiming-unrhythmically.ngrok-free.dev/api/lagu');

    
    //response dari API
    try{
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List dataLagu = json.decode(response.body);
        print('Mantap bro $dataLagu');

        List<SongModel> songFromServer = dataLagu.map((item) {
          return SongModel ({
            "_id":item['id'],
            "title":item['judul'],
            "artist":item['artis'], "_data":item['url_lagu'],
            "duration": 0,
          });
        }).toList();

        setState(() {
          _currentSongs = songFromServer;
        });
        
      } else {
        print('Duh gagal ngambil data ${response.statusCode}');
      }
    } catch (e) {
      print('Dapurnya kacau $e');
    }
  }

  // --- LOGIC AUDIO (FIXED) ---
  void playSong(int index) async {
    // Panggil fungsi play dari AudioManager
    // Fungsi ini di AudioManager kamu sudah otomatis set source, set duration, dan play.
    await context.read<AudioProvider>().playPlaylist(_currentSongs, index);

    // Update UI biar mini player muncul
    // AudioManager().isPlayerExpanded.value = true;
    context.read<AudioProvider>().togglePlayerExpanded();
  }


  void _removeSong(int index) {
    setState(() {
      _currentSongs.removeAt(index);
    });

    // Update ke Hive jika ini playlist user (bukan Downloads/System)
    if (widget.playlistKey != null) {
      var box = Hive.box('Playlists');
      
      List<dynamic> updatedList = _currentSongs.map((e) => e.getMap).toList();
      // Timpa data lama dengan list lagu yang baru (yang sudah dikurangi)
      box.put(widget.playlistKey, updatedList);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lagu dihapus dari playlist"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  // --- CRUD FUNCTIONS ---

  void deleteSong(SongModel song) async {
    // 1. LOGIC IZIN (Permission) YANG LEBIH RAPI
    bool permissionGranted = false;

    // Cek Manage External Storage (Android 11+)
    if (await Permission.manageExternalStorage.request().isGranted) {
      permissionGranted = true;
    }
    // Fallback: Cek Storage biasa (Android 10 ke bawah)
    else if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    }

    // 2. EKSEKUSI UTAMA
    if (permissionGranted) {
      try {

        final provider = context.read<AudioProvider>();
        final currentPlaying = provider.currentSong;

        // Cek apakah lagu yang mau dihapus lagi diputer?
        if (currentPlaying != null && currentPlaying.id == song.id) {
          print("DEBUG: Lagu sedang diputar. Mematikan suara...");
          provider.player.stop();
          // await AudioManager().player.stop();
          // AudioManager().currentSongNotifier.value = null;
          // AudioManager().isPlayerExpanded.value = false;
        }

        // === B. HAPUS FILE FISIK ===
        final file = File(song.data);
        if (await file.exists()) {
          await file.delete();
          print("DEBUG: File fisik berhasil dihapus");
        } else {
          print("DEBUG: File fisik tidak ditemukan (mungkin sudah hilang)");
        }

        // === C. UPDATE TAMPILAN (UI) ===
        if (mounted) {
          setState(() {
            _currentSongs.removeWhere((item) => item.id == song.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lagu berhasil dihapus")),
          );
        }
      } catch (e) {
        print('ERROR saat menghapus: $e');

        // Solusi Darurat: Kalau error, tetep ilangin dari list biar user gak bingung
        if (mounted) {
          setState(() {
            _currentSongs.removeWhere((item) => item.id == song.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dihapus dari tampilan (System Error: $e)")),
          );
        }
      }
    } else {
      // Kalau izin ditolak
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin penyimpanan ditolak")),
        );
      }
    }
  }

  void showDeleteDialog(SongModel song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Hapus Lagu?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Yakin hapus '${song.title}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSong(song);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void addToPlaylist(String rawPlaylistKey, SongModel song) {
    // 1. Ambil nama asli untuk TAMPILAN (Hapus __angka)
    String displayName = rawPlaylistKey;
    if (rawPlaylistKey.contains('__')) {
      displayName = rawPlaylistKey.split('__')[0];
    }

    final playlistBox = Hive.box('Playlists'); 
    
    // 2. Ambil data pakai KEY ASLI (tetap pakai rawPlaylistKey buat database)
    List<dynamic> currentSongs = playlistBox.get(
      rawPlaylistKey,
      defaultValue: [],
    );

    // Cek duplikasi
    bool exists = currentSongs.any((s) {
      if (s is Map) return s['_id'] == song.id || s['id'] == song.id;
      return false;
    });

    if (!exists) {
      currentSongs.add(song.getMap);
      // Simpan ke DB pakai KEY ASLI
      playlistBox.put(rawPlaylistKey, currentSongs); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Tampilkan nama yang sudah bersih
          content: Text("Ditambahkan ke $displayName"), 
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Tampilkan nama yang sudah bersih
          content: Text("Lagu sudah ada di playlist $displayName"),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void showAddToPlaylistDialog(SongModel song) {
    showDialog(
      context: context,
      builder: (context) {
        // Pastikan Box 'Playlists' sudah open di main.dart/library_page
        final playlistBox = Hive.box('Playlists');
        final playlists = playlistBox.keys.cast<String>().toList();

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Pilih Playlist",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: playlists.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada playlist",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final String rawKey = playlists[index];

                      String displayName = rawKey;
                      if (rawKey.contains('__')) {
                        displayName = rawKey.split('__')[0];
                      }

                      if (displayName == "Downloads" ||
                          displayName == "Liked Songs" ||
                          displayName == "New Episodes" ||
                          displayName == "Your Episodes") {
                        return const SizedBox.shrink(); // Skip system playlists
                      }

                      return ListTile(
                        title: Text(
                          displayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          addToPlaylist(rawKey, song);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          widget.playlistTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),

      // --- LIST LAGU ---
      body: _currentSongs.isEmpty
          ? const Center(
              child: Text(
                "Folder kosong.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _currentSongs.length,
              itemBuilder: (context, index) {
                final song = _currentSongs[index];

                // ValueListenableBuilder mendengarkan AudioManager global
                return Selector<AudioProvider, int?>(
                  selector: (_, provider) => provider.currentSong?.id,
                  builder: (context, currentSongId,ild) {
                    final bool isSelected = currentSongId == song.id;
                    final textColor = isSelected ? Colors.green : Colors.white;

                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      title: LayoutBuilder(
                        builder: (context, constraints) {
                          // Logic Marquee Text (Running Text)
                          final textSpan = TextSpan(
                            text: song.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          );
                          textPainter.layout(
                            minWidth: 0,
                            maxWidth: double.infinity,
                          );

                          final bool isOverflowing =
                              textPainter.width > constraints.maxWidth;
                          // Hanya jalan kalau lagu dipilih DAN teksnya kepanjangan
                          final bool shouldRun = isSelected && isOverflowing;

                          return SizedBox(
                            height: 24,
                            child: shouldRun
                                ? Marquee(
                                    text: song.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    blankSpace: 50.0,
                                    velocity: 30.0,
                                    pauseAfterRound: const Duration(seconds: 2),
                                    startPadding: 10.0,
                                    accelerationDuration: const Duration(
                                      seconds: 1,
                                    ),
                                    decelerationDuration: const Duration(
                                      milliseconds: 500,
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),

                      subtitle: Text(
                        song.artist ?? "Unknown",
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                      ),

                      onTap: () => playSong(index),

                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: Colors.grey[900],
                        onSelected: (value) {
                          if (value == 'playlist')
                            showAddToPlaylistDialog(song);
                          if (value == 'delete') showDeleteDialog(song);
                          if (value == 'remove') _removeSong(index);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'playlist',
                            child: Text(
                              "Add to Playlist",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          if (widget.playlistTitle == 'Downloads')
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                "Hapus File",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                            if (widget.playlistKey != null) 
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                "Hapus dari Playlist",
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
