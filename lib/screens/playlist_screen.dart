// lib/screens/playlist_screen.dart
import 'package:flutter/material.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Placeholder playlists (Segment 1: structure only) ---
    final playlists = [
      "Morning Worship",
      "Leadership Nuggets",
      "Favourite Sermons",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Playlists")),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final name = playlists[index];

          return ListTile(
            title: Text(name),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/playlist/detail',
                arguments: name, // NEW
              );
            },
          );
        },
      ),
    );
  }
}