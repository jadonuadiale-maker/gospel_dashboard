import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class PlayerScreen extends StatefulWidget {
  final AudioService audio;
  final String url;

  const PlayerScreen({
    super.key,
    required this.audio,
    required this.url,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  late StreamSubscription _durationSub;
  late StreamSubscription _positionSub;
  late StreamSubscription _stateSub;

  @override
  void initState() {
    super.initState();

    _durationSub = widget.audio.durationStream.listen((d) {
      if (d != null) {
        setState(() => _duration = d);
      }
    });

    _positionSub = widget.audio.positionStream.listen((p) {
      setState(() => _position = p);
    });

    _stateSub = widget.audio.stateStream.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _durationSub.cancel();
    _positionSub.cancel();
    _stateSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = widget.audio;
    final isCurrent = audio.currentUrl == widget.url;
    final isPlaying = audio.isPlaying && isCurrent;

    final displayPosition = isCurrent ? _position : Duration.zero;
    final displayDuration = isCurrent ? _duration : Duration.zero;

    final maxSeconds =
        displayDuration.inSeconds > 0 ? displayDuration.inSeconds.toDouble() : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Center(
        child: audio.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    "${_format(displayPosition)} / ${_format(displayDuration)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: displayPosition.inSeconds.toDouble(),
                    max: maxSeconds,
                    onChanged: isCurrent
                        ? (value) {
                            audio.seek(Duration(seconds: value.toInt()));
                          }
                        : null,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, size: 40),
                        onPressed: isCurrent ? () => audio.rewind15() : null,
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                        ),
                        onPressed: () {
                          if (!isCurrent) {
                            audio.playUrl(widget.url);
                          } else {
                            audio.togglePlayPause();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, size: 40),
                        onPressed: isCurrent ? () => audio.forward15() : null,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}