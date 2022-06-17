import 'package:anime_finder/pages/downloads.dart';
import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/pages/settings.dart';
import 'package:anime_finder/pages/watch_history.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/widgets/af_page.dart';
import 'package:flutter/material.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AFPage(
      title: 'AnimeFinder',
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: PageView(controller: _pageController, children: const [
          HomePage(),
          DownloadsPage(),
          WatchHistoryPage(),
          SettingsPage(),
        ]),
      ),
      actions: [
        HomePage.actions,
        DownloadsPage.actions,
        WatchHistoryPage.actions,
        SettingsPage.actions,
      ][_selectedPage],
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
            icon: const Icon(Icons.history),
            label: trHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: trSettings,
          ),
        ],
        currentIndex: _selectedPage,
        onTap: (index) {
          setState(() {
            _selectedPage = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          });
        },
      ),
    );
  }
}

int _selectedPage = 0;
