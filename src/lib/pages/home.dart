import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/widgets/anime_list.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static var _future = Anime
      .latestAnimes(); // static makes it does not reload when switching page

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh, child: AnimeList(future: _future));
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = Anime.latestAnimes();
    });
  }
}
