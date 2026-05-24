import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';


class SongProvider with ChangeNotifier {
   List<SongModel> _globalSongs = [];
  bool _isLoadingSongs = true;
  

  List<SongModel> get globalSongs => _globalSongs;
  bool get isLoadingSongs => _isLoadingSongs;


   Future<void> fetchGlobalSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    bool hasPermission = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (await Permission.audio.status.isGranted) {
          hasPermission = true;
        } else {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.audio,
            Permission.photos,
          ].request();

          if (statuses[Permission.audio]!.isGranted) hasPermission = true;
        }
      } else {
        if (await Permission.storage.status.isGranted) {
          hasPermission = true;
        } else {
          var status = await Permission.storage.request();
          if (status.isGranted) hasPermission = true;
        }
      }
    }
    if (!hasPermission) {
      _isLoadingSongs = false;
      notifyListeners();
      return;
    }

    try {
      List<SongModel> songs = await audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      List<SongModel> cleanSongs = songs.where((song) {
        String name = song.displayName.toLowerCase();
        int duration = song.duration ?? 0;
        String path = song.data.toLowerCase();
        return name.endsWith('.mp3') &&
            duration > 4500 &&
            !path.contains('whatsapp');
      }).toList();

      _globalSongs = cleanSongs;
      _isLoadingSongs = false;
      notifyListeners();

    } catch (e) {
      debugPrint('Error fetching songs: $e');
    }
  }
}
