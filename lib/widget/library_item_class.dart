import 'package:flutter/material.dart';
import 'package:percobaan/models/song_model.dart';

class LibraryItem extends StatelessWidget {
  final String subtitle;
  final String title;
  final Color titleColor;
  final String? imagePath;
  final Icon? iconInContainer;
  final Gradient? containerGradient;
  final Color? containerColor;
  final bool isGrid;
  bool isPinned;
  bool isPinnedIcon;
  final VoidCallback? onTogglePin;
  final String? category;
  final List<SongModel> songs;

  LibraryItem({
    required this.title,
    this.containerGradient,
    this.iconInContainer,
    this.imagePath,
    required this.titleColor,
    required this.subtitle,
    this.containerColor,
    this.isGrid = false,
    this.isPinned = false,
    this.isPinnedIcon = false,
    this.onTogglePin,
    this.category,
    this.songs = const [],
  });

  @override
  Widget build(BuildContext) {
    bool isArtist = subtitle.contains('Artist');

    if (isGrid) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                height: 100,

                decoration: BoxDecoration(
                  borderRadius: !isArtist
                      ? (title == 'New Episodes'
                            ? BorderRadius.circular(12)
                            : null)
                      : null,
                  shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
                  color: containerGradient == null ? containerColor : null,
                  gradient: containerGradient,
                ),
                child: imagePath != null
                    ? (isArtist
                          ? ClipOval(
                              child: Image.asset(imagePath!, fit: BoxFit.cover),
                            )
                          : ClipRRect(
                              child: Image.asset(imagePath!, fit: BoxFit.cover),
                            ))
                    : Center(child: iconInContainer ?? SizedBox()),
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                isPinnedIcon ? Icons.push_pin : null,
                color: Colors.green,
                size: 14,
              ),
            ),
          ],
        ),
      );
    }
    // ListView
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
      child: Row(
        children: [
          // ========== GAMBAR ==========
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: !isArtist
                      ? (title == 'New Episodes'
                            ? BorderRadius.circular(12)
                            : null)
                      : null,
              shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
              color: containerGradient == null ? containerColor : null,
              gradient: containerGradient,
            ),
            child: imagePath != null
                ? (isArtist
                      ? ClipOval(
                          child: Image.asset(imagePath!, fit: BoxFit.cover),
                        )
                      : ClipRRect(
                          child: Image.asset(imagePath!, fit: BoxFit.cover),
                        ))
                : Center(child: iconInContainer ?? SizedBox()),
          ),
          // ========== TEXT =============
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor)),
                Row(
                  children: <Widget>[
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onTogglePin,
                  child: Icon(
                    isPinnedIcon ? Icons.push_pin : null,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
