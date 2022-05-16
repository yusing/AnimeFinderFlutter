import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/search_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/anime_list.dart';
import 'package:anime_finder/widgets/search_history_listview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            splashRadius: kIconButtonSplashRadius,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        foregroundColor: kOnBackgroundColor,
        title: TextField(
          autofocus: false,
          decoration: InputDecoration(
            hintText: '搜尋關鍵字...',
            hintStyle: kBodyMedium.copyWith(
              color: kOnBackgroundColorDarker,
            ),
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
          controller: _searchController,
          style: kBodyMedium,
          maxLines: 1,
          onTap: () {
            if (_showResult == false) return;
            setState(() {
              _showResult = false;
            });
          },
        ),
        actions: [
          IconButton(
            splashRadius: kIconButtonSplashRadius,
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(),
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: _showResult
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimeList(
                  future: Anime.search(
                _searchController.text,
              )),
            )
          : SearchHistoryListView(
              searchBarControllerDelegate: () => _searchController,
              searchDelegate: _performSearch,
            ),
    );
  }

  _performSearch() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_searchController.text.isEmpty) {
      Get.snackbar(
        '請輸入關鍵字',
        '',
        duration: kSnackbarDuration,
        snackPosition: kSnackbarPosition,
        backgroundColor: kBackgroundColor,
        colorText: kOnBackgroundColor,
      );
      return;
    }
    setState(() {
      SearchHistory.add(_searchController.text);
      _showResult = true;
    });
  }
}
