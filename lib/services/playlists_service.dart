import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_item.dart';
import '../models/playlist.dart';

/// Persistent, category-scoped playlists. A "Hymn" playlist named
/// "Morning Worship" is entirely separate from a "Sermon" playlist of
/// the same name — they're keyed by (category, name) together.
class PlaylistsService {
  static final PlaylistsService _instance = PlaylistsService._internal();
  factory PlaylistsService() => _instance;
  PlaylistsService._internal();

  static const _prefsKey = 'playlists';

  final List<Playlist> _playlists = [];
  SharedPreferences? _prefs;
  bool _initialized = false;

  final _changesController = StreamController<void>.broadcast();
  Stream<void> get changes => _changesController.stream;

  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_prefsKey) ?? [];

    for (final entry in raw) {
      try {
        _playlists.add(Playlist.fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } catch (_) {
        // Skip any corrupted entry rather than crash app startup.
      }
    }

    _initialized = true;
  }

  List<Playlist> playlistsFor(String category) =>
      _playlists.where((p) => p.category == category).toList();

  Playlist? _find(String category, String name) {
    for (final p in _playlists) {
      if (p.category == category && p.name == name) return p;
    }
    return null;
  }

  /// Creates a new empty playlist if one with this name doesn't already
  /// exist in this category; otherwise returns the existing one.
  Future<Playlist> createPlaylist(String category, String name) async {
    final existing = _find(category, name);
    if (existing != null) return existing;

    final playlist = Playlist(name: name, category: category);
    _playlists.add(playlist);
    await _persist();
    _changesController.add(null);
    return playlist;
  }

  Future<void> deletePlaylist(String category, String name) async {
    _playlists.removeWhere((p) => p.category == category && p.name == name);
    await _persist();
    _changesController.add(null);
  }

  /// Renames a playlist in place, preserving its tracks. Does nothing if
  /// a playlist with [newName] already exists in this category (to avoid
  /// silently merging two distinct playlists).
  Future<bool> renamePlaylist(String category, String oldName, String newName) async {
    if (oldName == newName) return true;
    if (_find(category, newName) != null) return false; // name clash

    final index = _playlists.indexWhere(
      (p) => p.category == category && p.name == oldName,
    );
    if (index == -1) return false;

    final old = _playlists[index];
    _playlists[index] = Playlist(
      name: newName,
      category: category,
      tracks: old.tracks,
    );

    await _persist();
    _changesController.add(null);
    return true;
  }

  /// Adds [item] to the given playlist, creating the playlist first if it
  /// doesn't exist yet. Does nothing if the track is already in it.
  Future<void> addTrackToPlaylist(String category, String name, AudioItem item) async {
    final playlist = await createPlaylist(category, name);
    if (playlist.tracks.any((t) => t.url == item.url)) return;

    playlist.tracks.add(item);
    await _persist();
    _changesController.add(null);
  }

  Future<void> removeTrackFromPlaylist(String category, String name, String url) async {
    final playlist = _find(category, name);
    if (playlist == null) return;

    playlist.tracks.removeWhere((t) => t.url == url);
    await _persist();
    _changesController.add(null);
  }

  Future<void> _persist() async {
    final raw = _playlists.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs?.setStringList(_prefsKey, raw);
  }
}