class SongModel {
  final String title;
  final String artist;
  final String imageUrl;
  
    SongModel({
    required this.title,
    required this.artist,
    required this.imageUrl,
    
  });

  Map<String, dynamic> toMap() => {
    'title': 'title',
    'artist': 'artist',
    'imageUrl': 'imageUrl',
    // 'audiioUrl': 'audioUrl',
  };

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      title: map['title'],
      artist: map['artist'],
      imageUrl: map['imageUrl'],
      // audioUrl: map['audioUrl'],
    );
  }
}
