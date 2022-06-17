import 'dart:convert';

// import 'package:anime_finder/service/qbittorrent.dart.old';
import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:webfeed/webfeed.dart';

import 'anime_provider.dart';

class Anime {
  final String? provider;
  final String? title;
  final String? misc;
  final String? magnetUrl;
  String? _imageUrl;
  Widget? _image;

  Anime({
    required this.provider,
    required this.title,
    required this.misc,
    required this.magnetUrl,
  });

  String? get imageUrl {
    if (_imageUrl == null) {
      if (misc == null) {
        return null;
      }
      final match = RegExp(r'<img.*?src="(.*?)"').firstMatch(misc!);
      if (match == null) {
        return null;
      }
      _imageUrl = match.group(1);
    }
    return _imageUrl;
  }

  Widget image() {
    if (imageUrl == null) {
      return const SizedBox();
    }
    _image ??= ClipRRect(
      borderRadius:
          const BorderRadius.all(Radius.circular(kAnimeCardBorderRadius)),
      child: CachedNetworkImage(
          alignment: Alignment.center,
          imageUrl: imageUrl!,
          placeholder: (context, url) => Image.memory(kTransparentImage ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.scaleDown),
    );
    return _image!;
  }

  static List<Anime> parseRssItems(Iterable<RssItem> items) {
    final regFilter = Settings.filterNoChinese.value
        ? RegExp(r'[^\u4e00-\u9fa5]')
        : Settings.filterNoCHS.value
            ? RegExp(r'简体|CHS|GB')
            : null;

    if (regFilter != null) {
      items = items.where(
          (item) => item.title != null && !item.title!.contains(regFilter));
    }

    return [
      for (final item in items)
        Anime(
          provider: item.author,
          title: item.title,
          misc: item.description,
          magnetUrl: item.enclosure?.url ?? item.link,
        )
    ];
  }

  static Future<List<Anime>> getAnimes(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'encoding': 'utf-8',
        'Content-Type': 'application/xml;charset=utf-8'
      });
      if (response.statusCode == 200) {
        if (Settings.currentAnimeProvider.feedType == FeedType.rss) {
          final rss = RssFeed.parse(utf8.decode(response.bodyBytes));
          return rss.items == null ? [] : parseRssItems(rss.items!);
        } else {
          throw UnimplementedError();
        }
      } else {
        debugPrint(utf8.decode(response.bodyBytes));
        throw Exception(trConnectionError);
      }
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }

  static Future<List<Anime>> search(String keyword) async {
    return await getAnimes(
        Settings.currentAnimeProvider.searchUrlKeyword(keyword));
  }

  static Future<List<Anime>> latestAnimes() async {
    return await getAnimes(Settings.currentAnimeProvider.latestUrl);
  }
}
