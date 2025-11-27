import 'package:flutter/material.dart';
import 'package:percobaan/data/playlist_detail_page.dart';
import 'package:percobaan/widget/library_item_class.dart';

class LibraryItemTile extends StatelessWidget {
  final LibraryItem item;
  final bool isGridMode;
  final VoidCallback onTogglePin;
  final VoidCallback onLongPress;

  const LibraryItemTile({
    super.key,
    required this.item,
    required this.isGridMode,
    required this.onTogglePin,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaylistDetailPage(playlistItem: item)),
        );
      },
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        child: LibraryItem( // Widget tampilan item kamu
          title: item.title,
          imagePath: item.imagePath,
          iconInContainer: item.iconInContainer,
          containerColor: item.containerColor,
          containerGradient: item.containerGradient,
          titleColor: item.titleColor,
          subtitle: item.subtitle,
          isGrid: isGridMode,
          isPinnedIcon: item.isPinnedIcon,
          isPinned: item.isPinned,
          onTogglePin: onTogglePin,
        ),
      ),
    );
  }
}
