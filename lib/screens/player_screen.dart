// lib/screens/player_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../models/audio_item.dart';

class PlayerScreen extends StatefulWidget {
  final AudioService audio;
  final AudioItem? item;

  const PlayerScreen({
    super.key,
    required this.audio,
    this.item,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioService audio;
  late StreamSubscription _audioSub;

  @override
  void initState() {
    super.initState();
    audio = widget.audio;

    if (widget.item != null && audio.currentUrl != widget.item!.url) {
      audio.playUrl(widget.item!.url);
    }

    _audioSub = audio.stateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _audioSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = audio.currentUrl;
    final isPlaying = audio.isPlaying;

    if (currentUrl == null) {
      return const Scaffold(
        body: Center(child: Text("No track selected")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Now Playing"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              currentUrl.split('/').last,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            StreamBuilder<Duration>(
              stream: audio.positionStream,
              initialData: audio.currentPosition,
              builder: (context, snapshotPos) {
                final pos = snapshotPos.data ?? Duration.zero;

                return StreamBuilder<Duration?>(
                  stream: audio.durationStream,
                  initialData: audio.currentDuration,
                  builder: (context, snapshotDur) {
                    final dur = snapshotDur.data ?? Duration.zero;

                    final max = dur.inSeconds.toDouble();
                    final value = pos.inSeconds.toDouble().clamp(0.0, max);

                    return Column(
                      children: [
                        Slider(
                          value: max == 0.0 ? 0.0 : value,
                          max: max == 0.0 ? 1.0 : max,
                          onChanged: (v) {
                            audio.seek(Duration(seconds: v.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(pos)),
                            Text(_fmt(dur)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 32),
                  onPressed: audio.rewind15,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 70,
                    color: Colors.greenAccent.shade400,
                  ),
                  onPressed: audio.togglePlayPause,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 32),
                  onPressed: audio.forward15,
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.favorite_border),
              label: const Text("Favourite"),
              onPressed: () {
                // TODO: Implement favourites later
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}