import 'dart:convert';
import 'dart:io';

import 'package:anime_finder/service/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'libtorrent.dart';

part 'watch_history.g.dart';

enum WatchHistoryEntryType { video, image, audio, all }

List<String> watchHistoryEntryTypeStringKey = [
  'anime',
  'comics',
  'music',
  'all',
];

@JsonSerializable()
class WatchHistoryEntry {
  final WatchHistoryEntryType type;
  final int id;
  String title;
  String get path => _getPath();
  int? duration; // video/music duration in seconds, or index for image
  int? position; // video/music position in seconds, or pages for images

  WatchHistoryEntry(
      {required this.id,
      required this.title,
      required String path,
      required this.type,
      this.duration,
      this.position})
      : _path = path;

  String _path;
  String _getPath() {
    if (Platform.isIOS) {
      return torrentSavePathRoot +
          _path.substring(_path.indexOf('/AnimeFinderDownloads/') +
              '/AnimeFinderDownloads'.length);
    }
    return _path;
  }

  set path(value) => _path = value;

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryEntryToJson(this);
}

@JsonSerializable()
class WatchHistories {
  List<WatchHistoryEntry> value;

  WatchHistories(this.value);

  factory WatchHistories.empty() {
    return WatchHistories([]);
  }

  factory WatchHistories.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoriesFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoriesToJson(this);
}

class WatchHistory {
  static WatchHistories get() {
    final json = getPref<String>(_key);
    if (json == null) return WatchHistories.empty();
    try {
      return WatchHistories.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint(e.toString());
      return WatchHistories.empty();
    }
  }

  static Future<void> update() async {
    await setPref(_key, jsonEncode(history));
  }

  static void add(WatchHistoryEntry entry) {
    final entryIndex = history.value.indexWhere((e) => e.id == entry.id);
    if (entryIndex != -1) {
      history.value.removeAt(entryIndex);
    }
    history.value.insert(0, entry);
    update();
  }

  static void remove(int id) {
    history.value.removeWhere((e) => e.id == id);
    update();
  }

  static void updateDuration(int id, Duration duration) {
    final entryIndex = history.value.indexWhere((e) => e.id == id);
    if (entryIndex == -1) {
      debugPrint('WatchHistory.updateDuration: entry not found');
      return;
    }
    history.value[entryIndex].duration = duration.inSeconds;
    update();
  }

  static Duration getDuration(int id) {
    final entryIndex = history.value.indexWhere((e) => e.id == id);
    if (entryIndex == -1) {
      debugPrint('WatchHistory.getDuration: entry not found');
      return Duration.zero;
    }
    return Duration(seconds: history.value[entryIndex].duration ?? 0);
  }

  /* Image */
  static void updateIndex(int id, int index) {
    final entryIndex = history.value.indexWhere((e) => e.id == id);
    if (entryIndex == -1) {
      debugPrint('WatchHistory.updateIndex $id not found');
      return;
    }
    history.value[entryIndex].position = index;
    update();
  }

  static int getIndex(int id) {
    var index = history.value.indexWhere((e) => e.id == id);
    if (index == -1) {
      debugPrint('WatchHistory.getIndex $id not found');
      return 0;
    }
    index = history.value[index].position ?? 0;
    return index;
  }

  static updatePosition(int id, Duration position) {
    if (position == Duration.zero) {
      return;
    }
    updateIndex(id, position.inSeconds);
  }

  static Duration getPosition(int videoId) {
    return Duration(seconds: getIndex(videoId));
  }

  static const _key = 'watch_histories';
  static WatchHistories history = get();
}
