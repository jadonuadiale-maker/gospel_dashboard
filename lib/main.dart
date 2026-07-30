import 'package:flutter/material.dart';
import 'services/audio_service.dart';

void main() {
  runApp(const GospelDashboardApp());
}

class GospelDashboardApp extends StatelessWidget {
  const GospelDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestAudioScreen(),                 // Temporary test screen
    );
  }
}

class TestAudioScreen extends StatelessWidget {
  final AudioService audio = AudioService();   // Inject audio service

  final String testUrl =
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; 
      // Replace with sermon/song MP3 later

  TestAudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => audio.playUrl(testUrl),
              child: const Text("Play"),
            ),
            ElevatedButton(
              onPressed: () => audio.pause(),
              child: const Text("Pause"),
            ),
            ElevatedButton(
              onPressed: () => audio.stop(),
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
