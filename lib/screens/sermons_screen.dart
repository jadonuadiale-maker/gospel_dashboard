// lib/screens/sermons_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import '../widgets/audio_tile.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/category_nav_bar.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final audio = AudioService();
  late StreamSubscription _audioSub;

  int navIndex = 0;

  final List<AudioItem> allSermons = [
    AudioItem(
      title: "The Spirit of Innovation - Dr Myles Munroe",
      url: "assets/sermons/Dr-Myles-Munroe-Have-The-Spirit-of-Innovation-Power-of-Vision-64-kbps.opus",
      category: "Sermon",
    ),
    AudioItem(
      title: "God's Original Intent - Dr Myles Munroe",
      url: "assets/sermons/Gods-Original-Intent-_-Dr.-Myles-Munroe-64-kbps.opus",
      category: "Sermon",
    ),
    AudioItem(
      title: "Kingdom Authority - Dr Myles Munroe",
      url: "assets/sermons/KINGDOM-AUTHORITY-by-Dr.-Myles-Munroe-64-kbps.opus",
      category: "Sermon",
    ),
  ];

  final List<AudioItem> favouriteSermons = <AudioItem>[];
  final List<AudioItem> sermonsByMinister = <AudioItem>[];

  @override
  void initState() {
    super.initState();
    _audioSub = audio.stateStream.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _audioSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AudioItem> visibleList;

    switch (navIndex) {
      case 1:
        visibleList = favouriteSermons;
        break;
      case 2:
        visibleList = sermonsByMinister;
        break;
      default:
        visibleList = allSermons;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sermons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Navigator.pushNamed(context, '/playlist'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: audio.isLoading,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: visibleList.length,
          itemBuilder: (context, index) {
            final item = visibleList[index];
            final isCurrent = audio.currentUrl == item.url;
            final isPlaying = audio.isPlaying && isCurrent;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AudioTile(
                item: item,
                isPlaying: isPlaying,
                onPlayPause: () {
                  if (!isCurrent) {
                    audio.playUrl(item.url);
                  } else {
                    audio.togglePlayPause();
                  }
                },
                onSelectTrack: () {
                  if (!isCurrent) {
                    audio.playUrl(item.url);
                  }
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CategoryNavBar(
        currentIndex: navIndex,
        onTap: (i) => setState(() => navIndex = i),
      ),
    );
  }
}