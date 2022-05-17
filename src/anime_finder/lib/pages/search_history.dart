import 'package:anime_finder/pages/search_result.dart';
import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/search_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/anime_list.dart';
import 'package:anime_finder/widgets/search_bar.dart';
import 'package:anime_finder/widgets/search_history_listview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: 自動搜尋所有集數
class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({Key? key}) : super(key: key);

  @override
  State<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  final _searchBarController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(searchBarController: _searchBarController),
      body: SearchHistoryListView(
              searchBarControllerDelegate: () => _searchBarController,
              searchDelegate: _performSearch,
            ),
    );
  }

  void _performSearch() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_searchBarController.text.isEmpty) {
      Get.snackbar(
        trSearchbarEmpty,
        '',
        duration: kSnackbarDuration,
        snackPosition: kSnackbarPosition,
        backgroundColor: kBackgroundColor,
        colorText: kOnBackgroundColor,
      );
      return;
    }

    Get.to(() => SearchResultPage(keyword: _searchBarController.text));
  }
}
