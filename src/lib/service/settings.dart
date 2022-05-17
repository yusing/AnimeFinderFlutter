import 'dart:io';

import 'package:anime_finder/service/anime_provider.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/widgets/setting_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'anime_providers.dart';

final _box = GetStorage();

class Setting<T> extends ChangeNotifier implements ValueListenable<T> {
  final String title;
  final String key;
  final T defaultValue;
  final void Function(T)? onChange; // for bool
  final Map<String, T>? values; // for dropdown
  final RegExp? validator; // for string
  final bool Function()? visibilityDelegate;

  Setting(
      {required this.title,
      required this.key,
      required this.defaultValue,
      this.onChange,
      this.values,
      this.validator,
      this.visibilityDelegate})
      : super();

  @override
  T get value => _box.read(key) ?? defaultValue;

  set value(T newValue) {
    if (value == newValue) return;
    _box.write(key, newValue).then((_) {
      onChange?.call(newValue);
    });
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  Widget widget(void Function(void Function()) setState) => Visibility(
      visible: visibilityDelegate?.call() ?? true,
      child: SettingItem(setting: this, setState: setState));
}

abstract class AllSettings {
  Setting<String> get locale;
  Setting<bool> get darkMode;
  Setting<bool> get filterNoChinese;
  Setting<bool> get filterNoCHS;
  Setting<double> get textScale;
  Setting<String> get layoutOrientation;
  Setting<String> get qBittorrentAPIUrl;
  Setting<String> get animeProvider;

  List<Setting> get list;
  AnimeProvider get currentAnimeProvider;
  Future<void> reset();
}

class Settings implements AllSettings {
  @override
  Setting<String> get locale => Setting(
        title: trSettingLocale,
        key: 'locale',
        defaultValue: Get.deviceLocale?.languageCode ?? "zh",
        values: {
          "繁體中文": "zh",
          "English": "en",
        },
        onChange: (value) {
          Get.updateLocale(Locale(value));
        },
      );

  @override
  Setting<bool> get darkMode => Setting(
        title: trSettingDarkMode,
        key: 'dark_mode',
        defaultValue: false,
        onChange: (value) {
          Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          Get.forceAppUpdate();
        },
      );

  @override
  Setting<double> get textScale => Setting(
        title: trSettingTextScale,
        key: 'text_scale',
        defaultValue: Platform.isIOS || Platform.isAndroid ? 0.8 : 1.0,
        values: {
          trSettingFontSmall: 0.8,
          trSettingFontNormal: 1.0,
          trSettingFontLarge: 1.2,
        },
        onChange: (value) {
          Get.forceAppUpdate();
        },
      );

  @override
  Setting<String> get layoutOrientation => Setting(
          title: trSettingLayoutOrientation,
          key: 'layout_orientation',
          defaultValue: "auto",
          values: {
            trSettingAuto: "auto",
            trSettingPortrait: Orientation.portrait.toString(),
            trSettingLandscape: Orientation.landscape.toString(),
          });

  @override
  Setting<bool> get filterNoCHS => Setting(
      title: trSettingFilterNoChs,
      key: 'filter_no_chs',
      defaultValue: false,
      visibilityDelegate: () => filterNoChinese.value != true);

  @override
  Setting<bool> get filterNoChinese => Setting(
      title: trSettingFilterNoChinese,
      key: 'filter_no_chinese',
      defaultValue: false);

  @override
  Setting<String> get qBittorrentAPIUrl => Setting(
        title: trSettingQbittorrentApiUrl,
        key: 'qbittorrent_api_url',
        defaultValue: 'http://localhost:8080',
        validator: RegExp(r'^https?://.+'),
      );

  @override
  Setting<String> get animeProvider => Setting(
          title: trSettingProvider,
          key: 'anime_provider',
          defaultValue: 'DMHY 動漫花園 [動漫]',
          onChange: (_) async => await Get.forceAppUpdate(),
          values: {
            for (var entry in animeProviders.entries)
              entry.value.name: entry.key
          });

  @override
  AnimeProvider get currentAnimeProvider =>
      animeProviders[animeProvider.value]!;

  @override
  Future<void> reset() async {
    await GetStorage().erase();
    darkMode.value = darkMode.defaultValue;
  }

  @override
  List<Setting> get list => [
        locale,
        textScale,
        layoutOrientation,
        animeProvider,
        darkMode,
        filterNoChinese,
        filterNoCHS,
        qBittorrentAPIUrl,
      ];

  static Settings get instance => Settings();
  static const currentVersion = "v0.2.0";
}
