import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';

class AFPage extends StatefulWidget {
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
  State<AFPage> createState() => _AFPageState();
}

class _AFPageState extends State<AFPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title, style: kTitleLarge),
          actions: widget.actions),
      body: SafeArea(child: widget.body),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
