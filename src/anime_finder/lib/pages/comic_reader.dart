import 'dart:io';

import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/file_types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ComicReaderPage extends StatefulWidget {
  final String folderPath;
  final String title;
  const ComicReaderPage(
      {Key? key, required this.folderPath, required this.title})
      : super(key: key);

  @override
  State<ComicReaderPage> createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  late Directory _dir;
  late List<FileSystemEntity> _files;
  late int _initIndex;
  // late IndexedScrollController _indexedScrollController;

  @override
  void initState() {
    _dir = Directory(widget.folderPath);
    _files = _dir
        .listSync(recursive: true)
        .where((file) => kImageExtensions.contains(extension(file.path)))
        .toList();
    if (_files.isEmpty) {
      Get.back();
    }
    _files.sort((a, b) => a.path.compareTo(b.path));
    final id = widget.title.hashCode;
    _initIndex = WatchHistory.getIndex(id);
    debugPrint('Last read to page $_initIndex');
    WatchHistory.add(WatchHistoryEntry(
        id: id,
        title: widget.title,
        path: widget.folderPath,
        type: WatchHistoryEntryType.image,
        duration: _files.length,
        position: _initIndex));
    super.initState();
  }

  @override
  void dispose() {
    // _indexedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: kTitleSmall),
      ),
      body: ScrollablePositionedList.builder(
          initialScrollIndex: _initIndex,
          itemCount: _files.length,
          itemBuilder: (_, index) {
            final file = _files.elementAt(index);
            return VisibilityDetector(
                key: Key(index.toString()),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction > 0.5) {
                    WatchHistory.updateIndex(widget.title.hashCode, index);
                  }
                },
                child: Image.file(
                  File(file.path),
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.error_outline),
                  ),
                ));
          }),
    );
  }
}
