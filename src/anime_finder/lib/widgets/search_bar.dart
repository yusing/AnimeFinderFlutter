import 'package:anime_finder/pages/search_history.dart';
import 'package:anime_finder/pages/search_result.dart';
import 'package:anime_finder/service/search_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBar extends AppBar {
  SearchBar(
      {Key? key,
      required TextEditingController searchBarController,
      bool showSearchButton = true})
      : super(
          key: key,
          automaticallyImplyLeading: false,
          leadingWidth: 54,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
                splashRadius: kIconButtonSplashRadius,
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Get.back()),
          ),
          foregroundColor: kOnBackgroundColor,
          title: TextField(
            autofocus: false,
            decoration: InputDecoration(
              hintText: trSearchbarHint,
              hintStyle: kBodyMedium.copyWith(
                color: kOnBackgroundColorDarker,
              ),
              border: InputBorder.none,
            ),
            controller: searchBarController,
            style: kBodyMedium,
            maxLines: 1,
            onTap: () => Get.to(() => const SearchHistoryPage()),
          ),
          actions: showSearchButton
              ? [
                  IconButton(
                    splashRadius: kIconButtonSplashRadius,
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () async {
                      await SearchHistory.add(searchBarController.text);
                      await Get.off(() =>
                          SearchResultPage(keyword: searchBarController.text));
                    },
                  ),
                  const SizedBox(width: 16)
                ]
              : null,
        );
}
