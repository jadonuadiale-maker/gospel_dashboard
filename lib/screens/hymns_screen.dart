// lib/screens/hymns_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_service.dart';
import '../widgets/audio_tile.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/category_nav_bar.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  State<HymnsScreen> createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  final audio = AudioService();
  late StreamSubscription _audioSub;

  int navIndex = 0;

  final List<AudioItem> allHymns = [
    AudioItem(
      title: "Amazing Grace - Traditional",
      url: "assets/hymns/Amazing-Grace.opus",
      category: "Hymn",
    ),
    AudioItem(
      title: "How Great Thou Art - Traditional",
      url: "assets/hymns/How-Great-Thou-Art.opus",
      category: "Hymn",
    ),
    AudioItem(
      title: "Be Thou My Vision - Traditional",
      url: "assets/hymns/Be-Thou-My-Vision.opus",
      category: "Hymn",
    ),
  ];

  final List<AudioItem> favouriteHymns = <AudioItem>[];
  final List<AudioItem> hymnsByArtist = <AudioItem>[];

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
        visibleList = favouriteHymns;
        break;
      case 2:
        visibleList = hymnsByArtist;
        break;
      default:
        visibleList = allHymns;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hymns"),
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