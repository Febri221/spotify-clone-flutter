import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/providers/audio_provider.dart';
import 'package:percobaan/providers/song_provider.dart';
import 'package:percobaan/services/youtube_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final YoutubeService _ytService = YoutubeService();

  // ── State ──────────────────────────────────────────────────────────────────
  List<SongModel> _foundLocalSongs = [];
  List<YtSearchResult> _foundYtSongs = [];
  bool _isSearchingYt = false;
  bool _isInit = true;

  // Debounce timer: tunggu 600ms setelah user berhenti mengetik baru search YT
  // Ini mencegah spam request ke YouTube setiap ketikan
  Timer? _debounceTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _foundLocalSongs = [];
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ytService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Search Logic ───────────────────────────────────────────────────────────

  void _onSearchChanged(String keyword) {
    // 1. Langsung filter lokal (instan, tidak perlu debounce)
    _runLocalFilter(keyword);

    // 2. YouTube search dengan debounce 600ms
    _debounceTimer?.cancel();
    if (keyword.trim().isEmpty) {
      setState(() {
        _foundYtSongs = [];
        _isSearchingYt = false;
      });
      return;
    }

    setState(() => _isSearchingYt = true);

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _searchYoutube(keyword);
    });
  }

  void _runLocalFilter(String keyword) {
    final allSongs = context.read<SongProvider>().globalSongs;
    setState(() {
      _foundLocalSongs = keyword.isEmpty
          ? []
          : allSongs.where((song) {
              final title = song.title.toLowerCase();
              final artist = (song.artist ?? '').toLowerCase();
              final q = keyword.toLowerCase();
              return title.contains(q) || artist.contains(q);
            }).toList();
    });
  }

  Future<void> _searchYoutube(String keyword) async {
    final results = await _ytService.search(keyword);
    if (!mounted) return;
    setState(() {
      _foundYtSongs = results;
      _isSearchingYt = false;
    });
  }

  // ── Play Helpers ───────────────────────────────────────────────────────────

  void _playLocalMixedQueue(int index) {
    final allSongs = context.read<SongProvider>().globalSongs;
    final selected = _foundLocalSongs[index];
    final others = allSongs.where((s) => s.id != selected.id).toList()
      ..shuffle();
    context.read<AudioProvider>().playPlaylist([selected, ...others], 0);
  }

  void _playYtSong(YtSearchResult result) {
    FocusScope.of(context).unfocus();
    context.read<AudioProvider>().playYoutubeSong(
          result.videoId,
          result.title,
          result.artist,
          result.thumbnailUrl,
        );
  }

  void _removeLocalItem(SongModel song) {
    setState(() => _foundLocalSongs.removeWhere((s) => s.id == song.id));
  }

  @override
  bool get wantKeepAlive => true;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          cursorColor: Colors.green,
          decoration: InputDecoration(
            hintText: 'Cari lagu lokal atau YouTube...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Selector<AudioProvider, int?>(
        selector: (_, p) => p.currentSong?.id,
        builder: (context, currentSongId, _) {
          final keyword = _searchController.text;

          // ── Kosong & tidak ada keyword → riwayat ──────────────────────────
          if (keyword.isEmpty) {
            return _buildRiwayat(currentSongId);
          }

          // ── Ada keyword → gabung lokal + YouTube ──────────────────────────
          return _buildSearchResults(currentSongId);
        },
      ),
    );
  }

  // ── Sections ───────────────────────────────────────────────────────────────

  Widget _buildRiwayat(int? currentSongId) {
    final riwayat = context.watch<SongProvider>().reecentSong;
    if (riwayat.isEmpty) {
      return Center(
        child: Text(
          'Cari lagu favoritmu!',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Terakhir dicari',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final song = riwayat[index];
              return _buildLocalTile(
                song: song,
                isPlaying: currentSongId == song.id,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  final allSongs = context.read<SongProvider>().globalSongs;
                  final idx = allSongs.indexWhere((s) => s.id == song.id);
                  if (idx != -1) {
                    context.read<AudioProvider>().playPlaylist(allSongs, idx);
                  }
                },
                onRemove: () => setState(
                  () => context.read<SongProvider>().reecentSong.remove(song),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(int? currentSongId) {
    final hasLocal = _foundLocalSongs.isNotEmpty;
    final hasYt = _foundYtSongs.isNotEmpty;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        // ── Hasil Lokal ──────────────────────────────────────────────────────
        if (hasLocal) ...[
          _sectionHeader('Di Perangkat', Icons.phone_android, Colors.green),
          ...List.generate(_foundLocalSongs.length, (index) {
            final song = _foundLocalSongs[index];
            return _buildLocalTile(
              song: song,
              isPlaying: currentSongId == song.id,
              onTap: () {
                FocusScope.of(context).unfocus();
                context.read<SongProvider>().addToRecentSearch(song);
                _playLocalMixedQueue(index);
              },
              onRemove: () => _removeLocalItem(song),
            );
          }),
        ],

        // ── Hasil YouTube ────────────────────────────────────────────────────
        _sectionHeader(
          'YouTube',
          Icons.play_circle_filled,
          Colors.red,
          trailing: _isSearchingYt
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
              : null,
        ),

        if (_isSearchingYt && !hasYt)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          )
        else if (!_isSearchingYt && !hasYt)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tidak ada hasil YouTube',
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          ...List.generate(_foundYtSongs.length, (index) {
            final yt = _foundYtSongs[index];
            return _buildYtTile(yt);
          }),
      ],
    );
  }

  // ── Tile Builders ──────────────────────────────────────────────────────────

  Widget _buildLocalTile({
    required SongModel song,
    required bool isPlaying,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return ListTile(
      leading: QueryArtworkWidget(
        id: song.id,
        type: ArtworkType.AUDIO,
        nullArtworkWidget: _defaultArtwork(),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? Colors.green : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artist ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[500]),
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, color: Colors.grey[600]),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }

  Widget _buildYtTile(YtSearchResult yt) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          yt.thumbnailUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultArtwork(),
        ),
      ),
      title: Text(
        yt.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        yt.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[500]),
      ),
      trailing: yt.duration != null
          ? Text(
              _formatDuration(yt.duration!),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            )
          : const Icon(Icons.play_arrow, color: Colors.red),
      onTap: () => _playYtSong(yt),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, Color color,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _defaultArtwork() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}