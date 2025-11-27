import 'package:flutter/material.dart';
import 'package:percobaan/widget/library_item_class.dart';

final List<LibraryItem> items = [
    LibraryItem(
      title: 'Liked Songs',
      containerGradient: LinearGradient(
        colors: [Colors.deepPurpleAccent.shade400, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconInContainer: Icon(Icons.favorite, size: 40.0, color: Colors.white),
      titleColor: Colors.white,
      subtitle: 'Playlists • 114 songs',
      containerColor: null,
      category: 'Playlists',
    ),
    LibraryItem(
      title: 'New Episodes',
      iconInContainer: Icon(
        Icons.notifications,
        size: 40.0,
        color: Color(0xFF1ED760),
      ),
      titleColor: Colors.white,
      subtitle: 'Updated Jan 25, 2025',
      containerColor: Color(0xFF5E3DB3),
      category: 'Playlists',
    ),
    LibraryItem(
      title: 'Your Episodes',
      iconInContainer: Icon(
        Icons.bookmark,
        size: 40.0,
        color: Color(0xFF1ED760),
      ),
      titleColor: Colors.white,
      subtitle: 'Playlists • Saved & downloaded episodes',
      containerColor: Colors.green.shade900,
      category: 'Playlists',
    ),
    LibraryItem(
      title: 'Naruto Shippuden Openings 1-20',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Playlists • urgrandpaold',
      category: 'Playlists',
    ),
    LibraryItem(
      title: 'Codieng',
      imagePath: 'images/mini_dragon.jpg',
      titleColor: Colors.white,
      subtitle: 'Playlists • Mfebriansyah',
      category: 'Playlists',
    ),
    LibraryItem(
      title: 'TakaseToya',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Artist',
      category: 'Artists',
    ),
    LibraryItem(
      title: 'TakaseToya',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Artist',
      category: 'Artists',
    ),
    LibraryItem(
      title: 'Gema Membiru',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Updated Jan 25,2025 • Firdhani Zihan',
      category: 'Podcasts',
    ),
    LibraryItem(
      title: 'Gema Membiru',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Updated Jan 25,2025 • Firdhani Zihan',
      category: 'Podcasts',
    ),
    LibraryItem(
      title: 'Gema Membiru',
      imagePath: 'images/naruto.jpeg',
      titleColor: Colors.white,
      subtitle: 'Updated Jan 25,2025 • Firdhani Zihan',
      category: 'Podcasts',
    ),
  ];