import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    final songs = [
      AudioItem(
        title: "Jehovah Jireh - Don Moen",
        url: "assets/songs/06 Jehovah-Jireh (Live).mp3",
        category: "Song",
      ),
      AudioItem(
        title: "Emmanuel - John Fadejola",
        url: "assets/songs/Direct-Lyrics-John-Fadejola-Emmanuel-Es-Lyrics-(CeeNaija.com).mp3",
        category: "Song",
      ),
      AudioItem(
        title: "The Blessing - Elevation Worship",
        url: "assets/songs/The Blessing - Kari Jobe, Cody Carnes & Elevation Worship [www.AmenRadio.net].mp3",
        category: "Song",
      ),
      AudioItem(
        title: "I Give Myself Away - Williams McDowell",
        url: "assets/songs/Williams_McDowell_-_I_Give_Myself_Away_CeeNaija.com_.mp3",
        category: "Song",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Songs")),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final item = songs[index];
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
