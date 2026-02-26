import 'package:flutter/material.dart';
import 'package:percobaan/screens/library/widgets/playlist_detail_page.dart';
import 'package:percobaan/widgets/library_item_class.dart';

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

    String displayTitle = item.title;
    if (displayTitle.contains('__')) {
      displayTitle = displayTitle.split('__')[0];
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        child: LibraryItem( 
          title: displayTitle,
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
