import 'package:anime_finder/pages/downloads.dart';
import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/pages/search.dart';
import 'package:anime_finder/pages/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:anime_finder/widgets/afpage.dart';
import 'package:get/get.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;

  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  static final _pages = [
    const HomePage(),
    const DownloadsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AFPage(
      title: 'AnimeFinder',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: PageView(controller: _pageController, children: _pages),
      ),
      actions: _selectedIndex != 0
          ? null
          : [
              IconButton(
                icon: Icon(Icons.search, color: kOnBackgroundColor),
                onPressed: () => Get.to(() => const SearchPage()),
              ),
            ],
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
            icon: const Icon(Icons.settings),
            label: trSettings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          await _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}
