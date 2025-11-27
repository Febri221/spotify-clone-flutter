import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';
import 'package:percobaan/data/dummy_songs.dart';
import 'package:percobaan/widget/library_item_class.dart';

class PlaylistDetailPage extends StatelessWidget {
  final LibraryItem playlistItem;



  PlaylistDetailPage({required this.playlistItem, });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(playlistItem.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: dummySongs.length,
        itemBuilder: (context, index) {
          final song = dummySongs[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                song.imageUrl,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(song.title, style: TextStyle(color: Colors.white),),
            subtitle: Text(song.artist, style: TextStyle(color: Colors.white70),),
            trailing: Icon(Icons.play_arrow, color: Colors.white,),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}
