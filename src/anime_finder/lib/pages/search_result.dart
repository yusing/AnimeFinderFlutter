import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/widgets/anime_list.dart';
import 'package:anime_finder/widgets/search_bar.dart';
import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final String keyword;
  late final TextEditingController _searchBarController;

  SearchResultPage({Key? key, required this.keyword}) : super(key: key) {
    _searchBarController = TextEditingController(text: keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
        searchBarController: _searchBarController,
        showSearchButton: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimeList(animeListFuture: Anime.search(keyword))),
    );
  }
}
