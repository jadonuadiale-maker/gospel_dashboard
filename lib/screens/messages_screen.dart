import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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
    final messages = [
      AudioItem(
        title: "The Purpose of your Life - Dr Myles Munroe",
        url: "assets/messages/Dr-Myles-Munroe-_-The-purpose-for-your-life-64-kbps-2.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "10 Principles of a Future Leader - Dr Myles Munroe",
        url: "assets/messages/Dr-Myles-Munroe-10-Principles-and-marks-of-a-Future-leader-64-kbps.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "10 Principles for Leadership Development - Dr Myles Munroe",
        url: "assets/messages/DR-Myles-Munroe-10-PRINCIPLES-FOR-LEADERSHIP-DEVELOPMENT-NEW-RELEASE-2017-64-kbps.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "How to become a Leader - Dr Myles Munroe",
        url: "assets/messages/Dr-Myles-Munroe-HOW-TO-BECOME-A-LEADER-Break-away-from-your-struggling-mindset-POWERFUL-64-kbps.mp3",
        category: "Message",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final item = messages[index];
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