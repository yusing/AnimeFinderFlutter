import 'dart:convert';

import "package:flutter/services.dart" show rootBundle;
import "package:get/get.dart";

export 'translation.g.dart';

class TranslationService extends Translations {
  static final Map<String, Map<String, String>> _translations = {};
  static Future<void> init() async {
    final json =
        jsonDecode(await rootBundle.loadString('assets/translation.json'));
    int index = 0;
    for (final lang in json['languages']) {
      _translations[lang] = {
        for (final entry in json['translations'].entries)
          entry.key: entry.value[index]
      };
      ++index;
    }
  }

  @override
  get keys => _translations;
}
