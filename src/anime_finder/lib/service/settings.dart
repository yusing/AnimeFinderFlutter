import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/service/anime_provider.dart';
import 'package:anime_finder/service/storage.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/widgets/setting_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'anime_providers.dart';
import 'platform.dart';

typedef SettingNameDelegate = String Function();

class Setting<T> {
  final String Function() titleDelegate;
  final String key;
  final T defaultValue;
  final void Function(T)? onChange; // for bool
  final Map<SettingNameDelegate, T>? values; // for dropdown
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

  Widget widget(void Function(void Function()) setState) => Visibility(
      visible: visibilityDelegate?.call() ?? true,
      child: SettingItem(setting: this, setState: setState));
}

class Settings {
  static Setting<String> locale = Setting(
    titleDelegate: () => trSettingLocale,
    key: 'locale',
    defaultValue: Get.deviceLocale?.languageCode ?? "zh",
    values: {
      () => "繁體中文": "zh",
      () => "English": "en",
    },
    onChange: (value) => Get.updateLocale(Locale(value)),
  );

  static Setting<bool> darkMode = Setting(
      titleDelegate: () => trSettingDarkMode,
      key: 'dark_mode',
      defaultValue: ThemeMode.system == ThemeMode.dark,
      onChange: (value) async {
        Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        await Get.forceAppUpdate();
      });

  static Setting<double> textScale = Setting(
    titleDelegate: () => trSettingTextScale,
    key: 'text_scale',
    defaultValue: AFPlatform.isMobile ? 0.8 : 1.0,
    values: {
      () => trSettingFontSmall: 0.8,
      () => trSettingFontNormal: 1.0,
      () => trSettingFontLarge: 1.2,
    },
    onChange: (value) async {
      await Get.forceAppUpdate();
    },
  );

  static Setting<String> layoutOrientation = Setting(
      titleDelegate: () => trSettingLayoutOrientation,
      key: 'layout_orientation',
      defaultValue: "auto",
      values: {
        () => trSettingAuto: "auto",
        () => trSettingPortrait: Orientation.portrait.toString(),
        () => trSettingLandscape: Orientation.landscape.toString(),
      });

  static Setting<bool> filterNoCHS = Setting(
      titleDelegate: () => trSettingFilterNoChs,
      key: 'filter_no_chs',
      defaultValue: false,
      visibilityDelegate: () => filterNoChinese.value != true);

  static Setting<bool> filterNoChinese = Setting(
      titleDelegate: () => trSettingFilterNoChinese,
      key: 'filter_no_chinese',
      defaultValue: false);

  static Setting<String> animeProvider = Setting(
      titleDelegate: () => trSettingProvider,
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

  static const currentVersion = "v0.2.0";
}
