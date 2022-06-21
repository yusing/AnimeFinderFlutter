import 'dart:io';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/open_file.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/af_animated_list.dart';
import 'package:anime_finder/widgets/slidable_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/utils.dart';
import 'package:path/path.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({Key? key}) : super(key: key);

  static final actions = <Widget>[];

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  var watchHistories = WatchHistory.get();
  var filter = WatchHistoryEntryType.all;
  final globalKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return AFAnimatedList(
        key: globalKey,
        initialItemCount: watchHistories.value.length + 1,
        builder: buildItem);
  }

  Widget buildItem(BuildContext context, int index) {
    if (index == 0) {
      return ListTile(
        leading: const Icon(Icons.filter_alt_rounded),
        title: Text(
          trFilterBy,
          style: kTitleMedium,
        ),
        trailing: DropdownButton<WatchHistoryEntryType>(
          value: filter,
          onChanged: (value) {
            if (filter == value) {
              return; // no change
            }
            filter = value!;
            watchHistories = WatchHistory.get();
            if (value != WatchHistoryEntryType.all) {
              watchHistories.value = watchHistories.value
                  .where((entry) => entry.type == value)
                  .toList();
            }
            setState(() {});
          },
          items: WatchHistoryEntryType.values.map((type) {
            return DropdownMenuItem<WatchHistoryEntryType>(
              value: type,
              child: Text(
                watchHistoryEntryTypeStringKey[type.index].tr,
                style: kBodyMedium,
              ),
            );
          }).toList(),
        ),
      );
    }
    index -= 1;
    final watchHistory = watchHistories.value[index];
    watchHistory.position ??= 0;
    if (watchHistory.duration == null || watchHistory.duration == 0) {
      watchHistory.duration = 1;
    }
    double progress = watchHistory.position! / watchHistory.duration!;
    if (Platform.isIOS) {
      // iOS: App GUID may different on each build
      watchHistory.path = torrentSavePathRoot +
          watchHistory.path.substring(
              watchHistory.path.indexOf('/AnimeFinderDownloads/') +
                  '/AnimeFinderDownloads'.length);
    }
    return Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            DeleteSlidableAction(
              onPressed: (_) {
                AFAnimatedList.removeItem(globalKey, index, () {
                  watchHistories.value.removeAt(index);
                  WatchHistory.remove(watchHistory.id);
                });
              },
            )
          ],
        ),
        child: ListTile(
          leading: Icon(
            watchHistory.type == WatchHistoryEntryType.video
                ? Icons.video_library
                : watchHistory.type == WatchHistoryEntryType.audio
                    ? Icons.audiotrack
                    : Icons.image,
          ),
          title: Text(watchHistory.title, style: kBodyMedium),
          subtitle: progress < 0.05
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    color:
                        progress < 0.9 ? Colors.redAccent : Colors.greenAccent,
                    backgroundColor: kBackgroundColor,
                  ),
                ),
          onTap: () {
            debugPrint(
                'Position: ${watchHistory.position} / ${watchHistory.duration} $progress');
            openFile(watchHistory.path,
                    folderPath: dirname(watchHistory.path),
                    name: watchHistory.title,
                    type: watchHistory.type)
                .then((value) => setState(() {
                      watchHistories = WatchHistory.get();
                    })); // update progress after opening file
          },
        ));
  }
}
