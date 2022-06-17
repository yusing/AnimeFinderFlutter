import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:anime_finder/service/platform.dart';
import 'package:anime_finder/utils/http.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'libtorrent_wrapper.dart';

extension NativeTypeExtension on Pointer<Void> {
  /* Torrent Properties */
  int get torrentVecSize => libTorrent.torrent_vec_size(this);
  Pointer<Void> torrentHandleAt(int index) =>
      libTorrent.torrent_handle_at(this, index);

  String get torrentName => libTorrent.torrent_name(this).toDartString();
  String get torrentSavePath =>
      libTorrent.torrent_save_path(this).toDartString();
  String get state => libTorrent.torrent_state(this).toDartString();
  String get torrentFullPath => path.join(torrentSavePath, torrentName);
  String fileFullPath(Pointer<Void> fileInfoPtr) =>
      path.join(torrentSavePath, fileInfoPtr.filePath);
  double get progress => libTorrent.torrent_progress(this);
  int get torrentFileSize => libTorrent.torrent_file_size(this);
  int get downloadRate => libTorrent.torrent_download_rate(this);
  bool get paused => libTorrent.torrent_paused(this);
  bool get finished => libTorrent.torrent_finished(this);

  /* Torrent Actions */
  void pause() {
    libTorrent.pause_torrent(this);
  }

  void resume() {
    libTorrent.resume_torrent(this);
  }

  void remove() {
    libTorrent.remove_torrent(this);
  }

  /* Torrent File Info */
  Pointer<Void> fileInfoVec() => libTorrent.torrent_files(this);
  int get fileInfoVecSize => libTorrent.torrent_num_files(this);
  Pointer<Void> fileInfoAt(int index) => libTorrent.file_info_at(this, index);

  String get fileName => libTorrent.file_name(this).toDartString();
  String get filePath => libTorrent.file_path(this).toDartString();
  int get fileSize => libTorrent.file_size(this);
}

late final Directory privateDir;
late final String torrentSavePathRoot;
final libTorrent = LibTorrent(DynamicLibrary.process());
late Timer printQueueTimer;
final logger = Logger();

Future<void> initDirectories() async {
  Directory documentDir;
  if (AFPlatform.isDesktop) {
    documentDir = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  } else if (Platform.isAndroid) {
    documentDir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
  } else {
    documentDir = await getApplicationDocumentsDirectory();
  }
  torrentSavePathRoot = path.join(documentDir.path, 'AnimeFinderDownloads');
  final torrentSaveDir = Directory.fromUri(Uri.parse(torrentSavePathRoot));
  if (!await torrentSaveDir.exists()) {
    await torrentSaveDir.create(recursive: true);
  }
  privateDir = torrentSaveDir;
}

Future<void> initLibTorrent() async {
  if (kDebugMode) {
    printQueueTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      do {
        final msg = libTorrent.print_queue_last();
        if (msg == nullptr) {
          return;
        }
        debugPrint(msg.toDartString());
        libTorrent.pop_print_queue();
      } while (true);
    });
  }
  await initDirectories();
  final sessionDBPath = path.join(privateDir.path, 'session.db');
  libTorrent.init_session(sessionDBPath.toNativeString());
}

Future<void> addTorrent(String title, String magnetUrl) async {
  final savePath = path.join(torrentSavePathRoot, title.hashCode.toString());
  final saveDir = Directory.fromUri(Uri.parse(savePath));
  if (!await saveDir.exists()) {
    await saveDir.create();
  }
  var logger = Logger();
  logger.d('Magnet Download\n'
      'Downloading $title\n'
      'Save path: ${saveDir.path}\n'
      'Magnet Url = $magnetUrl');
  if (magnetUrl.toLowerCase().endsWith('.torrent')) {
    // download torrent file first
    var client = MyHttpOverrides().createHttpClient(null);
    var request = await client.getUrl(Uri.parse(magnetUrl));
    var response = await request.close();
    var torrentFile =
        File(path.join(saveDir.path, '${title.hashCode}.torrent'));
    var bytes = await consolidateHttpClientResponseBytes(response);
    await torrentFile.writeAsBytes(bytes);
    libTorrent.add_torrent(
        torrentFile.path.toNativeString(), saveDir.path.toNativeString(), true);
  }
  libTorrent.add_torrent(
      magnetUrl.toNativeString(), saveDir.path.toNativeString(), false);
}

Future<void> removeTorrent(Pointer<Void> torrentPtr) async {
  libTorrent.remove_torrent(torrentPtr);
}
