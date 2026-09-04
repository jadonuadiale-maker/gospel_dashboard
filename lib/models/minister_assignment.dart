import 'audio_item.dart';

/// A single track's minister/artist label. One assignment per track —
/// setting a new minister for a track replaces any previous one.
class MinisterAssignment {
  final String category;
  final String ministerName;
  final AudioItem item;

  MinisterAssignment({
    required this.category,
    required this.ministerName,
    required this.item,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'ministerName': ministerName,
        'item': item.toJson(),
      };

  factory MinisterAssignment.fromJson(Map<String, dynamic> json) =>
      MinisterAssignment(
        category: json['category'] as String,
        ministerName: json['ministerName'] as String,
        item: AudioItem.fromJson(json['item'] as Map<String, dynamic>),
      );
}