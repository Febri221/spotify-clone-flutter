import 'package:flutter/material.dart';

class LibraryBottomSheet {
  // Kita butuh context, item datanya, dan fungsi buat nge-Pin
  static void show(BuildContext context, dynamic item, VoidCallback onPinToggled) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF191414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ListView(
                controller: controller,
                children: [
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
                    title: Text(item.title, style: TextStyle(color: Colors.white)),
                    subtitle: Text(item.subtitle, style: TextStyle(color: Colors.white)),
                  ),
                  Divider(color: Colors.grey),
                  // Menu Pin/Unpin
                  ListTile(
                    leading: Icon(
                      item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: Colors.green,
                    ),
                    title: Text(
                      item.isPinned ? "Unpin Playlist" : "Pin Playlist",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Tutup sheet
                      onPinToggled(); // Jalankan fungsi Pin di LibraryPage
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.share, color: Colors.green),
                    title: Text("Share", style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}