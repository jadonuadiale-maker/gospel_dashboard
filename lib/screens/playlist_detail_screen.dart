// lib/screens/playlist_detail_screen.dart
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Untitled Playlist';
    final audio = AudioService();

    final tracks = ["Track 1", "Track 2", "Track 3"];

    return Scaffold(
      appBar: AppBar(title: Text(playlistName)),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final name = tracks[index];
          return ListTile(
            title: Text(name),
            onTap: () {
              // later: hook into real AudioItem list
            },
          );
        },
      ),
      // global MiniPlayer handles playback UI
    );
  }
}