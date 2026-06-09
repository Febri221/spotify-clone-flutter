import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percobaan/core/constants/app_constants.dart';
import 'package:percobaan/data/models/rekap_model.dart';

class DailyLogService {
  Box<DailyLog> get _box => Hive.box<DailyLog>(AppConstants.dailyLogsBox);

  void saveLog(SongModel song) {
    final log = DailyLog(
      songId: song.id.toString(),
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      playDate: DateTime.now(),
    );
    _box.add(log);
  }

  List<DailyLog> getLogs() => _box.values.toList();
}