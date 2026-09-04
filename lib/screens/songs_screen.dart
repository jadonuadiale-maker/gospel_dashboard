// lib/screens/songs_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import '../services/favourites_service.dart';
import '../services/ministers_service.dart';
import '../widgets/audio_tile.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/category_nav_bar.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final audio = AudioService();
  final favourites = FavouritesService();
  final ministers = MinistersService();
  late StreamSubscription _audioSub;
  late StreamSubscription _favSub;
  late StreamSubscription _ministersSub;

  int navIndex = 0;

  final List<AudioItem> allSongs = [
    AudioItem(
      title: "Jehovah Jireh - Don Moen",
      url: "assets/songs/06 Jehovah-Jireh (Live).opus",
      category: "Song",
    ),
    AudioItem(
      title: "Emmanuel - John Fadejola",
      url: "assets/songs/Direct-Lyrics-John-Fadejola-Emmanuel-Es-Lyrics-(CeeNaija.com).opus",
      category: "Song",
    ),
    AudioItem(
      title: "The Blessing - Elevation Worship",
      url: "assets/songs/The Blessing - Kari Jobe, Cody Carnes & Elevation Worship [www.AmenRadio.net].opus",
      category: "Song",
    ),
    AudioItem(
      title: "I Give Myself Away - Williams McDowell",
      url: "assets/songs/Williams_McDowell_-_I_Give_Myself_Away_CeeNaija.com_.opus",
      category: "Song",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioSub = audio.stateStream.listen((_) {
      if (mounted) setState(() {});
    });
    _favSub = favourites.changes.listen((_) {
      if (mounted) setState(() {});
    });
    _ministersSub = ministers.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _audioSub.cancel();
    _favSub.cancel();
    _ministersSub.cancel();
    super.dispose();
  }

  Widget _tileFor(AudioItem item) {
    final isCurrent = audio.currentUrl == item.url;
    final isPlaying = audio.isPlaying && isCurrent;
    final isFavourite = favourites.isFavourite(item.url);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AudioTile(
        item: item,
        isPlaying: isPlaying,
        isFavourite: isFavourite,
        onPlayPause: () {
          if (!isCurrent) {
            audio.playUrl(item.url, title: item.title);
          } else {
            audio.togglePlayPause();
          }
        },
        onSelectTrack: () {
          if (!isCurrent) {
            audio.playUrl(item.url, title: item.title);
          }
        },
        onToggleFavourite: () => favourites.toggleFavourite(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (navIndex == 2) {
      final grouped = ministers.groupedByMinister("Song");
      final names = grouped.keys.toList()..sort();

      body = names.isEmpty
          ? const Center(child: Text("No artists assigned yet.\nSet one from the Now Playing screen."))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final name in names) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (final item in grouped[name]!) _tileFor(item),
                ],
              ],
            );
    } else {
      final visibleList =
          navIndex == 1 ? favourites.favouritesFor("Song") : allSongs;

      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: visibleList.length,
        itemBuilder: (context, index) => _tileFor(visibleList[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Songs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Navigator.pushNamed(context, '/playlist', arguments: 'Song'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: audio.isLoading,
        child: body,
      ),
      bottomNavigationBar: CategoryNavBar(
        currentIndex: navIndex,
        onTap: (i) => setState(() => navIndex = i),
      ),
    );
  }
}