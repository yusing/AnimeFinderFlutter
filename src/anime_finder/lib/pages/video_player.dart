import 'dart:math';

import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/service/watch_history.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:anime_finder/widgets/af_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
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
  final _showControlsNotifier = ValueNotifier<bool>(true);
  int? _activeAudioTrack;
  int? _activeSubtitleTrack;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    _vlcController = VlcPlayerController.network(widget.filePath.encodeUrl(),
        autoPlay: false,
        options: VlcPlayerOptions(
            video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true)
        ])));
    _vlcController.addOnInitListener(_onVlcInit);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _showControlsNotifier.dispose();
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
      body: InkWell(
        onTap: () => _showControlsNotifier.value = !_showControlsNotifier.value,
        splashFactory: NoSplash.splashFactory,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: VlcPlayer(
                controller: _vlcController,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _showControlsNotifier,
              builder: (_, __, ___) => Visibility(
                  visible: _showControlsNotifier.value,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      height:
                          min(MediaQuery.of(context).size.height * 0.15, 150),
                      padding: const EdgeInsets.all(8),
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
                  )),
            ),
            ValueListenableBuilder(
              valueListenable: _showControlsNotifier,
              builder: (_, __, ___) => Visibility(
                visible: _showControlsNotifier.value,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    height: min(MediaQuery.of(context).size.height * 0.15, 150),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.forward_5_outlined),
                          onPressed: () async {
                            await _vlcController.seekTo(
                                await _vlcController.getPosition() -
                                    const Duration(seconds: 5));
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: _vlcController,
                          builder: (_, __, ___) =>
                              !_vlcController.value.isInitialized
                                  ? const Icon(Icons.play_arrow_outlined)
                                  : IconButton(
                                      onPressed: () =>
                                          _vlcController.value.isPlaying
                                              ? _vlcController.pause()
                                              : _vlcController.play(),
                                      icon: Icon(_vlcController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_5_outlined),
                          onPressed: () async {
                            await _vlcController.seekTo(
                                await _vlcController.getPosition() +
                                    const Duration(seconds: 5));
                          },
                        ),
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
              ),
            )
          ],
        ),
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
        type: WatchHistoryEntityType.video,
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

extension DurationExt on Duration {
  String toStringNoMs() {
    var microseconds = inMicroseconds;

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    var secondsPadding = seconds < 10 ? "0" : "";

    return "$hours:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }
}
