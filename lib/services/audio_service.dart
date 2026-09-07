import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:audio_service/audio_service.dart' as pkg_audio_service;
   import 'package:audio_session/audio_session.dart';

class PlaybackAudioHandler extends pkg_audio_service.BaseAudioHandler
    with pkg_audio_service.QueueHandler, pkg_audio_service.SeekHandler {
  final SoLoud _soloud = SoLoud.instance;

  AudioSource? _currentSource;
  SoundHandle? _currentHandle;
  String? _currentUrl;
  bool _isLoading = false;

  Timer? _positionTimer;

  final _stateController = StreamController<void>.broadcast();
  Stream<void> get stateStream => _stateController.stream;

  final _positionController = StreamController<Duration>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  final _durationController = StreamController<Duration?>.broadcast();
  Stream<Duration?> get durationStream => _durationController.stream;

  Duration? _lastDuration;
  Duration _lastPosition = Duration.zero;
  Duration? get currentDuration => _lastDuration;
  Duration get currentPosition => _lastPosition;

  String? get currentUrl => _currentUrl;
  bool get isLoading => _isLoading;

  bool get isPlaying =>
      _currentHandle != null &&
      _soloud.getIsValidVoiceHandle(_currentHandle!) &&
      !_soloud.getPause(_currentHandle!);

  late final Future<void> _initFuture;

  PlaybackAudioHandler() {
     _initFuture = _initAudio();
   }

  Future<void> _initAudio() async {
     final session = await AudioSession.instance;
     await session.configure(const AudioSessionConfiguration.music());
     await session.setActive(true);
     await _soloud.init();
   }

  /// Loads and plays [assetPath]. [streaming] controls whether the file is
  /// fully decoded into memory (fast start, ideal for short tracks like
  /// hymns/songs) or streamed from disk in chunks (much faster start for
  /// long spoken-word content like messages/sermons, avoiding a slow
  /// upfront decode of 30-60+ minutes of audio).
  Future<void> playTrack(
    String assetPath, {
    String? title,
    bool streaming = false,
  }) async {
    await _initFuture;

    final isSameTrack = _currentUrl == assetPath;

    if (!isSameTrack) {
      await _stopInternal();

      _currentUrl = assetPath;
      _isLoading = true;
      _stateController.add(null);

      try {
        _currentSource = await _soloud.loadAsset(
          assetPath,
          mode: streaming ? LoadMode.disk : LoadMode.memory,
        );

        final duration = _soloud.getLength(_currentSource!);
        _lastDuration = duration;
        _durationController.add(duration);

        _currentHandle = _soloud.play(_currentSource!);

        mediaItem.add(pkg_audio_service.MediaItem(
          id: assetPath,
          title: title ?? assetPath.split('/').last,
          duration: duration,
        ));

        _broadcastPlaybackState();
        _startPositionPolling();
      } catch (e) {
        print("Audio error on $assetPath: $e");
      } finally {
        _isLoading = false;
        _stateController.add(null);
      }
    } else {
      await play();
    }
  }

  /// SoLoud is a low-level engine and has no built-in position stream
  /// (unlike just_audio). We poll on a short interval and republish it
  /// ourselves so the PlayerScreen's slider stays reactive.
  void _startPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_currentHandle == null || !_soloud.getIsValidVoiceHandle(_currentHandle!)) {
        // Track finished naturally (or was stopped elsewhere) — stop polling.
        _positionTimer?.cancel();
        _stateController.add(null);
        return;
      }
      final pos = _soloud.getPosition(_currentHandle!);
      _lastPosition = pos;
      _positionController.add(pos);

      // Re-check duration periodically. With LoadMode.disk, the initial
      // length reading right after load can be an early/partial estimate
      // for streamed files — this keeps it in sync as more of the file
      // becomes known, and self-corrects the seek bar.
      if (_currentSource != null) {
        final currentLength = _soloud.getLength(_currentSource!);
        if (currentLength != _lastDuration) {
          _lastDuration = currentLength;
          _durationController.add(currentLength);
        }
      }
    });
  }

  /// Pushes current state to the OS notification/lock screen. Called only
  /// on discrete events (play/pause/seek/track change) — NOT every tick —
  /// per audio_service's own guidance: the OS can project position forward
  /// on its own between updates.
  void _broadcastPlaybackState() {
    final pos = _currentHandle != null && _soloud.getIsValidVoiceHandle(_currentHandle!)
        ? _soloud.getPosition(_currentHandle!)
        : Duration.zero;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        pkg_audio_service.MediaControl.rewind,
        isPlaying ? pkg_audio_service.MediaControl.pause : pkg_audio_service.MediaControl.play,
        pkg_audio_service.MediaControl.stop,
        pkg_audio_service.MediaControl.fastForward,
      ],
      systemActions: const {
        pkg_audio_service.MediaAction.seek,
        pkg_audio_service.MediaAction.seekForward,
        pkg_audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: _isLoading
          ? pkg_audio_service.AudioProcessingState.loading
          : pkg_audio_service.AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: pos,
      speed: 1.0,
    ));
  }

  @override
  Future<void> play() async {
    if (_currentHandle != null &&
        _soloud.getIsValidVoiceHandle(_currentHandle!) &&
        _soloud.getPause(_currentHandle!)) {
      _soloud.pauseSwitch(_currentHandle!);
    }
    _broadcastPlaybackState();
    _stateController.add(null);
  }

  @override
  Future<void> pause() async {
    if (_currentHandle != null &&
        _soloud.getIsValidVoiceHandle(_currentHandle!) &&
        !_soloud.getPause(_currentHandle!)) {
      _soloud.pauseSwitch(_currentHandle!);
    }
    _broadcastPlaybackState();
    _stateController.add(null);
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_currentHandle != null && _soloud.getIsValidVoiceHandle(_currentHandle!)) {
      _soloud.seek(_currentHandle!, position);
      _lastPosition = position;
      _positionController.add(position);
      _broadcastPlaybackState();
    }
  }

  Future<void> rewind15() async {
    if (_currentHandle == null) return;
    final current = _soloud.getPosition(_currentHandle!);
    final newPos = current - const Duration(seconds: 15);
    await seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> forward15() async {
    if (_currentHandle == null || _currentSource == null) return;
    final current = _soloud.getPosition(_currentHandle!);
    final total = _soloud.getLength(_currentSource!);
    final newPos = current + const Duration(seconds: 15);
    await seek(newPos > total ? total : newPos);
  }

  Future<void> _stopInternal() async {
    _positionTimer?.cancel();
    if (_currentHandle != null && _soloud.getIsValidVoiceHandle(_currentHandle!)) {
      await _soloud.stop(_currentHandle!);
    }
    if (_currentSource != null) {
      await _soloud.disposeSource(_currentSource!);
    }
    _currentHandle = null;
    _currentSource = null;
  }

  @override
  Future<void> stop() async {
    await _stopInternal();
    _currentUrl = null;
    _lastDuration = null;
    _lastPosition = Duration.zero;
    _durationController.add(null);
    _broadcastPlaybackState();
    _stateController.add(null);
    await super.stop();
  }
}

/// App-facing singleton — same public shape as the old just_audio-based
/// AudioService, so PlayerScreen, MiniPlayer, and every category screen
/// (hymns/sermons/songs/messages) work completely unchanged.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late final PlaybackAudioHandler _handler;
  bool _initialized = false;

  /// Must be awaited once in main(), before runApp(). Not named `init`
  /// to avoid confusion with the audio_service package's own
  /// `AudioService.init(...)` static method.
  Future<void> bootstrap() async {
    if (_initialized) return;

    _handler = await pkg_audio_service.AudioService.init(
      builder: () => PlaybackAudioHandler(),
      config: const pkg_audio_service.AudioServiceConfig(
        androidNotificationChannelId: 'com.gospeldashboard.channel.audio',
        androidNotificationChannelName: 'Gospel Dashboard Playback',
        androidNotificationOngoing: true,
      ),
    );

    _initialized = true;
  }

  String? get currentUrl => _handler.currentUrl;
  bool get isPlaying => _handler.isPlaying;
  bool get isLoading => _handler.isLoading;
  Duration? get currentDuration => _handler.currentDuration;
  Duration get currentPosition => _handler.currentPosition;

  Stream<void> get stateStream => _handler.stateStream;
  Stream<Duration> get positionStream => _handler.positionStream;
  Stream<Duration?> get durationStream => _handler.durationStream;

  Future<void> playUrl(String url, {String? title, bool streaming = false}) =>
      _handler.playTrack(url, title: title, streaming: streaming);

  Future<void> togglePlayPause() => _handler.togglePlayPause();
  Future<void> seek(Duration position) => _handler.seek(position);
  Future<void> rewind15() => _handler.rewind15();
  Future<void> forward15() => _handler.forward15();
  Future<void> stop() => _handler.stop();
}