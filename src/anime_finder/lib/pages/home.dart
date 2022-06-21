import 'package:anime_finder/pages/search_history.dart';
import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/anime_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static var reloadNeeded = ValueNotifier(false);
  static final actions = [
    IconButton(
      icon: Icon(Icons.search_outlined, color: kOnBackgroundColor),
      onPressed: () => Get.to(() => const SearchHistoryPage()),
    ),
  ];
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  static var _animeListFuture = Anime.latestAnime();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder(
        valueListenable: HomePage.reloadNeeded,
        builder: (context, value, widget) {
          if (HomePage.reloadNeeded.value) {
            _animeListFuture = Anime.latestAnime();
            HomePage.reloadNeeded.value = false;
            debugPrint('HomePage rebuilt');
          }
          return RefreshIndicator(
              onRefresh: () async {
                _animeListFuture = Anime.latestAnime();
                HomePage.reloadNeeded.value = true;
              },
              child: AnimeList(animeListFuture: _animeListFuture));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
