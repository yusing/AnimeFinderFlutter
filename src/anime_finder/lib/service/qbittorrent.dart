// ref: https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)
import 'dart:convert';
import 'dart:io';
import 'package:anime_finder/service/translation.dart';
import 'package:byte_size/byte_size.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'settings.dart';

class Torrent {
  final int addedOn;
  String category;
  int dlspeed;
  int eta;
  final String hash;
  String name;
  String state;
  dynamic progress;
  String savePath;

  Torrent({
    required this.addedOn,
    required this.category,
    required this.dlspeed,
    required this.eta,
    required this.hash,
    required this.name,
    required this.state,
    required this.progress,
    required this.savePath,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      addedOn: json['added_on'],
      category: json['category'],
      dlspeed: json['dlspeed'],
      eta: json['eta'],
      hash: json['hash'],
      name: json['name'],
      state: json['state'],
      progress: json['progress'],
      savePath: json['save_path'],
    );
  }

  bool get isDownloading =>
      state == 'downloading' ||
      state == 'stalled' ||
      state == 'checking' ||
      state == 'allocating' ||
      state == 'metaDL' ||
      state == 'checkingDL' ||
      state == 'forceDL';
  bool get isPaused => state == 'pausedUP' || state == 'pausedDL';
  bool get isCompleted =>
      state == 'uploading' ||
      state == 'stalledUP' ||
      state == 'queuedUP' ||
      state == 'forcedUP';

  String get status {
    var torrentInfo = '${state.tr}$trColon${(progress * 100).round()}% ';
    if (isDownloading) torrentInfo += '(${ByteSize.FromBytes(dlspeed)}/s)';
    return torrentInfo;
  }

  Future<void> delete() async {
    try {
      debugPrint('Deleting torrent: $name');
      await http.get(QBittorrent.endPointUri(
          '/api/v2/torrents/delete?hashes=$hash&deleteFiles=true'));
    } catch (e, st) {
      debugPrint('Failed to delete torrent: $e');
      debugPrintStack(stackTrace: st);
      return Future.error('Failed to delete torrent');
    }
  }

  Future<void> pause() async {
    try {
      debugPrint('Pausing torrent: $name');
      await http
          .get(QBittorrent.endPointUri('/api/v2/torrents/pause?hashes=$hash'));
    } catch (e, st) {
      debugPrint('Failed to pause torrent: $e');
      debugPrintStack(stackTrace: st);
      return Future.error('Failed to pause torrent');
    }
  }

  Future<void> resume() async {
    try {
      debugPrint('Resuming torrent: $name');
      await http
          .get(QBittorrent.endPointUri('/api/v2/torrents/resume?hashes=$hash'));
    } catch (e, st) {
      debugPrint('Failed to resume torrent: $e');
      debugPrintStack(stackTrace: st);
      return Future.error('Failed to resume torrent');
    }
  }

  Future<void> toggleResumePause() async {
    if (isPaused) {
      await resume();
    } else {
      await pause();
    }
  }

  Future<void> update() async {
    try {
      final response = await http
          .get(QBittorrent.endPointUri('/api/v2/torrents/info?hashes=$hash'));
      if (response.statusCode != 200) {
        debugPrint('Failed to update torrent: ${response.statusCode}');
        return Future.error('Failed to update torrent');
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      // update members
      name = json[0]['name'];
      category = json[0]['category'];
      dlspeed = json[0]['dlspeed'];
      eta = json[0]['eta'];
      state = json[0]['state'];
      progress = json[0]['progress'];
      savePath = json[0]['save_path'];
    } catch (e, st) {
      debugPrint('Failed to update torrent: $e');
      debugPrintStack(stackTrace: st);
      return Future.error('Failed to update torrent');
    }
  }
}

enum Filter {
  all,
  downloading,
  seeding,
  completed,
  paused,
  active,
  inactive,
  resumed,
  stalled,
  stalledUploading,
  stalledDownloading,
  errored
}

class QBittorrent {
  static Uri endPointUri(String endPoint) {
    return Uri.parse('${Settings.qBittorrentAPIUrl.value}$endPoint');
  }

  static Future<http.Response> get(String endPoint,
      {int timeoutSecs = 1}) async {
    try {
      var response = await http
          .get(endPointUri(endPoint))
          .timeout(Duration(seconds: timeoutSecs), onTimeout: () {
        throw Exception(trQbtErrorMsg);
      });
      if (response.statusCode != 200) {
        return Future.error(trQbtErrorMsg);
      }
      return response;
    } on SocketException {
      return Future.error(trQbtErrorMsg);
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      return Future.error(trQbtErrorMsg);
    }
  }

  static Future<List<Torrent>> getTorrents(
      {Filter? filter, String? category}) async {
    String params = '?sort=name';
    if (filter != null) {
      params += '&filter=${filter.toString().split('.').last}';
    }
    if (category != null) {
      params += '&category=$category';
    }
    try {
      var response = await get('/api/v2/torrents/info$params');
      return [
        for (var torrent in jsonDecode(utf8.decode(response.bodyBytes)))
          Torrent.fromJson(torrent)
      ];
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  static Future<void> addTorrent(
      {required List<String> urls,
      String? category,
      String? tags,
      String? rename}) async {
    try {
      debugPrint('Adding torrents... ${urls.join(', ')}');
      var body = {
        'urls': urls.join('\n'),
      };
      if (category != null) {
        body['category'] = category;
      }
      if (tags != null) {
        body['tags'] = tags;
      }
      if (rename != null) {
        body['rename'] = rename;
      }
      await http.post(
        endPointUri('/api/v2/torrents/add'),
        body: body,
      );
    } catch (e, st) {
      debugPrint('Failed to add torrent: $e');
      debugPrintStack(stackTrace: st);
      return Future.error(trQbtErrorMsg);
    }
  }
}
