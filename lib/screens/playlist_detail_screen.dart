// lib/screens/playlist_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/audio_service.dart';
import '../services/playlists_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final audio = AudioService();
  final service = PlaylistsService();
  late StreamSubscription _audioSub;
  late StreamSubscription _playlistSub;

  @override
  void initState() {
    super.initState();
    _audioSub = audio.stateStream.listen((_) {
      if (mounted) setState(() {});
    });
    _playlistSub = service.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _audioSub.cancel();
    _playlistSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passedPlaylist =
        ModalRoute.of(context)?.settings.arguments as Playlist?;

    if (passedPlaylist == null) {
      return const Scaffold(
        body: Center(child: Text("Playlist not found")),
      );
    }

    // Re-fetch live from the service so edits (track removed elsewhere)
    // reflect immediately rather than showing a stale snapshot.
    final playlist = service
        .playlistsFor(passedPlaylist.category)
        .where((p) => p.name == passedPlaylist.name)
        .firstOrNull;

    if (playlist == null) {
      return const Scaffold(
        body: Center(child: Text("This playlist was deleted")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: playlist.tracks.isEmpty
          ? const Center(child: Text("No tracks in this playlist yet."))
          : ListView.builder(
              itemCount: playlist.tracks.length,
              itemBuilder: (context, index) {
                final item = playlist.tracks[index];
                final isCurrent = audio.currentUrl == item.url;
                final isPlaying = audio.isPlaying && isCurrent;
                final longForm = item.category == 'Sermon' || item.category == 'Message';

                return ListTile(
                  leading: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.blueAccent,
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.category),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => service.removeTrackFromPlaylist(
                      playlist.category,
                      playlist.name,
                      item.url,
                    ),
                  ),
                  onTap: () {
                    if (!isCurrent) {
                      audio.playUrl(item.url, title: item.title, streaming: longForm);
                    } else {
                      audio.togglePlayPause();
                    }
                  },
                );
              },
            ),
      // global MiniPlayer handles playback UI
    );
  }
}