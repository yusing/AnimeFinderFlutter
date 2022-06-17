import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/downloads_table.dart';
import 'package:anime_finder/widgets/file_manager.dart';
import 'package:flutter/material.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  static final actions = <Widget>[];

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final _controller = PageController(
    initialPage: 0,
    keepPage: true,
  );

  static final _tabNames = [
    'Downloads',
    'File Manager',
  ];

  static final _tabs = [const DownloadsTable(), FileManager()];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: _tabNames
              .map((tabName) => Expanded(
                    child: MaterialButton(
                        onPressed: () => _controller.animateToPage(
                            _tabNames.indexOf(tabName),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        child: Text(tabName, style: kBodyMedium)),
                  ))
              .toList(),
        ),
        const Divider(),
        PageView(controller: _controller, children: _tabs),
      ],
    );
  }
}
