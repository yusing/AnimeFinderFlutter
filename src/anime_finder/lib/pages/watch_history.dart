import 'dart:io';

import 'package:anime_finder/service/file.dart';
import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({Key? key}) : super(key: key);

  static final actions = <Widget>[];

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final watchHistories = WatchHistory.get();
    if (watchHistories.value.isEmpty) {
      return Center(
        child: Text(
          trPageNothingYet,
          style: kTitleMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: watchHistories.value.length,
      itemBuilder: (_, index) {
        final watchHistory = watchHistories.value
            .elementAt(watchHistories.value.length - 1 - index);
        final progress =
            watchHistory.position != null && watchHistory.duration != null
                ? watchHistory.position! / (watchHistory.duration! - 1)
                : 0.0;
        if (Platform.isIOS) { // iOS: App GUID may different on each build
          watchHistory.path = torrentSavePathRoot +
              watchHistory.path.substring(
                  watchHistory.path.indexOf('/AnimeFinderDownloads/') +
                      '/AnimeFinderDownloads'.length);
        }
        debugPrint('${watchHistory.title} Progress: $progress');
        return ListTile(
          // video
          title: Text(watchHistory.title, style: kBodyMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(
              value: progress,
              color: progress != 1 ? Colors.redAccent : Colors.greenAccent,
              backgroundColor: kBackgroundColor,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              WatchHistory.remove(watchHistory.id);
              setState(() {});
            },
          ),
          onTap: () {
            openFile(watchHistory.path,
                    folderPath: watchHistory.path,
                    name: watchHistory.title,
                    type: watchHistory.type)
                .then((value) =>
                    setState(() {})); // update progress after opening file
          },
        );
      },
    );
  }
}
