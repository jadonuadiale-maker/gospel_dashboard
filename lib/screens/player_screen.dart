import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

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

    // Listen to duration
    widget.audio.durationStream.listen((d) {
      if (d != null) {
        setState(() => _duration = d);
      }
    });

    // Listen to position
    widget.audio.positionStream.listen((p) {
      setState(() => _position = p);
    });

    // Start loading + playing
    widget.audio.playUrl(widget.url);
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

                  // Duration text
                  Text(
                    "${_format(_position)} / ${_format(_duration)}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  // Seek bar
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      widget.audio.seek(Duration(seconds: value.toInt()));
                    },
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 40),
                        onPressed: () => widget.audio.playUrl(widget.url),
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause, size: 40),
                        onPressed: () => widget.audio.pause(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop, size: 40),
                        onPressed: () => widget.audio.stop(),
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