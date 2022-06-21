import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlayPauseButton extends IconButton {
  final VoidCallback play;
  final VoidCallback pause;
  final bool isPlaying;

  PlayPauseButton(
      {Key? key,
      double? iconSize,
      Color? color,
      required this.play,
      required this.pause,
      required this.isPlaying})
      : super(
          key: key,
          iconSize: iconSize,
          color: color,
          icon: FaIcon(
              isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play),
          onPressed: isPlaying ? pause : play,
        );
}
