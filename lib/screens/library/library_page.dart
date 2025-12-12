import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';
import 'package:percobaan/data/library_items.dart';
import 'package:percobaan/screens/library/widgets/playlist_detail_page.dart';
import 'package:percobaan/screens/library/widgets/library_header.dart';
import 'package:percobaan/screens/library/widgets/library_item_tile.dart';
import 'package:percobaan/screens/library/widgets/category_selector.dart';
import 'package:percobaan/screens/library/widgets/library_bottom_sheet.dart';
import 'package:percobaan/screens/library/widgets/create_modal.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Audio & Permission
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart'; // PENTING

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

  late ScrollController _scrollController;
  late List<LibraryItem> myLibrary;

  // Audio
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _realSongs = [];

  void showCreateModalFromOutside() {
    CreateModal.show(context, (judul, kategori) {
      _addNewItem(judul, kategori);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = widget.externalScrollController ?? ScrollController();
    myLibrary = List.from(defaultItems);

    _initializeData();
  }

  // ===============================
  //   FIX: LOGIC PERMISSION & FETCH
  // ===============================

  Future<void> requestPermissionAndFetchSongs() async {
    // 1. Cek Permission pake permission_handler (Lebih Stabil)
    var statusStorage = await Permission.storage.status;
    var statusPhotos = await Permission.photos.status;
    var statusAudio = await Permission.audio.status;

    if (!statusStorage.isGranted && !statusAudio.isGranted) {
      // Minta Izin
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.audio,
        Permission.photos,
      ].request();

      bool isAndroid13Complete =
          statuses[Permission.audio]!.isGranted &&
          statuses[Permission.photos]!.isGranted;
      bool isOldAndroidGranted = statuses[Permission.storage]!.isGranted;

      if (!isAndroid13Complete && !isOldAndroidGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Aplikasi butuh izin Lagu & Foto untuk berjalan normal",
              ),
            ),
          );
        }
        return; // Stop di sini kalau gak dikasih izin
      }
    }

    // 2. Jeda dikit (Trik ampuh buat Emulator biar gak nge-bug permission)
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Ambil Lagu
    try {
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (mounted) {
        setState(() {
          _realSongs = songs;

          // Update item "Downloads"
          final downloadIndex = myLibrary.indexWhere(
            (item) => item.title == 'Downloads',
          );

          if (downloadIndex != -1) {
            var oldItem = myLibrary[downloadIndex];
            myLibrary[downloadIndex] = LibraryItem(
              title: oldItem.title,
              iconInContainer: oldItem.iconInContainer,
              titleColor: oldItem.titleColor,
              subtitle: "Playlists • ${songs.length} songs",
              category: oldItem.category,
              containerColor: oldItem.containerColor,
            );
          }
        });
      }
    } catch (e) {
      print("ERROR FETCHING SONGS: $e");
    }
  }

  void _initializeData() async {
    await requestPermissionAndFetchSongs();
    fetchHivePlaylists();
  }

  // ===============================
  //   HIVE PLAYLISTS
  // ===============================

  void fetchHivePlaylists() async {
    if (!Hive.isBoxOpen('Playlists')) {
      await Hive.openBox('Playlists');
    }

    final playlistBox = Hive.box('Playlists');
    final playlistNames = playlistBox.keys.cast<String>().toList();

    List<LibraryItem> hiveItems = playlistNames.map((name) {
      List songs = playlistBox.get(name, defaultValue: []);
      int count = songs.length;

      return LibraryItem(
        title: name,
        iconInContainer: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.music_note, color: Colors.white),
        ),
        titleColor: Colors.white,
        subtitle: "Playlist • $count songs",
        category: 'Playlists',
        containerColor: Colors.grey[900],
      );
    }).toList();

    if (mounted) {
      setState(() {
        myLibrary.addAll(hiveItems);
      });
    }
  }

  // ===============================
  //   FILTERING & UI
  // ===============================

  List<LibraryItem> get filteredItems {
    String selected = categories[selectedCategory];
    if (selected == 'All') return myLibrary;
    return myLibrary.where((item) => item.category == selected).toList();
  }

  void togglePin(LibraryItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
      item.isPinnedIcon = item.isPinned;

      myLibrary.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    });
  }

  void _addNewItem(String title, String category) {
    setState(() {
      myLibrary.insert(
        0,
        LibraryItem(
          title: title,
          titleColor: Colors.white,
          subtitle: '$category • 0 songs',
          iconInContainer: Icon(
            category == 'Artists' ? Icons.person : Icons.music_note,
          ),
          containerColor: Colors.grey[850],
          category: category,
        ),
      );
    });
  }

  Widget buildListBody() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(8),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildTile(filteredItems[index], false);
      },
    );
  }

  Widget buildGridBody() {
    return GridView.builder(
      controller: _scrollController,
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          LibraryHeader(
            isGrid: isGrid,
            onToggleView: () => setState(() => isGrid = !isGrid),
          ),
          Expanded(child: isGrid ? buildGridBody() : buildListBody()),
        ],
      ),
    );
  }

  Widget _buildTile(LibraryItem item, bool grid) {
    bool isActive = _activeItem == item;
    return LibraryItem(
      title: item.title,
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

      onTap: () async {
        setState(() {
          _activeItem = item;
        });
        await Future.delayed(Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _activeItem = null;
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
        if (!mounted) return;
        
        if (item.title == 'Downloads') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                playlistTitle: 'Downloads',
                songs: _realSongs,
              ),
            ),
          );
        } else if (item.category == 'Playlists') {
          final playlistBox = Hive.box('Playlists');

          final List<dynamic> songList = playlistBox.get(
            item.title,
            defaultValue: [],
          );

          List<SongModel> playlistSongs = [];
          try {
            playlistSongs = songList.cast<SongModel>().toList();
          } catch (e) {
            print('Gagal convert lagu: $e');
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                playlistTitle: item.title,
                songs: playlistSongs,
              ),
            ),
          );
        }
      },
      onTogglePin: () => togglePin(item),
      onLongPress: () async {
        setState(() {
          _activeItem = item;
        });
        await LibraryBottomSheet.show(context, item, () => togglePin(item));

        if (mounted) {
          setState(() {
            _activeItem = null;
          });
        }
      },
    );
  }
}
