import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_item.dart';

/// Persistent favourites store, keyed by track url. Singleton, same
/// pattern as AudioService, so any screen can read/toggle favourites
/// and react when they change anywhere in the app.
class FavouritesService {
  static final FavouritesService _instance = FavouritesService._internal();
  factory FavouritesService() => _instance;
  FavouritesService._internal();

  static const _prefsKey = 'favourite_tracks';

  final Map<String, AudioItem> _favourites = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  final _changesController = StreamController<void>.broadcast();
  Stream<void> get changes => _changesController.stream;

  /// Must be awaited once in main(), before runApp() — same as
  /// AudioService.bootstrap().
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_prefsKey) ?? [];

    for (final entry in raw) {
      try {
        final item = AudioItem.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        _favourites[item.url] = item;
      } catch (_) {
        // Skip any corrupted entry rather than crash app startup.
      }
    }

    _initialized = true;
  }

  bool isFavourite(String url) => _favourites.containsKey(url);

  List<AudioItem> favouritesFor(String category) => _favourites.values
      .where((item) => item.category == category)
      .toList();

  Future<void> toggleFavourite(AudioItem item) async {
    if (_favourites.containsKey(item.url)) {
      _favourites.remove(item.url);
    } else {
      _favourites[item.url] = item;
    }
    await _persist();
    _changesController.add(null);
  }

  Future<void> _persist() async {
    final raw =
        _favourites.values.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs?.setStringList(_prefsKey, raw);
  }
}