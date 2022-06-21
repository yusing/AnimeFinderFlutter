import 'package:anime_finder/pages/downloads_table.dart';
import 'package:anime_finder/pages/file_manager.dart';
import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/pages/settings.dart';
import 'package:anime_finder/pages/watch_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/widgets/af_page.dart';
import 'package:flutter/material.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  static final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  static final _actions = <List<Widget>>[
    HomePage.actions,
    [],
    [],
    WatchHistoryPage.actions,
    SettingsPage.actions,
  ];

  static final _pages = <Widget>[
    const HomePage(),
    const DownloadsTable(),
    FileManager(),
    const WatchHistoryPage(),
    const SettingsPage(),
  ];

  static final ValueNotifier<int> _selectedPage = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectedPage,
      builder: (_, __, ___) => AFPage(
        title: 'AnimeFinder',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: PageView(
              controller: _pageController,
              pageSnapping: false,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => _selectedPage.value = page,
              children: _pages),
        ),
        actions: _actions[_selectedPage.value],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: trHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.download),
              label: trDownloads,
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.folder), label: trFileManager),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: trHistory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: trSettings,
            ),
          ],
          currentIndex: _selectedPage.value,
          onTap: (index) {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          },
        ),
      ),
    );
  }
}
