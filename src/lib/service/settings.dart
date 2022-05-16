import 'dart:io';

import 'package:anime_finder/service/anime_provider.dart';
import 'package:anime_finder/widgets/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

class Setting<T> {
  final String title;
  final String key;
  final T defaultValue;
  final void Function(T)? onChange; // for bool
  final Map<String, T>? values; // for dropdown
  final RegExp? validator; // for string
  // late T _value;

  Setting(
      {required this.title,
      required this.key,
      required this.defaultValue,
      this.onChange,
      this.values,
      this.validator});

  T get value => _box.read(key) ?? defaultValue;

  set value(T value) {
    _box.write(key, value).then((_) {
      onChange?.call(value);
    });
  }

  Widget get widget => SettingItem(setting: this);
}

class Settings {
  static Setting<bool> darkMode = Setting(
    title: '黑夜模式',
    key: 'dark_mode',
    defaultValue: false,
    onChange: (value) {
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
      Get.forceAppUpdate();
    },
  );

  static Setting<double> textScale = Setting(
    title: '文字大小',
    key: 'text_scale',
    defaultValue: Platform.isIOS || Platform.isAndroid ? 0.8 : 1.0,
    values: {
      '小': 0.8,
      '中': 1.0,
      '大': 1.2,
    },
    onChange: (value) {
      Get.forceAppUpdate();
    },
  );

  static Setting<String> layoutDirection = Setting(
      title: '布局方向',
      key: 'layout_direction',
      defaultValue: "auto",
      values: {
        '自動': "auto",
        '固定豎向': Orientation.portrait.toString(),
        '固定橫向': Orientation.landscape.toString(),
      });

  static Setting<bool> filterNoCHS = Setting(
    title: '過濾簡體字幕的動漫',
    key: 'filter_no_chs',
    defaultValue: false,
  );

  static Setting<String> qBittorrentAPIUrl = Setting(
    title: 'qBittorrent API 接入點',
    key: 'qbittorrent_api_url',
    defaultValue: 'http://localhost:8080',
    validator: RegExp(r'^https?://.+'),
  );

  static Setting<String> animeProvider = Setting(
      title: '來源',
      key: 'anime_provider',
      defaultValue: '動漫花園 [動漫]',
      onChange: (_) async => await Get.forceAppUpdate(),
      values: {for (var key in animeProviders.keys) key: key});

  static final Map<String, AnimeProvider> animeProviders = {
    '動漫花園 [所有分類]': AnimeProvider(
      name: '動漫花園 [所有分類]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/rss.xml',
    ),
    '動漫花園 [動漫]': AnimeProvider(
      name: '動漫花園 [動漫]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=2&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/2/rss.xml',
    ),
    '動漫花園 [動漫音樂]': AnimeProvider(
      name: '動漫花園 [動漫音樂]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=43&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/43/rss.xml',
    ),
    '動漫花園 [遊戲]': AnimeProvider(
      name: '動漫花園 [遊戲]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=9&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/9/rss.xml',
    ),
    '動漫花園 [漫畫]': AnimeProvider(
      name: '動漫花園 [漫畫]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=3&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/3/rss.xml',
    ),
    '動漫花園 [日劇]': AnimeProvider(
      name: '動漫花園 [日劇]',
      searchUrl:
          'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=6&order=date-desc',
      latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/6/rss.xml',
    ),
    'ACG.RIP [所有分類]': AnimeProvider(
      name: 'ACG.RIP [所有分類]',
      searchUrl: 'https://acg.rip/.xml?term=%q',
      latestUrl: 'https://acg.rip/.xml',
    ),
    'ACG.RIP [動漫]': AnimeProvider(
      name: 'ACG.RIP [動漫]',
      searchUrl: 'https://acg.rip/1.xml?term=%q',
      latestUrl: 'https://acg.rip/1.xml',
    ),
    'Bangumi Moe': AnimeProvider(
        name: 'Bangumi Moe',
        searchUrl: 'https://bangumi.moe/rss/search/%q',
        latestUrl: 'https://bangumi.moe/rss/latest'),
    'KissSub [所有分類]': AnimeProvider(
        name: 'KissSub [所有分類]',
        searchUrl: 'https://www.kisssub.org/rss-%q.xml',
        latestUrl: 'https://www.kisssub.org/rss.xml'),
    'KissSub [動漫]': AnimeProvider(
        name: 'KissSub [動漫]',
        searchUrl: 'https://kisssub.org/rss-%q+sort_id:1.xml',
        latestUrl: 'https://www.kisssub.org/rss-1.xml'),
    'KissSub [漫畫]': AnimeProvider(
        name: 'KissSub [漫畫]',
        searchUrl: 'https://kisssub.org/rss-%q+sort_id:2.xml',
        latestUrl: 'https://www.kisssub.org/rss-2.xml'),
    'KissSub [音樂]': AnimeProvider(
        name: 'KissSub [音樂]',
        searchUrl: 'https://kisssub.org/rss-%q+sort_id:3.xml',
        latestUrl: 'https://www.kisssub.org/rss-3.xml'),
    'KissSub [其他]': AnimeProvider(
        name: 'KissSub [其他]',
        searchUrl: 'https://kisssub.org/rss-%q+sort_id:5.xml',
        latestUrl: 'https://www.kisssub.org/rss-5.xml'),
    'Mikan': AnimeProvider(
      name: 'Mikan',
      searchUrl: 'http://mikanani.me/RSS/Search?searchstr=%q',
      latestUrl: 'http://mikanani.me/RSS/Classic',
    ),
    'Nyaa [所有分類]': AnimeProvider(
      name: 'Nyaa [所有分類]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q',
      latestUrl: 'https://nyaa.si/?page=rss',
    ),
    'Nyaa [動漫]': AnimeProvider(
      name: 'Nyaa [動漫]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=1_0&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=1_0&f=0',
    ),
    'Nyaa [音樂]': AnimeProvider(
      name: 'Nyaa [音樂]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=2_0&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=2_0&f=0',
    ),
    'Nyaa [音樂 - 無損]': AnimeProvider(
      name: 'Nyaa [音樂 - 無損]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=2_1&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=2_1&f=0',
    ),
    'Nyaa [小說]': AnimeProvider(
      name: 'Nyaa [小說]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=3_0&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=3_0&f=0',
    ),
    'Nyaa [圖片]': AnimeProvider(
      name: 'Nyaa [圖片]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=5_0&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=5_0&f=0',
    ),
    'Nyaa [軟體]': AnimeProvider(
      name: 'Nyaa [軟體]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=6_1&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=6_1&f=0',
    ),
    'Nyaa [遊戲]': AnimeProvider(
      name: 'Nyaa [遊戲]',
      searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=6_2&f=0',
      latestUrl: 'https://nyaa.si/?page=rss&c=6_2&f=0',
    ),
  };

  static AnimeProvider get currentAnimeProvider =>
      animeProviders[animeProvider.value]!;

  static Future<void> reset() async {
    await GetStorage().erase();
    darkMode.value = darkMode.defaultValue;
  }
}
