class AudioItem {
  final String title;       // Display name
  final String url;         // MP3 source
  final String category;    // Sermon, Song, or Message

  AudioItem({
    required this.title,
    required this.url,
    required this.category,
  });
}