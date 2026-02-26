import 'package:flutter/material.dart';
import 'package:percobaan/models/song_model.dart';

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
  final Function(bool)? onTouch;

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
    this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    // 1. SETTING EFEK TELEGRAM (SOFT)
    // Opacity 0.1 itu soft banget. Kalau kurang terang, naikin ke 0.15 atau 0.2
    final overlayColor = isHighlighted ? Colors.white.withOpacity(0.1) : Colors.transparent;
    
    bool isArtist = subtitle.contains('Artist');
    
    // Logic Radius biar overlay ngikutin bentuk gambar (Bulat/Kotak)
    final imageBorderRadius = !isArtist
        ? (title == 'New Episodes' ? BorderRadius.circular(12) : BorderRadius.zero)
        : null; 
    
    final imageShape = isArtist ? BoxShape.circle : BoxShape.rectangle;

    // ==========================================
    // TAMPILAN GRID VIEW
    // ==========================================
    if (isGrid) {
      return Material(
        color: Colors.transparent, 
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          
          // ANTI DOUBLE: Matikan efek bawaan
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onHighlightChanged: (isDown) {
            if (onTouch != null) {
              onTouch!(isDown);
            }
          },
          
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // A. GAMBAR
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: imageBorderRadius,
                          shape: imageShape,
                          color: containerGradient == null ? containerColor : null,
                          gradient: containerGradient,
                          image: imagePath != null
                              ? DecorationImage(
                                  image: AssetImage(imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
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

                    // B. OVERLAY CAHAYA (TELEGRAM STYLE)
                    // Ini ditaruh DI ATAS gambar. 
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 100), // Animasi halus dikit
                        decoration: BoxDecoration(
                          color: overlayColor, // Putih Soft (0.1)
                          borderRadius: imageBorderRadius,
                          shape: imageShape,
                        ),
                      ),
                    ),

                    // C. ICON PIN
                    Positioned(
                      top: 4,
                      right: 4,
                      child: isPinnedIcon
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
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
                Text(
                  title,
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
    // TAMPILAN LIST VIEW (SAMA RATAKAN LOGICNYA)
    // ==========================================
    return Material(
      // Background row ikut nyala soft (untuk area teks)
      color: overlayColor, 
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        
        // ANTI DOUBLE
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHighlightChanged: (isDown) {
            if (onTouch != null) {
              onTouch!(isDown);
            }
          },
        
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. GAMBAR DENGAN OVERLAY
              Stack(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: imageBorderRadius,
                      shape: imageShape,
                      color: containerGradient == null ? containerColor : null,
                      gradient: containerGradient,
                    ),
                    child: imagePath != null
                        ? (isArtist
                            ? ClipOval(child: Image.asset(imagePath!, fit: BoxFit.cover))
                            : ClipRRect(child: Image.asset(imagePath!, fit: BoxFit.cover)))
                        : Center(child: iconInContainer),
                  ),

                  // B. OVERLAY CAHAYA DI GAMBAR (WAJIB ADA BIAR GAMBAR GAK GELAP SENDIRIAN)
                  Positioned.fill(
                     child: AnimatedContainer(
                        duration: Duration(milliseconds: 50),
                        decoration: BoxDecoration(
                          color: overlayColor, // Putih Soft (0.1)
                          borderRadius: imageBorderRadius,
                          shape: imageShape,
                        ),
                     ),
                  )
                ],
              ),
              
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