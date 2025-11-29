import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';
import 'package:percobaan/models/song_model.dart';

final SongModel laguAboutYou = SongModel(
  title: 'About You',
  artist: 'The 1975',
  imageUrl: 'images/mini_dragon.jpg',
  audioUrl: 'audio/about_you.mp3',
);
final SongModel lagu18 = SongModel(
  title: '18',
  artist: 'One Direction',
  imageUrl: 'images/mini_dragon.jpg',
  audioUrl: 'audio/about_you.mp3',
);
final SongModel laguWhatMakesYouBeautiful = SongModel(
  title: 'What Makes You Beautiful',
  artist: 'One Direction',
  imageUrl: 'images/mini_dragon.jpg',
  audioUrl: 'audio/about_you.mp3',
);

final List<LibraryItem> defaultItems = [
  LibraryItem(
    title: 'Liked Songs',
    containerGradient: LinearGradient(
      colors: [Colors.deepPurpleAccent.shade400, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    iconInContainer: Icon(Icons.favorite, size: 30.0, color: Colors.white),
    titleColor: Colors.white,
    subtitle: 'Playlists • 114 songs',
    containerColor: null,
    category: 'Playlists',
    songs: [laguWhatMakesYouBeautiful, lagu18],

  ),
  LibraryItem(
    title: 'New Episodes',
    iconInContainer: Icon(
      Icons.notifications,
      size: 30.0,
      color: Color(0xFF1ED760),
    ),
    titleColor: Colors.white,
    subtitle: 'Updated Jan 25, 2025',
    containerColor: Color(0xFF5E3DB3),
    category: 'Playlists',
    songs: [laguAboutYou],
  ),
  LibraryItem(
    title: 'Your Episodes',
    iconInContainer: Icon(Icons.bookmark, size: 30.0, color: Color(0xFF1ED760)),
    titleColor: Colors.white,
    subtitle: 'Playlists • Saved & downloaded episodes',
    containerColor: Colors.green.shade900,
    category: 'Playlists',
    songs: [],
  ),
  LibraryItem(
    title: 'Downloads',
    iconInContainer: Icon(Icons.download, size: 30.0, color: Color(0xFF1ED760)),
    titleColor: Colors.white,
    subtitle: 'Playlists • Download',
    containerColor: Colors.green.shade900,
    category: 'Playlists',
    songs: [],
  ),
  
];
