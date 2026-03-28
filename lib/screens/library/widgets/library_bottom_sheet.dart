import 'package:flutter/material.dart';

class LibraryBottomSheet {
  // Tambahkan parameter opsional 'onRename' di akhir
  static Future<void> show(
    BuildContext context, 
    dynamic item, 
    VoidCallback onPinToggled, 
    {VoidCallback? onRename} // <--- Parameter Baru (Opsional)
  ) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black54, // Sedikit gelap biar fokus
      backgroundColor: Colors.transparent,
      builder: (context) {
        
        // LOGIC PEMBERSIH JUDUL (Biar di header sheet gak ada angkanya)
        String displayTitle = item.title;
        if (displayTitle.contains('__')) {
          displayTitle = displayTitle.split('__')[0];
        }

        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF191414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Garis kecil di atas (Handle)
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header Info Item
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: item.containerGradient == null ? item.containerColor : null,
                        gradient: item.containerGradient,
                        image: item.imagePath != null
                            ? DecorationImage(image: AssetImage(item.imagePath!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: item.imagePath == null ? item.iconInContainer : null,
                    ),
                    // Pakai judul yang sudah bersih
                    title: Text(displayTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subtitle, style: TextStyle(color: Colors.grey)),
                  ),
                  Divider(color: Colors.grey[800]),

                  // Menu Pin/Unpin
                  ListTile(
                    leading: Icon(
                      item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      item.isPinned ? "Unpin Playlist" : "Pin Playlist",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context); 
                      onPinToggled();
                    },
                  ),

                  // MENU RENAME (Hanya muncul jika onRename dikirim)
                  if (onRename != null) 
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.white),
                      title: Text("Edit playlist", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Tutup sheet dulu
                        onRename(); // Panggil dialog rename
                      },
                    ),

                  // Menu Share
                  ListTile(
                    leading: Icon(Icons.share, color: Colors.white),
                    title: Text("Share", style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ], 
        );
      },
    );
  }
}