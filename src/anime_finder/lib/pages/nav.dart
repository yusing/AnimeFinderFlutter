import 'package:anime_finder/pages/downloads.dart';
import 'package:anime_finder/pages/home.dart';
import 'package:anime_finder/pages/search_history.dart';
import 'package:anime_finder/pages/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:anime_finder/widgets/afpage.dart';
import 'package:get/get.dart';

int _selectedPage = 0;

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
        padding: const EdgeInsets.all(16.0),
        child: PageView(controller: _pageController, children: const [
          HomePage(),
          DownloadsPage(),
          SettingsPage(),
        ]),
      ),
      actions: _selectedPage != 0
          ? null
          : [
              IconButton(
                icon: Icon(Icons.search, color: kOnBackgroundColor),
                onPressed: () => Get.to(() => const SearchHistoryPage()),
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
