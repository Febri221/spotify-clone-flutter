import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';
import 'package:percobaan/data/dummy_songs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percobaan/models/player_modal.dart';

class PlaylistDetailPage extends StatefulWidget {
  final LibraryItem playlistItem;

  PlaylistDetailPage({required this.playlistItem});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool isPlaying = false;
  int? currentSongIndex;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });

    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _showPlayerModal(BuildContext context, dynamic song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setmodalState) {
            return StreamBuilder(
              stream: _player.onPositionChanged,
              builder: (context, snapshot) {
                final currentPos = snapshot.data ?? _position;

                return PlayerModal(
                  song: song,
                  isPlaying: isPlaying,
                  duration: _duration,
                  position: currentPos,
                  onPlayPause: () {
                    if (isPlaying) {
                      _player.pause();
                    } else {
                      _player.resume();
                    }
                  },
                  onSeek: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _player.seek(position);
                    await _player.resume();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _togglePlayPause(String url, int index) async {
    if (currentSongIndex == index) {
      if (isPlaying) {
        await _player.pause();
        setState(() => isPlaying = false);
      } else {
        await _player.resume();
        setState(() => isPlaying = true);
      }
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() {
        currentSongIndex = index;
        isPlaying = true;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          widget.playlistItem.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: widget.playlistItem.songs.length,
        itemBuilder: (context, index) {
          final song = widget.playlistItem.songs[index];
          bool isThisSongPlaying = (currentSongIndex == index && isPlaying);
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                song.imageUrl,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(song.title, style: TextStyle(color: Colors.white)),
            subtitle: Text(
              song.artist,
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
                _togglePlayPause(
                  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                  index,
                );
              _showPlayerModal(context, song);
            },
            trailing: IconButton(
              icon: Icon(
                isThisSongPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: isThisSongPlaying ? Colors.green : Colors.white,
              ),
              onPressed: () {
                _togglePlayPause(
                  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                  index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
