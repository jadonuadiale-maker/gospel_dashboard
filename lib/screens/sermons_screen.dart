import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final audio = AudioService();

  @override
  void initState() {
    super.initState();
    audio.stateStream.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
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
          final isCurrent = audio.currentUrl == item.url;
          final isPlaying = audio.isPlaying && isCurrent;

          return ListTile(
            title: Text(item.title),
            trailing: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: () {
                if (!isCurrent) {
                  audio.playUrl(item.url);
                } else {
                  audio.togglePlayPause();
                }
              },
            ),
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
