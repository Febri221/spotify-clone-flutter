import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import './now_playing_page.dart';
import 'dart:io';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _CreatePageState();
}

class _CreatePageState extends State<SearchPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  // Variabel buat nyimpen daftar lagu biar bisa di-next
  List<SongModel> _songs = [];

  // Variabel buat tau lagu apa yang lagi diputer sekarang
  String _currentTitle = "";
  int? _currentIndex;

  @override
  void initState() {
    super.initState();
    requestPermission();

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _songs.length) {
        setState(() {
          _currentIndex = index;
          _currentTitle = _songs[index].title;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  requestPermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }
    setState(() {});
  }

  void deleteSong(SongModel song) async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      try {
        final file = File(song.data);

        if (await file.exists()) {
          await file.delete();
          setState(() {
            _songs.removeWhere((item) => item.id == song.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lagu "${song.title}" berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('File tidak ditemukan')));
        }
      } catch (e) {
        print("Error deleting: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: File diproteksi sistem')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Izin akses file ditolak')));
      openAppSettings();
    }
  }

  // --- LOGIC BARU: MUTER DENGAN PLAYLIST ---
  void playSong(int index) {
    try {
      // 1. Ubah daftar lagu (SongModel) jadi daftar AudioSource biar dibaca Player
      // Ini bikin "Antrian" lagu di memori
      final playlist = ConcatenatingAudioSource(
        children: _songs.map((song) {
          return AudioSource.uri(Uri.parse(song.uri!));
        }).toList(),
      );

      setState(() {
        _currentTitle = _songs[index].title;
      });

      // 4. Dengerin perubahan lagu (Kalo lagu abis & pindah otomatis, judul update)
      _player.setAudioSource(playlist, initialIndex: index);
      _player.play();
    } catch (e) {
      print("Error muter lagu: $e");
    }
  }

  void showDeletDialog(SongModel song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Hapus Lagu?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Yakin mau hapus "${song.title}" dari HP?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteSong(song);
              },
              child: Text('Hapus', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Your Downloads Songs"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),

      // --- BAGIAN LIST LAGU ---
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item.data == null || item.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada lagu bre.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Simpan data lagu ke variabel global biar tombol Next tau
          _songs = item.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              SongModel song = item.data![index];
              final bool isPlaying = index == _currentIndex;

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
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isPlaying ? Colors.green : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist ?? "Unknown",
                  style: TextStyle(color: Colors.grey[400]),
                ),
                onTap: () {
                  // Play berdasarkan INDEX (urutan), bukan cuma file
                  playSong(index);
                },
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.grey[900],

                  onSelected: (String value) {
                    if (value == 'delete') {
                      showDeletDialog(song);
                    } else if (value == 'playlist') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fitur "Add to Playlist" alan segera hadir',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      value: 'playlist',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_add, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Add to Playlist',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuDivider(height: 1),

                    PopupMenuItem<String>(value: 'delete', child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent,),
                        SizedBox(width: 10),
                        Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                      ],
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),

      // --- FITUR BARU: MINI PLAYER DI BAWAH ---
      bottomSheet: _currentTitle.isEmpty && _player.audioSource == null
          ? null
          : GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  enableDrag: true,
                  builder: (context) {
                    return NowPlayingPage(player: _player, songs: _songs);
                  },
                );
              },
              child: Container(
                color: Colors.grey[900], // Warna background player
                height: 80,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Info Lagu yang lagi jalan
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentTitle.isEmpty
                                ? "Lagunya Download dulu ya gaiisss"
                                : _currentTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Now Playing",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // 2. Tombol Kontrol (Prev - Play/Pause - Next)
                    Row(
                      children: [
                        // PREVIOUS
                        StreamBuilder<SequenceState?>(
                          stream: _player.sequenceStateStream,
                          builder: (context, snapshot) {
                            final SequenceState? sequenceState = snapshot.data;

                            // FIX: Hitung manual. Can go back kalau currentIndex lebih besar dari 0 (lagu pertama).
                            final bool canGoBack =
                                (sequenceState != null &&
                                sequenceState.currentIndex != null &&
                                sequenceState.currentIndex! > 0);

                            return IconButton(
                              onPressed: canGoBack
                                  ? _player.seekToPrevious
                                  : null,
                              icon: Icon(
                                Icons.skip_previous,
                                // Warna Putih kalau bisa diklik, Abu-abu kalau disable
                                color: canGoBack ? Colors.white : Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),

                        // PLAY / PAUSE (Pake StreamBuilder biar icon berubah otomatis)
                        StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing;

                            if (playing == true) {
                              return IconButton(
                                onPressed: _player
                                    .pause, // Kalo lagi main, tombolnya PAUSE
                                icon: const Icon(
                                  Icons.pause_circle_filled,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            } else {
                              return IconButton(
                                onPressed: _player
                                    .play, // Kalo lagi diem, tombolnya PLAY
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            }
                          },
                        ),

                        // NEXT
                        StreamBuilder<SequenceState?>(
                          stream: _player.sequenceStateStream,
                          builder: (context, snapshot) {
                            final SequenceState? sequenceState = snapshot.data;
                            final bool canGoNext =
                                (sequenceState != null &&
                                sequenceState.currentIndex != null &&
                                sequenceState.currentIndex! <
                                    sequenceState.sequence.length - 1);
                            return IconButton(
                              onPressed: canGoNext ? _player.seekToNext : null,
                              icon: Icon(
                                Icons.skip_next,
                                color: canGoNext ? Colors.white : Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
