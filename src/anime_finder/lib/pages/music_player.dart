import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/duration.dart';
import 'package:anime_finder/utils/file_types.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/widgets/play_pause_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MusicPlayerPage extends StatefulWidget {
  final String title;
  final String path;
  final String folderPath;
  const MusicPlayerPage(
      {super.key,
      required this.title,
      required this.path,
      required this.folderPath});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final _coverPhotoFuture = ValueNotifier<Future<Uint8List>?>(null);
  final _player = AudioPlayer();
  final _itemScrollController = ItemScrollController();
  var _backgroundColor = kBackgroundColor;
  var _foregroundColor = kOnBackgroundColor;
  var _vibrantColor = kBackgroundColor.withOpacity(0.5);
  late Stream _listDirStream;
  late StreamSubscription _listDirStreamSubs;
  late StreamSubscription _playerSubs;
  final List<String> _playlist = [];
  final _playlistReady = ValueNotifier<bool>(true);
  int _currentIndex = 0;

  @override
  void initState() {
    debugPrint('initState');
    _playerSubs = _player.onPlayerComplete.listen((event) {
      if (_currentIndex == _playlist.length - 1) {
        _player.stop();
      } else {
        _playerSubs.cancel();
        updateIndex();
      }
    }, onError: (error) {
      showToast(title: 'Error', message: error.toString());
      logger.d(error.toString());
    });
    _listDirStream = Directory(widget.folderPath).list(recursive: true);
    _listDirStreamSubs = _listDirStream.listen((entry) {
      if (entry is File) {
        final ext = extension(entry.path).toLowerCase();
        if (_coverPhotoFuture.value == null && kImageExtensions.contains(ext)) {
          debugPrint('Found cover photo\n${basename(entry.path)}');
          _coverPhotoFuture.value = entry.readAsBytes();
        }
        if (kAudioExtensions.contains(ext)) {
          _playlist.add(entry.path);
        }
      }
    }, onDone: () {
      _playlist.sort();
      _currentIndex = _playlist
          .indexWhere((path) => basename(path) == basename(widget.path));
      _playlistReady.value = true;
      _listDirStreamSubs.cancel();
    });
    super.initState();
  }

  void updateIndex({int offset = 1}) {
    if (_currentIndex + offset >= _playlist.length ||
        _currentIndex + offset < 0) {
      return;
    }
    _itemScrollController.scrollTo(
        index: _currentIndex += offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    setState(() {});
  }

  @override
  void dispose() {
    _listDirStreamSubs.cancel();
    _playerSubs.cancel();
    _player.stop();
    _player.dispose();
    _playlistReady.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _playlist.isEmpty ? widget.path : _playlist[_currentIndex];
    final filename = basename(path);
    WatchHistory.add(WatchHistoryEntry(
        id: filename.hashCode,
        title: filename,
        path: path,
        type: WatchHistoryEntryType.audio));
    _player.play(DeviceFileSource(path));
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 32.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [_backgroundColor, _vibrantColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<Future<Uint8List>?>(
                  valueListenable: _coverPhotoFuture,
                  builder: (_, future, __) {
                    return FutureBuilder<Uint8List>(
                      future: future,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          PaletteGenerator.fromImageProvider(
                                  MemoryImage(snapshot.data!))
                              .then((generator) {
                            if (generator.dominantColor == null) return;
                            _backgroundColor = generator.dominantColor!.color;
                            if (generator.vibrantColor != null) {
                              _vibrantColor = generator.vibrantColor!.color;
                            } else {
                              _vibrantColor = _backgroundColor.withOpacity(0.5);
                            }
                            if (_backgroundColor.computeLuminance() > 0.5) {
                              _foregroundColor = Colors.black;
                            } else {
                              _foregroundColor = Colors.white;
                            }
                            setState(() {});
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.all(64),
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12.0)),
                              child: snapshot.hasData
                                  ? Image.memory(snapshot.data!)
                                  : Expanded(
                                      child: Icon(Icons.music_note,
                                          size: 128, color: _foregroundColor))),
                        );
                      },
                    );
                  }),
              Text(filename,
                  style: kTitleMedium.copyWith(
                    color: _foregroundColor,
                  )),
              StreamBuilder<Duration>(
                  // TODO: fix
                  stream: _player.onDurationChanged,
                  builder: (context, durationSnapshot) {
                    if (!durationSnapshot.hasData) {
                      return Slider(
                          value: WatchHistory.getDuration(filename.hashCode)
                              .inSeconds
                              .toDouble(),
                          onChanged: (_) {});
                    }
                    WatchHistory.updateDuration(
                        filename.hashCode, durationSnapshot.data!);
                    return StreamBuilder<Duration>(
                        stream: _player.onPositionChanged,
                        builder: (context, positionSnapshot) {
                          if (positionSnapshot.hasData) {
                            WatchHistory.updatePosition(
                                filename.hashCode, positionSnapshot.data!);
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Slider(
                                  value: !positionSnapshot.hasData
                                      ? 0
                                      : positionSnapshot.data!.inSeconds
                                          .toDouble(),
                                  max: durationSnapshot.data!.inSeconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    _player
                                        .seek(Duration(seconds: value.round()));
                                  }),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(positionSnapshot.data.toStringNoMs(),
                                          style: kBodySmall.copyWith(
                                              color: _foregroundColor
                                                  .withOpacity(0.6))),
                                      Text(
                                          durationSnapshot.data!.toStringNoMs(),
                                          style: kBodySmall.copyWith(
                                              color: _foregroundColor
                                                  .withOpacity(0.6))),
                                    ]),
                              ),
                            ],
                          );
                        });
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: _currentIndex == 0
                            ? null
                            : () => updateIndex(offset: -1),
                        icon: const Icon(Icons.skip_previous_outlined),
                        iconSize: 48),
                    StreamBuilder<PlayerState>(
                        stream: _player.onPlayerStateChanged,
                        builder: (context, snapshot) {
                          bool isPlaying = snapshot.data == PlayerState.playing;
                          return PlayPauseButton(
                              play: _player.resume,
                              pause: _player.pause,
                              isPlaying: isPlaying,
                              iconSize: 48);
                        }),
                    IconButton(
                        onPressed: _currentIndex + 1 >= _playlist.length
                            ? null
                            : () => updateIndex(),
                        iconSize: 48,
                        icon: const Icon(Icons.skip_next_outlined)),
                  ],
                ),
              ),
              Visibility(
                visible: _playlist.length > 1,
                child: Center(
                    child: Text('playlist'.tr,
                        style: kTitleLarge.copyWith(color: _foregroundColor))),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _playlistReady,
                builder: (_, ready, ___) => !ready
                    ? const SizedBox()
                    : Expanded(
                        child: ScrollablePositionedList.separated(
                            separatorBuilder: (_, index) =>
                                const Divider(height: 8),
                            itemScrollController: _itemScrollController,
                            initialScrollIndex: _currentIndex,
                            itemCount: _playlist.length,
                            itemBuilder: (context, index) {
                              TextStyle textStyle;
                              if (index == _currentIndex) {
                                textStyle = kTitleMedium.copyWith(
                                    color: _foregroundColor.withRed(64));
                              } else {
                                textStyle = kBodyMedium.copyWith(
                                    color: _foregroundColor);
                              }
                              return TextButton(
                                onPressed: () =>
                                    setState(() => _currentIndex = index),
                                child: Text(basename(_playlist[index]),
                                    style: textStyle),
                              );
                            }),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
