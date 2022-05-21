import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';

class AFPage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final BottomNavigationBar? bottomNavigationBar;
  const AFPage(
      {Key? key,
      required this.title,
      required this.body,
      this.actions,
      this.bottomNavigationBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: kTitleLarge), actions: actions),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
