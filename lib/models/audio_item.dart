class AudioItem {
  final String title;       // Display name
  final String url;         // Asset path (also the unique identifier)
  final String category;    // Sermon, Song, Message, or Hymn

  AudioItem({
    required this.title,
    required this.url,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'category': category,
      };

  factory AudioItem.fromJson(Map<String, dynamic> json) => AudioItem(
        title: json['title'] as String,
        url: json['url'] as String,
        category: json['category'] as String,
      );
}