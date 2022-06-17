import 'dart:async';
import 'dart:ffi';

import 'package:anime_finder/service/file.dart';
import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/units.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DownloadsTable extends StatefulWidget {
  const DownloadsTable({Key? key}) : super(key: key);

  @override
  State<DownloadsTable> createState() => _DownloadsTableState();
}

class _DownloadsTableState extends State<DownloadsTable> {
  final scrollController = ScrollController();
  final updateListenable = ValueNotifier<bool>(false);
  var torrentVec = libTorrent.get_torrent_vec();
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      torrentVec = libTorrent.get_torrent_vec();
      updateListenable.value = !updateListenable.value;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    scrollController.dispose();
    updateListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: updateListenable,
        builder: (ctx, o, _) {
          if (torrentVec.torrentVecSize == 0) {
            return Center(
              child: Text(trPageNothingYet, style: kBodyLarge),
            );
          }
          return ListView.separated(
            controller: scrollController,
            itemCount: torrentVec.torrentVecSize,
            itemBuilder: (context, index) {
              final torrent = torrentVec.torrentHandleAt(index);
              final fileInfoVec = torrent.fileInfoVec();
              return ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Visibility(
                        visible: !torrent.finished,
                        child: Text(
                            '${torrent.paused ? "Paused" : torrent.state} ${torrent.downloadRate.toReadableSize()}/s ${(torrent.progress * 100).toStringAsFixed(1)}%',
                            style: kBodySmall),
                      ),
                      Visibility(
                          visible: !torrent.finished,
                          child: LinearProgressIndicator(
                            value: torrent.progress,
                            color: kOnBackgroundColor,
                            backgroundColor: kBackgroundColor,
                          )),
                      fileInfoVec == nullptr
                          ? const SizedBox()
                          : ExpandablePanel(
                              theme: ExpandableThemeData(
                                  iconColor: kOnBackgroundColor,
                                  iconSize: kBodySmall.fontSize,
                                  iconPlacement:
                                      ExpandablePanelIconPlacement.left,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  bodyAlignment:
                                      ExpandablePanelBodyAlignment.left,
                                  alignment: Alignment.centerLeft),
                              header: Text(
                                  '${fileInfoVec.fileInfoVecSize} $trNumFiles (${torrent.torrentFileSize.toReadableSize()})',
                                  style: kBodyMedium),
                              collapsed: const SizedBox(),
                              expanded: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: ScrollController(),
                                  shrinkWrap: true,
                                  itemCount: fileInfoVec.fileInfoVecSize,
                                  itemBuilder: (context, index) {
                                    final fileInfo =
                                        fileInfoVec.fileInfoAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ListTile(
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        visualDensity: VisualDensity.compact,
                                        leading: const Icon(CupertinoIcons.doc),
                                        title: Text(fileInfo.fileName,
                                            style: kBodySmall),
                                        trailing: Text(
                                            fileInfo.fileSize.toReadableSize(),
                                            style: kBodySmall),
                                        dense: true,
                                        onTap: () async => await openFile(
                                            torrent.fileFullPath(fileInfo),
                                            name: torrent.torrentName,
                                            folderPath:
                                                torrent.torrentSavePath),
                                      ),
                                    );
                                  }),
                            )
                    ],
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Text(torrent.torrentName,
                              style: kBodyMedium.copyWith(
                                  color: kHighlightColor))),
                      Visibility(
                        visible: !torrent.finished,
                        child: Tooltip(
                          message: torrent.paused ? trResumeDl : trPauseDl,
                          child: IconButton(
                            icon: Icon(torrent.paused
                                ? Icons.play_arrow
                                : Icons.pause),
                            onPressed: () {
                              if (torrent.paused) {
                                torrent.resume();
                              } else {
                                torrent.pause();
                              }
                            },
                          ),
                        ),
                      ),
                      Tooltip(
                        message: trDelete,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeTorrent(torrent),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await openFile(torrent.torrentFullPath,
                        name: torrent.torrentName,
                        folderPath: torrent.torrentSavePath);
                  });
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 16,
            ),
          );
        });
  }
}
