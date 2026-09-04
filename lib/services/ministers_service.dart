import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_item.dart';
import '../models/minister_assignment.dart';

/// Persistent, category-scoped minister/artist labels. Unlike playlists,
/// this is one-to-one: setting a minister for a track replaces any
/// existing assignment for that track rather than adding to a list.
class MinistersService {
  static final MinistersService _instance = MinistersService._internal();
  factory MinistersService() => _instance;
  MinistersService._internal();

  static const _prefsKey = 'minister_assignments';

  final List<MinisterAssignment> _assignments = [];
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
        _assignments.add(
          MinisterAssignment.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip any corrupted entry rather than crash app startup.
      }
    }

    _initialized = true;
  }

  /// The currently assigned minister for this track, if any.
  String? ministerFor(String url) {
    for (final a in _assignments) {
      if (a.item.url == url) return a.ministerName;
    }
    return null;
  }

  /// All distinct minister names used so far in this category — used to
  /// offer existing names as quick-pick suggestions rather than retyping.
  List<String> ministerNamesFor(String category) {
    final names = _assignments
        .where((a) => a.category == category)
        .map((a) => a.ministerName)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  /// Tracks in this category, grouped by minister name, for the
  /// "Ministers" tab.
  Map<String, List<AudioItem>> groupedByMinister(String category) {
    final map = <String, List<AudioItem>>{};
    for (final a in _assignments.where((a) => a.category == category)) {
      map.putIfAbsent(a.ministerName, () => []).add(a.item);
    }
    return map;
  }

  Future<void> setMinister(String category, AudioItem item, String ministerName) async {
    _assignments.removeWhere((a) => a.item.url == item.url);
    _assignments.add(
      MinisterAssignment(category: category, ministerName: ministerName, item: item),
    );
    await _persist();
    _changesController.add(null);
  }

  Future<void> clearMinister(String url) async {
    _assignments.removeWhere((a) => a.item.url == url);
    await _persist();
    _changesController.add(null);
  }

  Future<void> _persist() async {
    final raw = _assignments.map((a) => jsonEncode(a.toJson())).toList();
    await _prefs?.setStringList(_prefsKey, raw);
  }
}