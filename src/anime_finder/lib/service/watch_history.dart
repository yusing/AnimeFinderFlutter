import 'dart:convert';

import 'package:anime_finder/service/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'watch_history.g.dart';

enum WatchHistoryEntityType { video, image }

@JsonSerializable()
class WatchHistoryEntry {
  final WatchHistoryEntityType type;
  final int id;
  String title;
  String path;
  int? duration; // video duration in seconds, or index for image
  int? position; // video position in seconds, or count for images

  WatchHistoryEntry(
      {required this.id,
      required this.title,
      required this.path,
      required this.type,
      this.duration,
      this.position});

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
    history.value.add(entry);
    update();
  }

  static void remove(int id) {
    history.value.removeWhere((e) => e.id == id);
    update();
  }

  /* Image */
  static void updateIndex(int id, int index) {
    final entryIndex = history.value.indexWhere((e) => e.id == id);
    if (entryIndex == -1) {
      debugPrint('updateIndex $id not found');
      return;
    }
    history.value[entryIndex].position = index;
    update().then((_) {
      debugPrint('updateIndex $id updated to $index');
    });
  }

  static int getIndex(int id) {
    var index = history.value.indexWhere((e) => e.id == id);
    if (index == -1) {
      debugPrint('getIndex $id not found');
      return 0;
    }
    index = history.value[index].position!;
    return index;
  }

  /* Videos */
  static updatePosition(int videoId, Duration position) {
    if (position == Duration.zero) {
      return;
    }
    updateIndex(videoId, position.inSeconds);
  }

  static Duration getPosition(int videoId) {
    return Duration(seconds: getIndex(videoId));
  }

  static const _key = 'watch_histories';
  static WatchHistories history = get();
}
