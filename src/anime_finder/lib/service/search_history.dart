import 'dart:convert';

import 'package:anime_finder/service/storage.dart';
import 'package:flutter/foundation.dart';

class SearchHistory {
  static List<String> fetch() {
    String? historyJson = getPref<String>('searchHistory');
    if (historyJson == null) {
      return [];
    }
    try {
      return (jsonDecode(historyJson) as List).map((e) => e as String).toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> _save(List<String> history) async {
    await setPref('searchHistory', jsonEncode(history));
  }

  static Future<void> add(String keyword) async {
    final history = fetch();
    if (history.length >= 20) {
      history.removeLast();
    }
    if (history.contains(keyword)) {
      return;
    }
    history.insert(0, keyword);
    await _save(history);
    debugPrint('Added $keyword to search history');
  }

  static Future<void> remove(int index) async {
    final history = fetch();
    history.removeAt(index);
    await _save(history);
  }
}
