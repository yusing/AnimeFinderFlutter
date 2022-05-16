import 'dart:convert';
import 'dart:typed_data';

import 'package:anime_finder/service/qbittorrent.dart';
import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:webfeed/webfeed.dart';

import 'anime_provider.dart';

const jikanBaseUrl = 'https://api.jikan.moe/v4/anime/';

class Anime {
  final String? provider;
  final String? title;
  final String? misc;
  final String? magnetUrl;
  String? _imageUrl;
  String? _description;
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
    _image ??= Visibility(
      visible: imageUrl != null,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(kAnimeCardBorderRadius)),
        child: FadeInImage.memoryNetwork(
            alignment: Alignment.center,
            image: imageUrl ?? '',
            placeholder: kTransparentImage,
            imageErrorBuilder: (context, image, error) =>
                const Visibility(visible: false, child: SizedBox()),
            fit: BoxFit.scaleDown),
      ),
    );
    return _image!;
  }

  Future<String> get description async {
    if (_description == null) {
      final response = await http.get(Uri.parse('$jikanBaseUrl?q=$title'));
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes))['data'][0];
        _description =
            "${data['title_japanese'] ?? ""} - ${data['title_english'] ?? ""}\n\n${data['synopsis']}";
      } catch (e, st) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: st);
        _description = "找不到動漫簡介 :(";
      }
    }
    return _description!;
  }

  Future<void> download() async {
    if (magnetUrl == null) {
      return Future.error("找不到磁力鏈結");
    }
    try {
      await QBittorrent.addTorrent(
          urls: [magnetUrl!], category: 'AnimeFinder', tags: imageUrl);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  static List<Anime> parseRssItems(Iterable<RssItem> items) {
    if (Settings.filterNoCHS.value) {
      // filter out items with simplified Chinese title
      items = items.where((item) =>
          item.title == null ||
          !item.title!.contains(
            RegExp(r'简体|CHS|GB'),
          ));
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
          // TODO: support atom if needed
          throw UnimplementedError();
        }
      } else {
        debugPrint(utf8.decode(response.bodyBytes));
        throw Exception('Failed to load rss feed');
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
