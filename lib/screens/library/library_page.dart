import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';
import 'package:percobaan/data/library_items.dart';

import 'package:percobaan/screens/library/widgets/library_header.dart';
import 'package:percobaan/screens/library/widgets/library_item_tile.dart';
import 'package:percobaan/screens/library/widgets/category_selector.dart';
import 'package:percobaan/screens/library/widgets/library_bottom_sheet.dart';
import 'package:percobaan/screens/library/widgets/create_modal.dart';

class LibraryPage extends StatefulWidget {
  final ScrollController? externalScrollController;
  LibraryPage({super.key, this.externalScrollController});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  final List<String> categories = ['All', 'Playlists', 'Podcasts', 'Artists'];
  int selectedCategory = 0;
  bool isGrid = false;
  late ScrollController _scrollController;
  late List<LibraryItem> myLibrary;

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
  }

  // --- LOGIC DATA ---
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
          iconInContainer: Icon( category == 'Artists'
              ? Icons.person
              : Icons.music_note,
          ),
          containerColor: Colors.grey[850],
          category: category,
        ),
      );
    });
  }

  // --- UI BUILDER ---
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
    return LibraryItemTile(
      item: item,
      isGridMode: grid,
      onTogglePin: () => togglePin(item),
      onLongPress: () =>
          LibraryBottomSheet.show(context, item, () => togglePin(item)),
    );
  }
}
