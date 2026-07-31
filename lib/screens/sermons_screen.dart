import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class SermonsScreen extends StatelessWidget {
  const SermonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService(); // Local audio engine

    final sermons = [
      AudioItem(
        title: "The Spirit of Innovation - Dr Myles Munroe",
        url: "assets/sermons/Dr-Myles-Munroe-Have-The-Spirit-of-Innovation-Power-of-Vision-64-kbps.mp3",
        category: "Sermon",
      ),
      AudioItem(
        title: "God's Original Intent - Dr Myles Munroe",
        url: "assets/sermons/Gods-Original-Intent-_-Dr.-Myles-Munroe-64-kbps.mp3",
        category: "Sermon",
      ),
      AudioItem(
        title: "Kingdom Authority - Dr Myles Munroe",
        url: "assets/sermons/KINGDOM-AUTHORITY-by-Dr.-Myles-Munroe-64-kbps.mp3",
        category: "Sermon",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sermons")),
      body: ListView.builder(
        itemCount: sermons.length,
        itemBuilder: (context, index) {
          final item = sermons[index];
          return ListTile(
            title: Text(item.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(audio: audio, url: item.url),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
