import 'dart:math';

import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/duration.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:anime_finder/widgets/af_dropdown.dart';
import 'package:anime_finder/widgets/play_pause_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage(
      {super.key, required this.filePath, required this.title});

  final String filePath;
  final String title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VlcPlayerController _vlcController;
  // final _showControlsNotifier = ValueNotifier<bool>(true);
  int? _activeAudioTrack;
  int? _activeSubtitleTrack;
  double _playbackSpeed = 1.0;
  late OverlayEntry _overlay;

  @override
  void initState() {
    _overlay = OverlayEntry(
      opaque: false,
      builder: (context) => GestureDetector(
        onTap: () {
          debugPrint('Tapped from overlay');
          _overlay.remove();
        },
        child: Card(
          color: Colors.black.withOpacity(0.3),
          shadowColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.all(0),
          child: SizedBox.fromSize(
              size: MediaQuery.of(context).size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height:
                          min(MediaQuery.of(context).size.height * 0.15, 150),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                              onPressed: () => Get.back(closeOverlays: true),
                              icon: const Icon(Icons.arrow_back_ios_new)),
                          Expanded(
                              child: Text(widget.title, style: kTitleSmall)),
                          IconButton(
                            icon: const Icon(Icons.more_vert_outlined),
                            onPressed: () => _showOptions(),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height:
                          min(MediaQuery.of(context).size.height * 0.15, 150),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _vlcController,
                            builder: (_, __, ___) => Text(
                                '${_vlcController.value.position.toStringNoMs()} / '
                                '${_vlcController.value.duration.toStringNoMs()}'),
                          ),
                          Expanded(
                              child: ValueListenableBuilder(
                            valueListenable: _vlcController,
                            builder: (_, __, ___) => Slider(
                              value: _vlcController.value.position.inSeconds
                                  .toDouble(),
                              onChanged: (v) => _vlcController
                                  .seekTo(Duration(seconds: v.toInt())),
                              // onChangeStart: (v) async =>
                              //     await _vlcController.pause(),
                              onChangeEnd: (v) => _vlcController.play(),
                              min: 0.0,
                              max: max(
                                  1.0, // maybe uninitialized
                                  _vlcController.value.duration.inSeconds
                                      .toDouble()), // _durationSecs.value may load after _positionSecs.value
                              activeColor: Colors.white,
                              inactiveColor: Colors.white.withOpacity(0.5),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Center(
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.backward),
                          iconSize: 32,
                          onPressed: () async {
                            await _vlcController.seekTo(
                                await _vlcController.getPosition() -
                                    const Duration(seconds: 5));
                          },
                        ),
                      )),
                      Expanded(
                        child: Center(
                          child: ValueListenableBuilder(
                            valueListenable: _vlcController,
                            builder: (_, __, ___) => PlayPauseButton(
                                iconSize: 32,
                                color: Colors.white.withOpacity(0.8),
                                play: _vlcController.play,
                                pause: _vlcController.pause,
                                isPlaying: _vlcController.value.isPlaying),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Center(
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.forward),
                          iconSize: 32,
                          onPressed: () async {
                            await _vlcController.seekTo(
                                await _vlcController.getPosition() +
                                    const Duration(seconds: 5));
                          },
                        ),
                      )),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
    _vlcController = VlcPlayerController.network(widget.filePath.encodeUrl(),
        autoPlay: false,
        options: VlcPlayerOptions(
            video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true)
        ])));
    _vlcController.addOnInitListener(_onVlcInit);
    _vlcController.addOnInitListener(() {
      Overlay.of(context)?.insert(_overlay);
    });
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _overlay.remove();
    // _showControlsNotifier.dispose();
    if (_vlcController.value.isInitialized) {
      await _vlcController.stopRendererScanning();
      await _vlcController.dispose();
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GestureDetector(
        onTap: () {
          debugPrint('Tapped from player');
          if (!_overlay.mounted) {
            Overlay.of(context)?.insert(_overlay);
          } else {
            _overlay.remove();
          }
          // _showControlsNotifier.value = true;
        },
        child: Center(
            child: VlcPlayer(
                controller: _vlcController,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()))),
      ),
    );
  }

  void _onVlcInit() async {
    final lastWatched = WatchHistory.getPosition(widget.title.hashCode);
    final videoId = widget.title.hashCode;

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await _vlcController.play();

    while (_vlcController.value.duration == Duration.zero) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    WatchHistory.add(WatchHistoryEntry(
        id: videoId,
        title: widget.title,
        path: widget.filePath,
        type: WatchHistoryEntryType.video,
        duration: _vlcController.value.duration.inSeconds));

    if (lastWatched != Duration.zero) {
      await _vlcController.seekTo(lastWatched);
    }

    _vlcController.addListener(() async {
      if (_vlcController.value.isEnded) {
        await _vlcController.stop();
        Get.back();
      }
      await WatchHistory.updatePosition(videoId, _vlcController.value.position);
    });
  }

  void _showOptions() {
    if (_overlay.mounted) {
      _overlay.remove();
    }
    showModalBottomSheet(
        context: context,
        backgroundColor: kBackgroundColor,
        useRootNavigator: true,
        builder: (_) {
          return ListView(
            children: [
              ListTile(
                  leading: const Icon(Icons.speed_outlined),
                  title: Text(trPlaybackSpeed, style: kBodyMedium),
                  trailing: AFDropdown<double>(
                      itemsMap: Map.fromIterable(
                          List.generate(8, (i) => (i + 1) * 0.25,
                              growable: false),
                          value: (v) => '${v.toStringAsFixed(2)}x'),
                      valueGetter: () => _playbackSpeed,
                      onChanged: (speed) async {
                        _playbackSpeed = speed!;
                        await _vlcController.setPlaybackSpeed(_playbackSpeed);
                      })),
              ListTile(
                  leading: const Icon(Icons.audiotrack_outlined),
                  title: Text(trAudioTrack, style: kBodyMedium),
                  trailing: FutureBuilder<Map<int, String>>(
                      future: _vlcController.getAudioTracks(),
                      builder: (_, snapshot) => snapshot.data == null
                          ? const SizedBox()
                          : AFDropdown<int>(
                              valueGetter: () =>
                                  _activeAudioTrack ??
                                  _vlcController.value.activeAudioTrack,
                              itemsMap: snapshot.data!,
                              onChanged: (value) async {
                                _activeAudioTrack = value!;
                                await _vlcController.setAudioTrack(value);
                              },
                            ))),
              ListTile(
                  leading: const Icon(Icons.subtitles_outlined),
                  title: Text(trSubtitle, style: kBodyMedium),
                  trailing: FutureBuilder<Map<int, String>>(
                      future: _vlcController.getSpuTracks(),
                      builder: (_, snapshot) => snapshot.data == null
                          ? const SizedBox()
                          : AFDropdown<int>(
                              valueGetter: () =>
                                  _activeSubtitleTrack ??
                                  _vlcController.value.activeSpuTrack,
                              itemsMap: snapshot.data!,
                              onChanged: (value) async {
                                _activeSubtitleTrack = value!;
                                await _vlcController.setSpuTrack(value);
                              },
                            )))
            ],
          );
        });
  }
}
