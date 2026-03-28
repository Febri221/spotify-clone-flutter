import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Providers
import 'package:provider/provider.dart';
import 'package:percobaan/providers/audio_provider.dart';
import '../providers/song_provider.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key, });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  List<SongModel> _foundSongs = [];
  bool _isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final allSongs = context.read<SongProvider>().globalSongs;
      _foundSongs = allSongs;
      _isInit = false;
    }
 
  }

  void _runFilter(String keyword) {
    final allSongs = context.read<SongProvider>().globalSongs;

    List<SongModel> results = [];
    if (keyword.isEmpty) {
      results = List.from(allSongs);
    } else {
      results = allSongs.where((song) {
        final titleLower = song.title.toLowerCase();
        final artistLower = (song.artist ?? '').toLowerCase();
        final searchLower = keyword.toLowerCase();

        return titleLower.contains(searchLower) ||
            artistLower.contains(searchLower);
      }).toList();
    }

    setState(() {
      _foundSongs = results;
    });
  }

  void _playMIxedQueue(int index) {
    final playMixedQueue = context.read<SongProvider>().globalSongs;
    
    final selectedSong = _foundSongs[index];

    final otherSongs = playMixedQueue
        .where((song) => song.id != selectedSong.id)
        .toList();

    otherSongs.shuffle();

    final mixedPlaylist = [selectedSong, ...otherSongs];

    context.read<AudioProvider>().playPlaylist(mixedPlaylist, 0);
  }

  void _removeItem(SongModel song) {
    setState(() {
      _foundSongs.removeWhere((item) => item.id == song.id);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);


    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            _runFilter(value);
            setState(() {});
          },
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          cursorColor: Colors.green,
          decoration: InputDecoration(
            hintText: 'Cari Lagu atau Artist',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: InputBorder.none,

            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _runFilter('');
                    },
                  )
                : null,
          ),
        ),
      ),

      body: Selector<AudioProvider, int?>(
        selector: (_, provider) => provider.currentSong?.id,
        builder: (context, currentSong, child) {
          if (_foundSongs.isEmpty) {
            return Center(
              child: Text(
                'Lagu tidak ditemukan',
                style: TextStyle(color: Colors.grey[500]),
              ),
            );
          }

          return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: _foundSongs.length,
            itemBuilder: (context, index) {
              final song = _foundSongs[index];
              final bool isPlayingThisSong = currentSong == song.id;

              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlayingThisSong ? Colors.green : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                subtitle: Text(
                  song.artist ?? 'Unkown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500]),
                ),

                trailing: IconButton(
                  onPressed: () {
                    _removeItem(song);
                  },
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _playMIxedQueue(index);
                },
              );
            },
          );
        },
      ),
    );
  }
}
