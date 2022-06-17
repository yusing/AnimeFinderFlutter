import 'dart:io';

import 'package:anime_finder/pages/comic_reader.dart';
import 'package:anime_finder/pages/video_player.dart';
import 'package:anime_finder/service/platform.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/utils/file_types.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openFile(String filePath,
    {String? name, String? folderPath, WatchHistoryEntityType? type}) async {
  debugPrint('Opening $filePath, type: $type');

  String url = 'file://$filePath'.encodeUrl();
  String ext = extension(filePath).toLowerCase();
  if (AFPlatform.isDesktop) {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      debugPrint('Could not launch $url');
      await showToast(message: 'Could not open file');
    }
  } else {
    // Mobile

    if (type == WatchHistoryEntityType.video ||
        kVideoExtensions.contains(ext)) {
      assert(name != null);
      if (!await File(filePath).exists()) {
        showToast(message: trFileNotExists);
        return;
      }
      await Get.to(() => VideoPlayerPage(title: name!, filePath: filePath));
    } else if (type == WatchHistoryEntityType.image || kImageExtensions.contains(ext)) {
      assert(name != null);
      assert(folderPath != null);
      await Get.to(() => ComicReaderPage(title: name!, folderPath: folderPath!));
    } else {
      if (name != null && folderPath != null) {
        await Get.to(() => ComicReaderPage(title: name, folderPath: folderPath));
      }
      else {
        await showToast(message: trUnsupportedFileType);
      }
    }
  }
}
