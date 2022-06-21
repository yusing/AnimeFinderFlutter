import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';

class AFPage extends Scaffold {
  final String? title;
  final List<Widget>? actions;
  AFPage({
    super.key,
    super.bottomNavigationBar,
    required Widget body,
    this.title,
    this.actions,
  })  : assert(actions != null && title != null || actions == null),
        super(
          appBar: title == null
              ? null
              : AppBar(
                  title: Text(title,
                      style: kTitleMedium, overflow: TextOverflow.visible),
                  actions: actions,
                  toolbarHeight: 48),
          body: SafeArea(child: body),
        );
}
