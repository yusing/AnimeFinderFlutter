import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/widgets/anime_list.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static var reloadNeeded = ValueNotifier(false);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  static var _animeListFuture = Anime.latestAnimes();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return ValueListenableBuilder(
        valueListenable: HomePage.reloadNeeded,
        builder: (context, value, widget) {
          if (HomePage.reloadNeeded.value) {
            _animeListFuture = Anime.latestAnimes();
            HomePage.reloadNeeded.value = false;
            debugPrint('HomePage rebuilt');
          }
          return RefreshIndicator(
              onRefresh: () async {
                _animeListFuture = Anime.latestAnimes();
                HomePage.reloadNeeded.value = true;
              },
              child: AnimeList(animeListFuture: _animeListFuture));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
