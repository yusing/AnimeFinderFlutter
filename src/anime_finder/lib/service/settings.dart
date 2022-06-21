import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/service/storage.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/widgets/setting_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/platform.dart';
import 'anime.dart';
import 'anime_providers.dart';

class Setting<T> {
  final String Function() titleDelegate;
  final String key;
  final T defaultValue;
  final void Function(T)? onChange; // for bool
  final Map<ValueGetter<String>, T>? values; // for dropdown
  final RegExp? validator; // for string
  final bool Function()? visibilityDelegate;

  Setting(
      {required this.titleDelegate,
      required this.key,
      required this.defaultValue,
      this.onChange,
      this.values,
      this.validator,
      this.visibilityDelegate});

  T get value {
    T? prefValue = getPref(key);
    if (values != null) {
      if (prefValue == null) return defaultValue; // no value in box
      if (values!.containsValue(prefValue) == false) {
        return defaultValue;
      }
      return prefValue;
    }
    return prefValue ?? defaultValue;
  }

  set value(T newValue) {
    if (value == newValue) return;
    setPref(key, newValue).then((_) {
      onChange?.call(newValue);
    });
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  Widget widget(StateSetter setState) => Visibility(
      visible: visibilityDelegate?.call() ?? true,
      child: SettingItem(setting: this, setState: setState));
}

class Settings {
  static Setting<String> locale = Setting(
    titleDelegate: () => trLocale,
    key: 'locale',
    defaultValue: Get.deviceLocale?.languageCode ?? "zh",
    values: {
      () => "繁體中文": "zh",
      () => "English": "en",
    },
    onChange: (value) => Get.updateLocale(Locale(value)),
  );

  static Setting<bool> darkMode = Setting(
      titleDelegate: () => trDarkMode,
      key: 'dark_mode',
      defaultValue: ThemeMode.system == ThemeMode.dark,
      onChange: (value) async {
        Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        await Get.forceAppUpdate();
      });

  static Setting<double> textScale = Setting(
    titleDelegate: () => trTextScale,
    key: 'text_scale',
    defaultValue: AFPlatform.isMobile ? 0.9 : 1.0,
    values: {
      () => trFontSmall: 0.9,
      () => trFontNormal: 1.0,
      () => trFontLarge: 1.1,
    },
    onChange: (value) async {
      await Get.forceAppUpdate();
    },
  );

  static Setting<String> layoutOrientation = Setting(
      titleDelegate: () => trLayoutOrientation,
      key: 'layout_orientation',
      defaultValue: "auto",
      values: {
        () => trAuto: "auto",
        () => trPortrait: Orientation.portrait.toString(),
        () => trLandscape: Orientation.landscape.toString(),
      });

  static Setting<bool> filterNoCHS = Setting(
      titleDelegate: () => trFilterNoChs,
      key: 'filter_no_chs',
      defaultValue: false,
      visibilityDelegate: () => filterNoChinese.value != true);

  static Setting<bool> filterNoChinese = Setting(
      titleDelegate: () => trFilterNoChinese,
      key: 'filter_no_chinese',
      defaultValue: false);

  static Setting<String> animeProvider = Setting(
      titleDelegate: () => trProvider,
      key: 'anime_provider',
      defaultValue: animeProviders.entries.first.key,
      values: {
        for (var entry in animeProviders.entries)
          () => entry.value.name: entry.key
      },
      onChange: (value) => HomePage.reloadNeeded.value = true);

  static AnimeProvider get currentAnimeProvider =>
      animeProviders[animeProvider.value]!;

  static Future<void> reset() async {
    await clearStorage();
    darkMode.value = darkMode.defaultValue;
  }

  static List<Setting Function()> list = [
    () => locale,
    () => textScale,
    () => layoutOrientation,
    () => animeProvider,
    () => darkMode,
    () => filterNoChinese,
    () => filterNoCHS
  ];
}
