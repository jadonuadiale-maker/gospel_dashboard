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

  @override
  void initState() {
    super.initState();

    widget.audio.durationStream.listen((d) {
      if (d != null) {
        setState(() => _duration = d);
      }
    });

    widget.audio.positionStream.listen((p) {
      setState(() => _position = p);
    });

    widget.audio.stateStream.listen((_) => setState(() {}));

    // 🔥 PlayerScreen NO LONGER calls playUrl()
    // Playback is controlled ONLY by category list toggle button
  }

  @override
  Widget build(BuildContext context) {
    final audio = widget.audio;

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
                    "${_format(_position)} / ${_format(_duration)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      audio.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, size: 40),
                        onPressed: () => audio.rewind15(),
                      ),
                      IconButton(
                        icon: Icon(
                          audio.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                        ),
                        onPressed: () => audio.togglePlayPause(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, size: 40),
                        onPressed: () => audio.forward15(),
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
