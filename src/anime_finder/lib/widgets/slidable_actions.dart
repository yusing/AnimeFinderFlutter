import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AFSlidableAction extends CustomSlidableAction {
  AFSlidableAction({
    super.key,
    super.onPressed,
    required IconData icon,
    required String label,
    Color? foregroundColor,
    Color? backgroundColor,
  }) : super(
            backgroundColor: backgroundColor ?? kOnBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: foregroundColor ?? kOnBackgroundColor),
                const SizedBox(height: 8),
                Text(label,
                    style: kBodySmall.copyWith(
                        color: foregroundColor ?? kOnBackgroundColor)),
              ],
            ));
}

class DeleteSlidableAction extends CustomSlidableAction {
  DeleteSlidableAction({
    super.key,
    super.onPressed,
  }) : super(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Icon(Icons.delete),
                const SizedBox(height: 8),
                Text(trDelete, style: kBodyMedium),
              ],
            ),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white);
}
