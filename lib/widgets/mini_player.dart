// lib/widgets/mini_player.dart
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class MiniPlayer extends StatelessWidget {
  final AudioService audio;

  const MiniPlayer({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    final isPlaying = audio.isPlaying;
    final title = audio.currentUrl!.split('/').last;

    return GestureDetector(
      onTap: () {
        // IMPORTANT: use rootNavigator to ensure navigation works
        Navigator.of(context, rootNavigator: true).pushNamed('/player');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 3),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 26,
                color: Colors.greenAccent.shade400,
              ),
              onPressed: audio.togglePlayPause,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.expand_less, size: 24),
          ],
        ),
      ),
    );
  }
}