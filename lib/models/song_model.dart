class SongModelBuatanSendiri {
  final String title;
  final String artist;
  final String imageUrl;
  final String? audioUrl;
  
    SongModelBuatanSendiri({
    required this.title,
    required this.artist,
    required this.imageUrl,
     this.audioUrl,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'artist': artist,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
  };

  factory SongModelBuatanSendiri.fromMap(Map<String, dynamic> map) {
    return SongModelBuatanSendiri(
      title: map['title'],
      artist: map['artist'],
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
    );
  }
}
