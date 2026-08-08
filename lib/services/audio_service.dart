import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    _player.playerStateStream.listen((_) {
      _stateController.add(null);
    });
  }

  final AudioPlayer _player = AudioPlayer(
    handleInterruptions: false,
    androidApplyAudioAttributes: false,
  );

  bool isLoading = false;
  String? currentUrl;

  final _stateController = StreamController<void>.broadcast();
  Stream<void> get stateStream => _stateController.stream;

  bool get isPlaying => _player.playing;

  Future<void> playUrl(String url) async {
    final isSameTrack = currentUrl == url;

    if (!isSameTrack) {
      await _player.stop();
      currentUrl = url;
      isLoading = true;
      _stateController.add(null);

      try {
        if (url.startsWith('assets/')) {
          await _player.setAsset(url);
        } else {
          await _player.setUrl(url);
        }

        // Preload decoded frames before playback
        await _player.load();

        // Optional small runtime boost
        _player.setVolume(1.15);

      } catch (e) {
        print("Audio error: $e");
      } finally {
        isLoading = false;
        _stateController.add(null);
      }
    }

    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (currentUrl != null) {
        await _player.play();
      }
    }
    _stateController.add(null);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _stateController.add(null);
  }

  Future<void> rewind15() async {
    final current = _player.position;
    final newPos = current - const Duration(seconds: 15);
    await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
    _stateController.add(null);
  }

  Future<void> forward15() async {
    final current = _player.position;
    final total = _player.duration ?? Duration.zero;
    final newPos = current + const Duration(seconds: 15);
    await _player.seek(newPos > total ? total : newPos);
    _stateController.add(null);
  }

  Future<void> stop() async {
    await _player.stop();
    currentUrl = null;
    _stateController.add(null);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
}