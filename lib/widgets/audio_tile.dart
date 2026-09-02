// lib/widgets/audio_tile.dart
import 'package:flutter/material.dart';
import '../models/audio_item.dart';

class AudioTile extends StatelessWidget {
  final AudioItem item;
  final bool isPlaying;
  final bool isFavourite;
  final VoidCallback onPlayPause;
  final VoidCallback onSelectTrack;
  final VoidCallback onToggleFavourite;

  const AudioTile({
    super.key,
    required this.item,
    required this.isPlaying,
    required this.isFavourite,
    required this.onPlayPause,
    required this.onSelectTrack,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 3),
            color: Colors.black12,
          ),
        ],
      ),
      child: InkWell(
        onTap: onSelectTrack,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 42,
                color: Colors.blueAccent,
              ),
              onPressed: onPlayPause,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.redAccent : Colors.grey.shade400,
              ),
              onPressed: onToggleFavourite,
            ),
          ],
        ),
      ),
    );
  }
}