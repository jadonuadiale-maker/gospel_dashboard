// lib/screens/messages_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import '../services/favourites_service.dart';
import '../services/ministers_service.dart';
import '../widgets/audio_tile.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/category_nav_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final audio = AudioService();
  final favourites = FavouritesService();
  final ministers = MinistersService();
  late StreamSubscription _audioSub;
  late StreamSubscription _favSub;
  late StreamSubscription _ministersSub;

  int navIndex = 0;

  final List<AudioItem> allMessages = [
    AudioItem(
      title: "The Purpose of your Life - Dr Myles Munroe",
      url: "assets/messages/Dr-Myles-Munroe-_-The-purpose-for-your-life-64-kbps-2.opus",
      category: "Message",
    ),
    AudioItem(
      title: "10 Principles of a Future Leader - Dr Myles Munroe",
      url: "assets/messages/Dr-Myles-Munroe-10-Principles-and-marks-of-a-Future-leader-64-kbps.opus",
      category: "Message",
    ),
    AudioItem(
      title: "10 Principles for Leadership Development - Dr Myles Munroe",
      url: "assets/messages/DR-Myles-Munroe-10-PRINCIPLES-FOR-LEADERSHIP-DEVELOPMENT-NEW-RELEASE-2017-64-kbps.opus",
      category: "Message",
    ),
    AudioItem(
      title: "How to become a Leader - Dr Myles Munroe",
      url: "assets/messages/Dr-Myles-Munroe-HOW-TO-BECOME-A-LEADER-Break-away-from-your-struggling-mindset-POWERFUL-64-kbps.opus",
      category: "Message",
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
            audio.playUrl(item.url, title: item.title, streaming: true);
          } else {
            audio.togglePlayPause();
          }
        },
        onSelectTrack: () {
          if (!isCurrent) {
            audio.playUrl(item.url, title: item.title, streaming: true);
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
      final grouped = ministers.groupedByMinister("Message");
      final names = grouped.keys.toList()..sort();

      body = names.isEmpty
          ? const Center(child: Text("No ministers assigned yet.\nSet one from the Now Playing screen."))
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
          navIndex == 1 ? favourites.favouritesFor("Message") : allMessages;

      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: visibleList.length,
        itemBuilder: (context, index) => _tileFor(visibleList[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Navigator.pushNamed(context, '/playlist', arguments: 'Message'),
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