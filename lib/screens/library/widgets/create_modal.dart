import 'package:flutter/material.dart';

class CreateModal {
  static void show(
    BuildContext context,
    Function(String, String) onItemCreated,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 250,
        decoration: BoxDecoration(
          color: Color(0xFF191414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Create New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildAddButton(
                  label: "Playlist",
                  shape: BoxShape.rectangle,
                  icon: Icons.music_note,
                  onTap: () {
                    Navigator.pop(context);
                    onItemCreated("Playlist Baru", "Playlists");
                  },
                ),
                _buildAddButton(
                  label: "Artist",
                  shape: BoxShape.circle,
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    onItemCreated("Artist Baru", "Artists");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAddButton({
    required String label,
    required BoxShape shape,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: shape,
              color: Colors.grey[800],
              borderRadius: shape == BoxShape.rectangle
                  ? BorderRadius.circular(10)
                  : null,
              border: Border.all(color: Colors.white54),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 35)),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
