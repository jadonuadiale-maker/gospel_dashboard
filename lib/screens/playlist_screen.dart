// lib/screens/playlist_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/playlists_service.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final service = PlaylistsService();
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = service.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<String?> _promptForName({String title = "New Playlist", String initial = ""}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Playlist name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlaylist(String category) async {
    final name = await _promptForName(title: "New Playlist");
    if (name != null && name.isNotEmpty) {
      await service.createPlaylist(category, name);
    }
  }

  Future<void> _renamePlaylist(String category, String oldName) async {
    final newName = await _promptForName(title: "Rename Playlist", initial: oldName);
    if (newName == null || newName.isEmpty || newName == oldName) return;

    final success = await service.renamePlaylist(category, oldName, newName);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A playlist named "$newName" already exists')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Hymn';
    final playlists = service.playlistsFor(category);

    return Scaffold(
      appBar: AppBar(title: Text("$category Playlists")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPlaylist(category),
        child: const Icon(Icons.add),
      ),
      body: playlists.isEmpty
          ? const Center(child: Text("No playlists yet — tap + to create one."))
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return Dismissible(
                  key: ValueKey('${playlist.category}:${playlist.name}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) =>
                      service.deletePlaylist(playlist.category, playlist.name),
                  child: ListTile(
                    title: Text(playlist.name),
                    subtitle: Text("${playlist.tracks.length} track(s)"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: "Rename",
                          onPressed: () =>
                              _renamePlaylist(playlist.category, playlist.name),
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/playlist/detail',
                        arguments: playlist,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}