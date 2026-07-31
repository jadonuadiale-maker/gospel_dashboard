import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // Simple loading notifier
  bool isLoading = false;

  Future<void> playUrl(String url) async {
  try {
    isLoading = true;
    if (url.startsWith('assets/')) {
      await _player.setAsset(url);   // Local asset
    } else {
      await _player.setUrl(url);     // Remote URL
    }
    await _player.play();
  } catch (e) {
    print("Audio error: $e");
  } finally {
    isLoading = false;
  }
}

  Future<void> seek(Duration position) async {
  await _player.seek(position);
  }

  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
}
