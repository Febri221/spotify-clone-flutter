import 'package:flutter/material.dart';
import 'package:percobaan/widgets/library_item_class.dart';
import 'package:percobaan/screens/library/widgets/playlist_detail_page.dart';
import 'package:percobaan/screens/library/widgets/library_header.dart';
import 'package:percobaan/screens/library/widgets/category_selector.dart';
import 'package:percobaan/screens/library/widgets/library_bottom_sheet.dart';
import 'package:percobaan/screens/library/widgets/create_modal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/services/update_service.dart';

//provider
import 'package:percobaan/providers/playlist_provider.dart';
import 'package:percobaan/providers/song_provider.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  final ScrollController? externalScrollController;
  LibraryPage({super.key, this.externalScrollController});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final List<String> categories = ['All', 'Playlists', 'Downloads'];
  int selectedCategory = 0;
  bool isGrid = false;
  LibraryItem? _activeItem;
  Set<String> pinnedPlaylists = {};
  late ScrollController _scrollController;
  final bool _isMenuOpen = false;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService().checkForUpdate(context);
    });
    _scrollController = widget.externalScrollController ?? ScrollController();

    // 1. LOAD DATA STATIS (FIX: Jangan difilter biar Liked Songs muncul)
    // Kita copy dari defaultItems (data dummy kamu)

  }

  List<LibraryItem> _buildSystemItems(BuildContext context) {
    final allSongs = context.watch<SongProvider>().globalSongs;
    final favoriteIds = context.watch<PlaylistProvider>().favoriteIds;

    final likedSongsCount = allSongs
        .where((song) => favoriteIds.contains(song.id))
        .length;

    return [
      LibraryItem(
        title: 'Liked Songs',
        containerGradient: LinearGradient(
          colors: [Colors.deepPurpleAccent.shade400, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        iconInContainer: Icon(Icons.favorite, size: 30.0, color: Colors.white),
        titleColor: Colors.white,
        subtitle: 'Playlists • $likedSongsCount songs',
        containerColor: null,
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'New Episodes',
        iconInContainer: Icon(
          Icons.notifications,
          size: 30.0,
          color: Color(0xFF1ED760),
        ),
        titleColor: Colors.white,
        subtitle: 'Updated Jan 25, 2025',
        containerColor: Color(0xFF5E3DB3),
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'Your Episodes',
        iconInContainer: Icon(
          Icons.bookmark,
          size: 30.0,
          color: Color(0xFF1ED760),
        ),
        titleColor: Colors.white,
        subtitle: 'Playlists • Saved & downloaded episodes',
        containerColor: Colors.green.shade900,
        category: 'Playlists',
      ),
      LibraryItem(
        title: 'Downloads',
        iconInContainer: Icon(
          Icons.download,
          size: 30.0,
          color: Color(0xFF1ED760),
        ),
        titleColor: Colors.white,
        subtitle: 'Playlists • ${allSongs.length} songs',
        containerColor: Colors.green.shade900,
        category: 'Downloads',
      ),
    ];
  }


  // --- LOGIC RENAME PLAYLIST ---
  void _showRenameDialog(LibraryItem item) {
    TextEditingController renameController = TextEditingController();
    // Bersihkan nama untuk ditampilkan di TextField
    String currentDisplayTitle = item.title.contains('__')
        ? item.title.split('__')[0]
        : item.title;
    renameController.text = currentDisplayTitle;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Rename Playlist', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: renameController,
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Nama playlist baru',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                String newName = renameController.text.trim();
                // Validasi nama baru
                if (newName.isNotEmpty && newName != currentDisplayTitle) {
                  await _processRename(item, newName);
                  Navigator.pop(context);
                }
              },
              child: Text('Rename', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processRename(LibraryItem item, String newName) async {
    var box = Hive.box('Playlists');
    String oldKey = item.title; // Key lama (misal: Galau__123)
    List<dynamic> songs = box.get(oldKey, defaultValue: []);

    // Buat Key baru (misal: Senang__999)
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    String newKey = "${newName}__$uniqueId";

    // Copy data ke key baru, hapus key lama
    await box.put(newKey, songs);
    await box.delete(oldKey);

    // Tidak perlu setState manual karena ValueListenableBuilder akan refresh UI
  }

  void showCreateModalFromOutside() {
    CreateModal.show(context, (judul, kategori) {
      _addNewItem(judul, kategori);
    });
  }

  // --- LOGIC ADD NEW PLAYLIST ---
  void _addNewItem(String title, String category) async {
    if (title.trim().isEmpty) return;

    if (category == 'Playlists') {
      if (!Hive.isBoxOpen('Playlists')) await Hive.openBox('Playlists');
      var box = Hive.box('Playlists');

      // Simpan dengan ID Unik biar bisa punya nama sama
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      String databaseKey = "${title}__$uniqueId";

      await box.put(databaseKey, []); // Simpan list kosong

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil membuat playlist: $title'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void togglePin(LibraryItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
      item.isPinnedIcon = item.isPinned;

      if (item.isPinned) {
        pinnedPlaylists.add(item.title);
      } else {
        pinnedPlaylists.remove(item.title);
      }
      // Note: Idealnya status pin disimpan juga ke Hive/Local Storage
    });
  }

  // ===============================
  //  UI BUILDER
  // ===============================
  @override
  Widget build(BuildContext context) {
    final systemsItems = _buildSystemItems(context);
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: Color(0xFF191414),
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('images/febri.jpg'),
            ),
            SizedBox(width: 10),
            Text(
              "Your Library",
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
            icon: Icon(Icons.search, color: Colors.white, size: 35),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 35),
            onPressed: () {
              CreateModal.show(context, (judul, kategori) {
                _addNewItem(judul, kategori);
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CategorySelector(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: (index) =>
                setState(() => selectedCategory = index),
          ),
        ),
      ),

      // CCTV DATABASE: Real-time update
      body: ValueListenableBuilder(
        valueListenable: Hive.box('Playlists').listenable(),
        builder: (context, Box box, child) {
          // 1. Ambil Data Hive (Playlist User)
          List<LibraryItem> hiveItems = [];
          final keys = box.keys.cast<String>().toList();

          for (var key in keys) {
            final List songs = box.get(key, defaultValue: []);
            final int songCount = songs.length;

            hiveItems.add(
              LibraryItem(
                title: key, // Key asli (ada unique ID)
                iconInContainer: Container(
                  child: Icon(Icons.music_note, color: Colors.white),
                ),
                titleColor: Colors.white,
                subtitle: 'Playlist • $songCount songs',
                containerColor: Colors.grey[900],
                category: 'Playlists',
                isPinned: pinnedPlaylists.contains(key),
              ),
            );
          }

          // 2. GABUNGKAN DATA (Static di ATAS, Hive di BAWAH)
          // hiveItems.reversed agar playlist terbaru ada di paling atas dari kelompok playlist user
          List<LibraryItem> allDisplayItems = [
            ...systemsItems,
            ...hiveItems.reversed,
          ];

          // 3. Filtering Logic
          List<LibraryItem> filteredItems = [];
          String selected = categories[selectedCategory];

          if (selected == 'All') {
            filteredItems = allDisplayItems;
          } else if (selected == 'Playlists') {
            // Tampilkan semua yg kategorinya Playlists (termasuk Liked Songs & Playlist User)
            filteredItems = allDisplayItems
                .where((item) => item.category == 'Playlists')
                .toList();
          } else {
            // Downloads dll
            filteredItems = allDisplayItems
                .where((item) => item.category == selected)
                .toList();
          }

          // 4. Sorting (Pinning)
          filteredItems.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return 0;
          });

          // 5. Tampilkan UI
          if (filteredItems.isEmpty) {
            return Center(
              child: Text(
                'Library Kosong',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          // FIX DEAD CODE: Return Grid/List sekarang di luar blok IF
          return Column(
            children: [
              LibraryHeader(
                isGrid: isGrid,
                onToggleView: () => setState(() => isGrid = !isGrid),
              ),
              Expanded(
                child: isGrid
                    ? GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildTile(filteredItems[index], true);
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 100,
                        ), // Padding bawah biar gak ketutupan player
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildTile(filteredItems[index], false);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(LibraryItem item, bool grid) {
    bool isActive = _activeItem == item;

    // Bersihkan judul (buang ID unik Hive)
    String displayTitle = item.title;
    if (displayTitle.contains('__')) {
      displayTitle = displayTitle.split('__')[0];
    }

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
      isHighlighted: isActive, // <--- Ini pemicu visualnya

      onTouch: (isDown) {
        if (isDown) {
          setState(() => _activeItem = item);
        } else {
          if (!_isMenuOpen) {
            setState(() => _activeItem = null);
          }
        }
      },

      // --- LOGIC SKENARIO TELEGRAM ---
      onTap: () async {
        // 1. NYALA (Soft Light)
        setState(() => _activeItem = item);

        // 2. TAHAN (Biar mata user sadar item terpencet)
        await Future.delayed(Duration(milliseconds: 100));

        // 3. MATI (Reset warna sebelum berangkat)
        if (mounted) {
          setState(() => _activeItem = null);
        }

        // 4. NAPAS (Kasih waktu HP render warna 'mati' biar gak nyangkut)
        await Future.delayed(Duration(milliseconds: 40));

        if (!mounted) return;

        // 5. NAVIGASI
        Route? route;

        // Cek Downloads
        if (item.title == 'Downloads') {
          final allSongs = context.read<SongProvider>().globalSongs;
          route = MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(
              playlistTitle: 'Downloads',
              songs: allSongs,
            ),
          );
        } else if (item.title == 'Liked Songs') {
          final allSongs = context.read<SongProvider>().globalSongs;
          final favoriteIds = context.read<PlaylistProvider>().favoriteIds;

          final likedSongs = allSongs.where((song) => favoriteIds.contains(song.id)).toList();
          route = MaterialPageRoute(builder: (context) => PlaylistDetailPage(playlistTitle: 'Liked Songs', songs: likedSongs));
        }
        // Cek Playlist Lain
        else if (item.category == 'Playlists') {
          
          final playlistBox = Hive.box('Playlists');

          if (playlistBox.containsKey(item.title)) {
            // Logic Ambil Lagu Hive
            final List<dynamic> rawList = playlistBox.get(
              item.title,
              defaultValue: [],
            );
            List<SongModel> playlistSongs = [];
            try {
              playlistSongs = rawList
                  .map((data) {
                    if (data is SongModel) return data;
                    if (data is Map)
                      return SongModel(data.cast<String, dynamic>());
                    return null;
                  })
                  .whereType<SongModel>()
                  .toList();
            } catch (e) {
              print(e);
            }

            route = MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                playlistTitle: displayTitle,
                songs: playlistSongs,
                playlistKey: item.title,
              ),
            );
          } else {
            // Logic Folder Sistem Lain
            route = MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                playlistTitle: displayTitle,
                songs: [],
                playlistKey: null,
              ),
            );
          }
        }

        // Eksekusi Pindah
        if (route != null) {
          Navigator.push(context, route);
        }
      },

      // -------------------------------
      onTogglePin: () => togglePin(item),
      onLongPress: () async {
        // Logic Long Press tetep sama
        setState(() => _activeItem = item);

        VoidCallback? renameAction;
        List<String> systemFolders = [
          'Downloads',
          'Liked Songs',
          'New Episodes',
          'Your Episodes',
        ];
        String cleanName = item.title.contains('__')
            ? item.title.split('__')[0]
            : item.title;

        if (!systemFolders.contains(cleanName) &&
            item.category == 'Playlists') {
          renameAction = () => _showRenameDialog(item);
        }

        await LibraryBottomSheet.show(
          context,
          item,
          () => togglePin(item),
          onRename: renameAction,
        );

        if (mounted) setState(() => _activeItem = null);
      },
    );
  }
}
