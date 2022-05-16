import 'dart:async';

import 'package:anime_finder/service/platform.dart';
import 'package:anime_finder/service/qbittorrent.dart';
import 'package:anime_finder/theme/style.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final _scrollController = ScrollController();
  final _future = QBittorrent.getTorrents(category: 'AnimeFinder');
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Torrent>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text('還沒有下載任何動畫'),
            );
          }
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (!timer.isActive) {
              return;
            }
            for (var torrent in snapshot.data!) {
              await torrent.update();
            }
            if (!timer.isActive) {
              return;
            }
            setState(() {});
          });
          return ListView.separated(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final torrent = snapshot.data![index];
                return ListTile(
                    title: Text(torrent.name, style: kBodyMedium),
                    subtitle: Text(
                      '${torrent.state}: ${(torrent.progress * 100).round()}%',
                      style: kBodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // pause and ersume
                        Visibility(
                            visible:
                                torrent.isDownloading || torrent.isPaused,
                            child: Tooltip(
                              message: torrent.isPaused ? '繼續下載' : '暫停下載',
                              child: IconButton(
                                splashRadius: kIconButtonSplashRadius,
                                icon: Icon(torrent.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause),
                                onPressed: () async {
                                  await torrent.toggleResumePause();
                                  setState(() {});
                                },
                              ),
                            )),
                        Visibility(
                            visible:
                                AFPlatform.isDesktop && torrent.isCompleted,
                            child: Tooltip(
                              message: '打開',
                              child: IconButton(
                                splashRadius: kIconButtonSplashRadius,
                                icon: const Icon(Icons.launch),
                                onPressed: () async {
                                  debugPrint(
                                      'Path: ${torrent.save_path}/${torrent.name}');
                                  String url =
                                      'file://${torrent.save_path}/${torrent.name}';
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url);
                                  }
                                },
                              ),
                            )),
                        Visibility(
                            visible:
                                AFPlatform.isDesktop && torrent.isCompleted,
                            child: Tooltip(
                              message: '打開所在文件夾',
                              child: IconButton(
                                splashRadius: kIconButtonSplashRadius,
                                icon: const Icon(Icons.folder),
                                onPressed: () async {
                                  debugPrint('Path: ${torrent.save_path}');
                                  String url = 'file://${torrent.save_path}';
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url);
                                  }
                                },
                              ),
                            )),
                        Tooltip(
                          message: '刪除',
                          child: IconButton(
                            splashRadius: kIconButtonSplashRadius,
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await torrent.delete();
                              setState(() {
                                snapshot.data!.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ));
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ));
        } else if (snapshot.hasError) {
          return Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text('${snapshot.error}', textAlign: TextAlign.center));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
