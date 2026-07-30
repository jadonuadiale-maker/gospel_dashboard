import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();   // Core audio engine

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);               // Load remote MP3
      await _player.play();                    // Begin playback
    } catch (e) {
      print("Audio error: $e");                // Minimal error logging
    }
  }

  Future<void> pause() async {
    await _player.pause();                     // Pause playback
  }

  Future<void> stop() async {
    await _player.stop();                      // Stop + reset
  }
}
