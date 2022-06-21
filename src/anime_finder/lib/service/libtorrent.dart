import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:anime_finder/utils/http.dart';
import 'package:anime_finder/utils/platform.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'libtorrent_wrapper.dart';

class Torrent {
  late int index;
  late String name;
  late String savePath;
  late String state;
  late String fullPath;
  late double progress;
  late int fileSize;
  late int downloadRate;
  late bool paused;
  late bool finished;

  Torrent(this.index) {
    if (index == -1) {
      index = 0;
      name = '';
      savePath = '';
      state = '';
      fullPath = '';
      progress = 0;
      fileSize = 0;
      downloadRate = 0;
      paused = false;
      finished = false;
    }
    final result = libTorrent.query_torrent(index);
    name = result.ref.name.toDartString();
    savePath = result.ref.save_path.toDartString();
    state = result.ref.state.toDartString();
    fullPath = path.join(savePath, name);
    progress = result.ref.progress;
    fileSize = result.ref.total_size;
    downloadRate = result.ref.download_rate;
    paused = result.ref.paused;
    finished = result.ref.finished;
    calloc.free(result);
    if (name.isNotEmpty) {
      torrentNamesMap[path.basename(savePath)] ??= name;
    } else {
      name = 'Downloading Metadata';
    }
  }

  factory Torrent.empty() {
    return Torrent(-1);
  }

  /* Torrent Properties */
  static int get nTorrents => libTorrent.n_torrents();

  /* Torrent Actions */
  void pause() => libTorrent.pause_torrent(index);
  void resume() => libTorrent.resume_torrent(index);
  void remove() => libTorrent.remove_torrent(index);
}

class FileInfo {
  final String name;
  final String fullPath;
  final int size;

  FileInfo(this.name, this.fullPath, this.size);
}

class Files {
  static List<FileInfo> query(Torrent torrent) {
    if (torrent.index == -1) {
      return [];
    }
    final list = <FileInfo>[];
    final result = libTorrent.query_files(torrent.index);
    final nFiles = result.ref.n_files;
    for (int i = 0; i < nFiles; i++) {
      final fileInfo = libTorrent.query_file(result, i);
      final name = fileInfo.ref.name.toDartString();
      list.add(FileInfo(
        name,
        path.join(torrent.savePath, fileInfo.ref.path.toDartString()),
        fileInfo.ref.size,
      ));
      calloc.free(fileInfo);
    }
    calloc.free(result);
    return list;
  }
}

late final Directory privateDir;
late final String torrentSavePathRoot;
final libTorrent = LibTorrent(Platform.isAndroid
    ? DynamicLibrary.open('libdart_torrent.so')
    : DynamicLibrary.process());
final logger = Logger();
final torrentNamesMap = <String, String>{}; // title.hashCode -> name

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

Stream<String> cacheUsageStream() async* {
  while (true) {
    yield 'String Cache used: ${libTorrent.cache_used().toReadableSize()} (${libTorrent.cache_used_percentage().toStringAsFixed(2)}%)';
    await Future.delayed(const Duration(seconds: 3));
  }
}

Future<void> initLibTorrent() async {
  if (kDebugMode) {
    cacheUsageStream().listen((msg) => debugPrint(msg));
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
  logger.d('Magnet Download\n'
      'Downloading $title\n'
      'Save path: ${saveDir.path}');
  if (magnetUrl.toLowerCase().startsWith('http')) {
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

Future<void> removeTorrent(int index, String savePath) async {
  libTorrent.remove_torrent(index);
  try {
    await Directory(savePath).delete(recursive: true);
  } catch (e) {
    // ignore
  }
}

Stream<int> tableUpdateStream() async* {
  while (true) {
    if (libTorrent.need_update()) {
      yield Torrent.nTorrents;
      libTorrent.updated();
    }
    await Future.delayed(const Duration(seconds: 1));
  }
}

Stream<Torrent> progressUpdateStream(int torrentIndex) async* {
  Torrent t;
  while (true) {
    t = Torrent(torrentIndex);
    yield t;
    if (t.finished) return;
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
