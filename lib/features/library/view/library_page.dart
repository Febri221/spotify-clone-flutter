import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:percobaan/features/library/view/playlist_detail_page.dart';
import 'package:percobaan/features/library/viewmodel/library_viewmodel.dart';
import 'package:percobaan/features/library/widgets/category_selector.dart';
import 'package:percobaan/features/library/widgets/create_modal.dart';
import 'package:percobaan/features/library/widgets/library_bottom_sheet.dart';
import 'package:percobaan/features/library/widgets/library_header.dart';
import 'package:percobaan/features/player/viewmodel/song_viewmodel.dart';
import 'package:percobaan/features/library/viewmodel/playlist_viewmodel.dart';
import 'package:percobaan/data/services/update_service.dart';
import 'package:percobaan/features/library/widgets/library_item.dart';
// import 'package:percobaan/widgets/library_item_class.dart';

class LibraryPage extends StatefulWidget {
  final ScrollController? externalScrollController;
  const LibraryPage({super.key, this.externalScrollController});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final _viewModel = LibraryViewModel();
  final List<String> categories = ['All', 'Playlists', 'Downloads'];

  int _selectedCategory = 0;
  bool _isGrid = false;
  LibraryItem? _activeItem;
  Set<String> _pinnedPlaylists = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.externalScrollController ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService().checkForUpdate(context);
    });
  }

  void _togglePin(LibraryItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
      item.isPinnedIcon = item.isPinned;
      if (item.isPinned) {
        _pinnedPlaylists.add(item.title);
      } else {
        _pinnedPlaylists.remove(item.title);
      }
    });
  }

  void _showRenameDialog(LibraryItem item) {
    final currentName = _viewModel.cleanTitle(item.title);
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Rename Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.green,
          decoration: const InputDecoration(
            hintText: 'Nama playlist baru',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                await _viewModel.renamePlaylist(item.title, newName);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Rename', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void showCreateModalFromOutside() {
    CreateModal.show(context, (title, _) async {
      await _viewModel.createPlaylist(title);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil membuat playlist: $title'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = context.watch<SongViewModel>().songs;
    final favoriteIds = context.watch<PlaylistViewModel>().favoriteIds;
    final user = context.watch<AuthViewModel>().user;
    final systemItems = _viewModel.buildSystemItems(
      allSongs: allSongs,
      favoriteIds: favoriteIds,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: (user?.photoURL != null)
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 22)
                  : null,
            ),
            const SizedBox(width: 10),
            const Text(
              'Your Library',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 35),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 35),
            onPressed: showCreateModalFromOutside,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CategorySelector(
            categories: categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (i) => setState(() => _selectedCategory = i),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('Playlists').listenable(),
        builder: (context, Box box, _) {
          final hiveItems = _viewModel.buildHiveItems(box, _pinnedPlaylists);
          final filtered = _viewModel.filterAndSort(
            systemItems: systemItems,
            hiveItems: hiveItems,
            selectedCategory: categories[_selectedCategory],
          );

          if (filtered.isEmpty) {
            return const Center(
              child: Text('Library Kosong', style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }

          return Column(
            children: [
              LibraryHeader(
                isGrid: _isGrid,
                onToggleView: () => setState(() => _isGrid = !_isGrid),
              ),
              Expanded(
                child: _isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _buildTile(filtered[i], true),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _buildTile(filtered[i], false),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(LibraryItem item, bool grid) {
    final displayTitle = _viewModel.cleanTitle(item.title);
    final isActive = _activeItem == item;

    return LibraryItem(
      title: displayTitle,
      subtitle: item.subtitle,
      titleColor: item.titleColor,
      iconInContainer: item.iconInContainer,
      imagePath: item.imagePath,
      containerGradient: item.containerGradient,
      containerColor: item.containerColor,
      isGrid: grid,
      isPinned: item.isPinned,
      isPinnedIcon: item.isPinned,
      isHighlighted: isActive,
      onTouch: (isDown) => setState(() => _activeItem = isDown ? item : null),
      onTogglePin: () => _togglePin(item),
      onTap: () => _handleTap(item, displayTitle),
      onLongPress: () => _handleLongPress(item),
    );
  }

  Future<void> _handleTap(LibraryItem item, String displayTitle) async {
    setState(() => _activeItem = item);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _activeItem = null);
    await Future.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;

    final allSongs = context.read<SongViewModel>().songs;
    final favoriteIds = context.read<PlaylistViewModel>().favoriteIds;

    if (item.title == 'Downloads') {
      _navigate(PlaylistDetailPage(playlistTitle: 'Downloads', songs: allSongs));
    } else if (item.title == 'Liked Songs') {
      final liked = allSongs.where((s) => favoriteIds.contains(s.id)).toList();
      _navigate(PlaylistDetailPage(playlistTitle: 'Liked Songs', songs: liked));
    } else if (item.category == 'Playlists') {
      final box = Hive.box('Playlists');
      final songs = box.containsKey(item.title)
          ? _viewModel.getSongsFromHive(item.title)
          : <SongModel>[];
      _navigate(PlaylistDetailPage(
        playlistTitle: displayTitle,
        songs: songs,
        playlistKey: box.containsKey(item.title) ? item.title : null,
      ));
    }
  }

  Future<void> _handleLongPress(LibraryItem item) async {
    setState(() => _activeItem = item);

    final canRename = !_viewModel.isSystemFolder(item.title) &&
        item.category == 'Playlists';

    await LibraryBottomSheet.show(
      context,
      item,
      () => _togglePin(item),
      onRename: canRename ? () => _showRenameDialog(item) : null,
    );

    if (mounted) setState(() => _activeItem = null);
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}