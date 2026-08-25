// lib/widgets/track_modal_player.dart
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class TrackModalPlayer extends StatelessWidget {
  final AudioService audio;

  const TrackModalPlayer({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    final isPlaying = audio.isPlaying;
    final currentUrl = audio.currentUrl ?? "No track selected";

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentUrl.split('/').last,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 60,
                color: Colors.blueAccent,
              ),
              onPressed: audio.togglePlayPause,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}