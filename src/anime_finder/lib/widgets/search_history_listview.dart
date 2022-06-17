import 'package:anime_finder/service/search_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SearchHistoryListView extends StatefulWidget {
  final TextEditingController Function() searchBarControllerDelegate;
  final void Function() searchDelegate;
  const SearchHistoryListView(
      {Key? key,
      required this.searchBarControllerDelegate,
      required this.searchDelegate})
      : super(key: key);

  @override
  State<SearchHistoryListView> createState() => _SearchHistoryListViewState();
}

class _SearchHistoryListViewState extends State<SearchHistoryListView> {
  @override
  Widget build(BuildContext context) {
    var searchHistory = SearchHistory.fetch();
    if (searchHistory.isEmpty) {
      return Center(
        child: Text(
          trNoSearchHistory,
          style: kBodyMedium,
        ),
      );
    }
    return ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: searchHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.history, color: kOnBackgroundColorDark),
            title: Text(
              searchHistory[index],
              style: kBodyMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: searchHistory[index] !=
                      widget.searchBarControllerDelegate().text,
                  child: Transform.rotate(
                    angle: -45 / 180 * math.pi,
                    child: IconButton(
                      splashRadius: kIconButtonSplashRadius,
                      icon: Icon(Icons.arrow_upward,
                          color: kOnBackgroundColorDark),
                      onPressed: () {
                        setState(() {
                          widget.searchBarControllerDelegate().text =
                              searchHistory[index];
                          widget.searchBarControllerDelegate().selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: searchHistory[index].length));
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 24,
                  icon: Icon(Icons.delete, color: kOnBackgroundColorDark),
                  onPressed: () async {
                    await SearchHistory.remove(index);
                    setState(() {});
                  },
                ),
              ],
            ),
            onTap: () {
              setState(() {
                widget.searchBarControllerDelegate().text =
                    searchHistory[index];
              });
              widget.searchDelegate();
            },
          );
        });
  }
}
