import 'package:flutter/material.dart';
import 'package:percobaan/screens/library/library_page.dart';
import 'package:percobaan/screens/home/home_page.dart';
import 'package:percobaan/screens/search_page.dart';
import 'package:percobaan/screens/premium_page.dart';
import 'package:percobaan/screens/create_page.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 2;
  final GlobalKey<NavigatorState> libraryNavKey = GlobalKey<NavigatorState>();
  final ScrollController libraryScrollController = ScrollController();

  final List<Widget> _pages = [];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      if (index == 2) {
        libraryScrollController.animateTo(
          0,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
        libraryNavKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(),
      SearchPage(),
      LibraryPage(externalScrollController: libraryScrollController),
      PremiumPage(),
      CreatePage(),
    ]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          SearchPage(),

          Navigator(
            key: libraryNavKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => LibraryPage(
                  externalScrollController: libraryScrollController,
                ),
              );
            },
          ),
          PremiumPage(),
          CreatePage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF191414),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Your Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium),
              label: 'Premium',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          ],
        ),
      ),
    );
  }
}
