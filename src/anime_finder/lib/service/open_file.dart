import 'dart:io';

import 'package:anime_finder/pages/comic_reader.dart';
import 'package:anime_finder/pages/music_player.dart';
import 'package:anime_finder/pages/video_player.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/utils/file_types.dart';
import 'package:anime_finder/utils/platform.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openFile(String filePath,
    {String? name, String? folderPath, WatchHistoryEntryType? type}) async {
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
    if (!await File(filePath).exists()) {
      showToast(message: trFileNotExists);
      return;
    }
    if (type == WatchHistoryEntryType.video || kVideoExtensions.contains(ext)) {
      assert(name != null);
      await Get.to(() => VideoPlayerPage(title: name!, filePath: filePath));
    } else if (type == WatchHistoryEntryType.image ||
        kImageExtensions.contains(ext)) {
      assert(name != null);
      assert(folderPath != null);
      await Get.to(
          () => ComicReaderPage(title: name!, folderPath: folderPath!));
    } else if (type == WatchHistoryEntryType.audio ||
        kAudioExtensions.contains(ext)) {
      assert(name != null);
      assert(folderPath != null);
      await Get.to(() => MusicPlayerPage(
          title: name!, path: filePath, folderPath: folderPath!));
    } else if (kArchiveExtensions.contains(ext)) {
      assert(folderPath != null);
      showToast(title: 'Extracting', message: basename(filePath));
      final outputPath = join(folderPath!, basenameWithoutExtension(filePath));
      debugPrint('Extracting $filePath to $outputPath');
      await extractFileToDisk(filePath, outputPath);
      await showToast(
          title: 'Extraction completed', message: basename(filePath));
      await File(filePath).delete();
    } else {
      await showToast(message: trUnsupportedFileType);
    }
  }
}
