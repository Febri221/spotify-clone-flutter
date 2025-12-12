import 'package:flutter/material.dart';
import 'package:percobaan/models/song_model.dart'; // Pastikan path ini sesuai projectmu

class LibraryItem extends StatelessWidget {
  final String subtitle;
  final String title;
  final Color titleColor;
  final String? imagePath;
  final Widget iconInContainer;
  final Gradient? containerGradient;
  final Color? containerColor;
  final bool isGrid;
  bool isPinned;
  bool isPinnedIcon;
  final VoidCallback? onTogglePin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? category;
  final List<SongModel> songs;
  final bool isHighlighted;

  LibraryItem({
    super.key,
    required this.title,
    this.containerGradient,
    required this.iconInContainer,
    this.imagePath,
    required this.titleColor,
    required this.subtitle,
    this.containerColor,
    this.isGrid = false,
    this.isPinned = false,
    this.isPinnedIcon = false,
    this.onTap,
    this.onTogglePin,
    this.onLongPress,
    this.category,
    this.songs = const [],
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isHighlighted ? Colors.white.withOpacity(0.1) : Colors.transparent;
    bool isArtist = subtitle.contains('Artist');

    // ==========================================
    // TAMPILAN GRID VIEW (YANG KITA PERBAIKI)
    // ==========================================
    if (isGrid) {
      return Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KUNCI PERBAIKAN: STACK
                Stack(
                  children: [
                    // 1. Gambar / Kotak Warna
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: !isArtist
                              ? (title == 'New Episodes'
                                    ? BorderRadius.circular(12)
                                    : null)
                              : null,
                          shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
                          color: containerGradient == null ? containerColor : null,
                          gradient: containerGradient,
                          image: imagePath != null
                              ? DecorationImage(
                                  image: AssetImage(imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        // Logic: Kalau gak ada imagePath, tampilkan iconInContainer
                        child: imagePath == null
                            ? Center(
                                child: Transform.scale(
                                  scale: 2,
                                  child: iconInContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
          
                    // 2. Icon Pin (Overlay di atas gambar)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: isPinnedIcon
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black45, // Biar kelihatan jelas
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.push_pin,
                                color: Colors.green,
                                size: 16,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
          
                const SizedBox(height: 8),
          
                // Judul
                Text(
                  title,
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          
                // Subtitle
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ==========================================
    // TAMPILAN LIST VIEW (AMAN)
    // ==========================================
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
          onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== GAMBAR ==========
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: !isArtist
                      ? (title == 'New Episodes' ? BorderRadius.circular(12) : null)
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: titleColor)),
                    Row(
                      children: <Widget>[
                        if (isPinnedIcon)
                          Icon(
                            isPinnedIcon ? Icons.push_pin : null,
                            color: Colors.green,
                            size: 16,
                          ),
                        Text(
                          subtitle,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
