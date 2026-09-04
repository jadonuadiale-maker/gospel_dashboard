import 'audio_item.dart';

class Playlist {
  final String name;
  final String category; // "Hymn", "Sermon", "Song", or "Message"
  final List<AudioItem> tracks;

  Playlist({
    required this.name,
    required this.category,
    List<AudioItem>? tracks,
  }) : tracks = tracks ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'tracks': tracks.map((t) => t.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        name: json['name'] as String,
        category: json['category'] as String,
        tracks: (json['tracks'] as List)
            .map((t) => AudioItem.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}