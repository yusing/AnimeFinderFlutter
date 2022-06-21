import 'dart:async';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:anime_finder/widgets/af_animated_list.dart';
import 'package:anime_finder/widgets/file_list.dart';
import 'package:anime_finder/widgets/play_pause_button.dart';
import 'package:anime_finder/widgets/slidable_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class DownloadsTable extends StatefulWidget {
  const DownloadsTable({Key? key}) : super(key: key);

  @override
  State<DownloadsTable> createState() => _DownloadsTableState();
}

class _DownloadsTableState extends State<DownloadsTable> {
  final scrollController = ScrollController();
  final globalKey = GlobalKey<AnimatedListState>();
  late StreamSubscription<int> _tableUpdateSubscription;
  late int nTorrents;

  @override
  void initState() {
    nTorrents = Torrent.nTorrents;
    _tableUpdateSubscription = tableUpdateStream().listen((nTorrentsUpdated) {
      while (nTorrentsUpdated > nTorrents) {
        globalKey.currentState!.insertItem(0);
        --nTorrentsUpdated;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _tableUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AFAnimatedList(
      key: globalKey,
      controller: scrollController,
      initialItemCount: nTorrents,
      builder: buildItem,
    );
  }

  Widget buildItem(BuildContext context, int torrentIndex) {
    return Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            DeleteSlidableAction(onPressed: (_) {
              AFAnimatedList.removeItem(globalKey, torrentIndex, () {
                removeTorrent(torrentIndex, Torrent(torrentIndex).savePath);
                nTorrents = Torrent.nTorrents;
              });
            })
          ],
        ),
        child: ListTile(
          title: StreamBuilder<Torrent>(
              stream: progressUpdateStream(torrentIndex),
              builder: (context, snapshot) {
                final torrent = snapshot.data ?? Torrent.empty();
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(torrent.name,
                            style:
                                kBodyMedium.copyWith(color: kHighlightColor))),
                    Visibility(
                      visible: !torrent.finished,
                      child: Tooltip(
                        message: torrent.paused ? trResumeDl : trPauseDl,
                        child: PlayPauseButton(
                          isPlaying: !torrent.paused,
                          play: torrent.resume,
                          pause: torrent.pause,
                        ),
                      ),
                    ),
                  ],
                );
              }),
          subtitle: StreamBuilder<Torrent>(
            stream: progressUpdateStream(torrentIndex),
            builder: (_, snapshot) {
              final torrent = snapshot.data ?? Torrent.empty();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                      torrent.finished
                          ? '${Files.query(torrent).length} $trNumFiles ${torrent.fileSize.toReadableSize()}'
                          : '${torrent.paused ? trPaused : torrent.state.tr} ${torrent.downloadRate.toReadableSize()}/s ${torrent.fileSize.toReadableSize()}',
                      style: kBodySmall),
                  Visibility(
                    visible: !torrent.finished,
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: torrent.progress,
                            color: kOnBackgroundColor,
                            backgroundColor: kBackgroundColor,
                          ),
                        ),
                        Visibility(
                          visible: torrent.progress > 0,
                          child: Text(
                              '${(torrent.progress * 100).toStringAsFixed(2)}%',
                              style: kBodySmall),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
          onTap: () async {
            final torrent = Torrent(torrentIndex);
            var files = Files.query(torrent);
            if (files.isEmpty) {
              await showToast(message: trPageNthYet);
            } else {
              await Get.to(() => Scaffold(
                  appBar: AppBar(
                      title: Text(torrent.name,
                          overflow: TextOverflow.ellipsis,
                          style: kTitleMedium)),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: FileList(torrent, files),
                  )));
            }
          },
        ));
  }
}
