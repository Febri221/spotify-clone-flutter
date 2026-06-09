import 'package:hive/hive.dart';

// WAJIB ADA: Ini ngasih tau Flutter buat nyari file "stempel" yang nanti di-generate.
// Namanya harus sama persis kayak nama file lu ini, cuma ditambahin '.g'

// biar kaga merah ketik ini di terminal supaya muncul file baru "flutter pub run build_runner build --delete-conflicting-outputs"
part '../../models/rekap_model.g.dart'; 

@HiveType(typeId: 1) // ID Kardus. Kalau lu punya model Hive lain, angkanya gak boleh sama.
class DailyLog {
  @HiveField(0) // Nomor urut laci
  String songId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String artist;

  @HiveField(3)
  DateTime playDate;

  DailyLog({
    required this.songId,
    required this.title,
    required this.artist,
    required this.playDate,
  });
}