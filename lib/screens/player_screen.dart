// lib/screens/player_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/favourites_service.dart';
import '../services/playlists_service.dart';
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
  final favourites = FavouritesService();
  final playlists = PlaylistsService();
  late StreamSubscription _audioSub;
  late StreamSubscription _favSub;

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
    _favSub = favourites.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _audioSub.cancel();
    _favSub.cancel();
    super.dispose();
  }

  AudioItem _resolveItem(String url) {
    if (widget.item != null) return widget.item!;

    final segments = url.split('/');
    final folder = segments.length > 1 ? segments[1] : '';
    String category;
    switch (folder) {
      case 'hymns':
        category = 'Hymn';
        break;
      case 'sermons':
        category = 'Sermon';
        break;
      case 'songs':
        category = 'Song';
        break;
      case 'messages':
        category = 'Message';
        break;
      default:
        category = 'Unknown';
    }

    return AudioItem(title: segments.last, url: url, category: category);
  }

  Future<void> _showAddToPlaylistSheet(AudioItem item) async {
    // Captured from the stable outer screen context, BEFORE any sheet or
    // dialog is opened/closed — this avoids relying on a context that
    // might already be mid-teardown by the time we try to show a SnackBar.
    final messenger = ScaffoldMessenger.of(context);
    final existing = playlists.playlistsFor(item.category);

    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        // Renamed from `context` to `sheetContext` so it can never be
        // confused with the outer screen's context above.
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Add to ${item.category} Playlist",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ...existing.map((p) => ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(p.name),
                    subtitle: Text("${p.tracks.length} track(s)"),
                    onTap: () async {
                      await playlists.addTrackToPlaylist(item.category, p.name, item);
                      Navigator.pop(sheetContext);
                      messenger.showSnackBar(
                        SnackBar(content: Text("Added to ${p.name}")),
                      );
                    },
                  )),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("New playlist"),
                onTap: () async {
                  Navigator.pop(sheetContext); // close sheet before showing dialog
                  final controller = TextEditingController();
                  final name = await showDialog<String>(
                    context: context, // outer, stable — still valid here
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("New Playlist"),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: "Playlist name"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
                          child: const Text("Create"),
                        ),
                      ],
                    ),
                  );

                  if (name != null && name.isNotEmpty) {
                    await playlists.addTrackToPlaylist(item.category, name, item);
                    messenger.showSnackBar(
                      SnackBar(content: Text("Added to $name")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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

    final item = _resolveItem(currentUrl);
    final isFavourite = favourites.isFavourite(currentUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Now Playing"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: "Add to playlist",
            onPressed: () => _showAddToPlaylistSheet(item),
          ),
        ],
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
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.redAccent : null,
              ),
              label: Text(isFavourite ? "Favourited" : "Favourite"),
              onPressed: () => favourites.toggleFavourite(item),
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