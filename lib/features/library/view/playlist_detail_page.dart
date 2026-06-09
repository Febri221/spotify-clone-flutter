import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/core/constants/app_constants.dart';
import 'package:percobaan/data/services/local_audio_service.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';

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
  late List<SongModel> _songs;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.songs);
    _fetchServerSongs();
  }

  // Fetch lagu dari server via LocalAudioService
  Future<void> _fetchServerSongs() async {
    try {
      final serverSongs = await LocalAudioService().fetchSongs();
      if (serverSongs.isNotEmpty && mounted) {
        setState(() => _songs = serverSongs);
      }
    } catch (e) {
      debugPrint('Gagal fetch lagu dari server: $e');
    }
  }

  void _playSong(int index) async {
    final vm = context.read<AudioViewModel>();
    final tapped = _songs[index];

    if (vm.currentSong?.id == tapped.id) {
      vm.togglePlayerExpanded();
    } else {
      await vm.playPlaylist(_songs, index);
      if (mounted) vm.togglePlayerExpanded();
    }
  }

  void _removeSongFromPlaylist(int index) {
    setState(() => _songs.removeAt(index));

    if (widget.playlistKey != null) {
      final box = Hive.box('Playlists');
      box.put(widget.playlistKey, _songs.map((s) => s.getMap).toList());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lagu dihapus dari playlist'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteSongFile(SongModel song) async {
    final granted = await _requestDeletePermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan ditolak')),
        );
      }
      return;
    }

    try {
      final vm = context.read<AudioViewModel>();
      if (vm.currentSong?.id == song.id) vm.player.stop();

      final file = File(song.data);
      if (await file.exists()) await file.delete();

      if (mounted) {
        setState(() => _songs.removeWhere((s) => s.id == song.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lagu berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _songs.removeWhere((s) => s.id == song.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dihapus dari tampilan (error: $e)')),
        );
      }
    }
  }

  Future<bool> _requestDeletePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    return false;
  }

  void _addToPlaylist(String rawKey, SongModel song) {
    final displayName = rawKey.contains('__') ? rawKey.split('__')[0] : rawKey;
    final box = Hive.box('Playlists');
    final current = box.get(rawKey, defaultValue: []) as List;

    final exists = current.any((s) {
      if (s is Map) return s['_id'] == song.id || s['id'] == song.id;
      return false;
    });

    if (!exists) {
      current.add(song.getMap);
      box.put(rawKey, current);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ditambahkan ke $displayName'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lagu sudah ada di $displayName'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ));
    }
  }

  void _showDeleteDialog(SongModel song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Hapus Lagu?', style: TextStyle(color: Colors.white)),
        content: Text('Yakin hapus "${song.title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSongFile(song);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(SongModel song) {
    showDialog(
      context: context,
      builder: (_) {
        final box = Hive.box('Playlists');
        final playlists = box.keys.cast<String>().toList();

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Pilih Playlist',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: playlists.isEmpty
                ? const Center(
                    child: Text('Belum ada playlist',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (_, i) {
                      final key = playlists[i];
                      final display =
                          key.contains('__') ? key.split('__')[0] : key;

                      // Skip sistem playlist
                      if (['Downloads', 'Liked Songs', 'New Episodes',
                            'Your Episodes'].contains(display)) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        title: Text(display,
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          _addToPlaylist(key, song);
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: _songs.isEmpty
          ? const Center(
              child: Text('Folder kosong.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _songs.length,
              itemBuilder: (_, index) {
                final song = _songs[index];
                return Selector<AudioViewModel, int?>(
                  selector: (_, vm) => vm.currentSong?.id,
                  builder: (_, currentId, __) {
                    final isSelected = currentId == song.id;
                    final color = isSelected ? Colors.green : Colors.white;

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
                      title: LayoutBuilder(
                        builder: (_, constraints) {
                          final painter = TextPainter(
                            text: TextSpan(text: song.title,
                                style: const TextStyle(fontSize: 16)),
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: double.infinity);

                          final overflow = painter.width > constraints.maxWidth;
                          final shouldScroll = isSelected && overflow;

                          return SizedBox(
                            height: 24,
                            child: shouldScroll
                                ? Marquee(
                                    text: song.title,
                                    style: TextStyle(color: color, fontSize: 16),
                                    blankSpace: 50,
                                    velocity: 30,
                                    pauseAfterRound: const Duration(seconds: 2),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: color, fontSize: 16),
                                    ),
                                  ),
                          );
                        },
                      ),
                      subtitle: Text(song.artist ?? 'Unknown',
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () => _playSong(index),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: Colors.grey[900],
                        onSelected: (value) {
                          if (value == 'playlist') _showAddToPlaylistDialog(song);
                          if (value == 'delete') _showDeleteDialog(song);
                          if (value == 'remove') _removeSongFromPlaylist(index);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'playlist',
                            child: Text('Add to Playlist',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (widget.playlistTitle == 'Downloads')
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus File',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          if (widget.playlistKey != null)
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Hapus dari Playlist',
                                  style: TextStyle(color: Colors.orangeAccent)),
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