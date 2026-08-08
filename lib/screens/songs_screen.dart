import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final audio = AudioService();
  late StreamSubscription _audioSub;

  @override
  void initState() {
    super.initState();
    _audioSub = audio.stateStream.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _audioSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = [
      AudioItem(
        title: "Jehovah Jireh - Don Moen",
        url: "assets/songs/06 Jehovah-Jireh (Live).opus",
        category: "Song",
      ),
      AudioItem(
        title: "Emmanuel - John Fadejola",
        url: "assets/songs/Direct-Lyrics-John-Fadejola-Emmanuel-Es-Lyrics-(CeeNaija.com).opus",
        category: "Song",
      ),
      AudioItem(
        title: "The Blessing - Elevation Worship",
        url: "assets/songs/The Blessing - Kari Jobe, Cody Carnes & Elevation Worship [www.AmenRadio.net].opus",
        category: "Song",
      ),
      AudioItem(
        title: "I Give Myself Away - Williams McDowell",
        url: "assets/songs/Williams_McDowell_-_I_Give_Myself_Away_CeeNaija.com_.opus",
        category: "Song",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Songs")),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final item = songs[index];
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