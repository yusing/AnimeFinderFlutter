import 'package:anime_finder/pages/search_result.dart';
import 'package:anime_finder/service/search_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/utils/show_toast.dart';
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
    _searchBarController.dispose();
    super.dispose();
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

  Future<void> _performSearch() async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_searchBarController.text.isEmpty) {
      await showToast(
        message: trSearchbarEmpty,
      );
      return;
    }
    await SearchHistory.add(_searchBarController.text);
    await Get.off(() => SearchResultPage(keyword: _searchBarController.text));
  }
}
