import 'package:flutter/material.dart';
import '../models/audio_item.dart';

class AudioTile extends StatelessWidget {
  final AudioItem item;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenPlayer;

  const AudioTile({
    super.key,
    required this.item,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onOpenPlayer,
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
        // Tap anywhere → open PlayerScreen
        onTap: onOpenPlayer,
        child: Row(
          children: [
            // --- Play/Pause icon moved to the left ---
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 42,
                color: Colors.blueAccent,
              ),
              // Tap icon → toggle playback
              onPressed: onPlayPause,
            ),

            const SizedBox(width: 16),

            // --- Track title and category context ---
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
          ],
        ),
      ),
    );
  }
}