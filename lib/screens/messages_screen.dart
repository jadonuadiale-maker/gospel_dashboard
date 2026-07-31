import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    final messages = [
      AudioItem(
        title: "The Purpose of your Life - Dr Myles Munroe",
        url:"assets/messages/Dr-Myles-Munroe-_-The-purpose-for-your-life-64-kbps-2.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "10 Principles of a Future Leader - Dr Myles Munroe",
        url:"assets/messages/Dr-Myles-Munroe-10-Principles-and-marks-of-a-Future-leader-64-kbps.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "10 Principles for Leadership Development - Dr Myles Munroe",
        url:"assets/messages/DR-Myles-Munroe-10-PRINCIPLES-FOR-LEADERSHIP-DEVELOPMENT-NEW-RELEASE-2017-64-kbps.mp3",
        category: "Message",
      ),
      AudioItem(
        title: "How to become a Leader - Dr Myles Munroe",
        url:"assets/messages/Dr-Myles-Munroe-HOW-TO-BECOME-A-LEADER-Break-away-from-your-struggling-mindset-POWERFUL-64-kbps.mp3",
        category: "Message",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final item = messages[index];
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
