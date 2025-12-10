import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percobaan/screens/library/library_page.dart';
import 'package:percobaan/screens/home/home_page.dart';
import 'package:percobaan/screens/search_page.dart';
import 'package:percobaan/screens/premium_page.dart';
import 'package:percobaan/screens/create_page.dart';

// Import Widget Baru
import 'package:percobaan/widget/mini_player.dart'; 

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 2;
  final GlobalKey<NavigatorState> libraryNavKey = GlobalKey<NavigatorState>();
  final ScrollController libraryScrollController = ScrollController();
  final GlobalKey<LibraryPageState> libraryKey = GlobalKey<LibraryPageState>();

  final List<Widget> _pages = [];

  // --- LOGIC NAVIGASI KAMU (TETAP AMAN) ---
  void _onItemTapped(int index) {
    if (index == 4) {
      setState(() {
        _selectedIndex = 2;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        libraryKey.currentState?.showCreateModalFromOutside();
      });
      return;
    }
    if (_selectedIndex == index) {
      if (index == 2) {
        libraryScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
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
      const HomePage(),
      const SearchPage(),
      LibraryPage(externalScrollController: libraryScrollController),
      const PremiumPage(),
      const CreatePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // --- LOGIC BACK BUTTON KAMU (TETAP AMAN) ---
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final isLibraryTab = _selectedIndex == 2;
        if (isLibraryTab &&
            libraryNavKey.currentState != null &&
            libraryNavKey.currentState!.canPop()) {
              libraryNavKey.currentState!.pop();
              return;
            }

        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }
        const platform = MethodChannel('android/back_button');
        try {
          await platform.invokeMethod('minimizeApp');
        } on PlatformException catch (e) {
          print('Gagal minimize: "${e.message}"');
        }
        return;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomePage(),
            const SearchPage(),
            Navigator(
              key: libraryNavKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => LibraryPage(
                    key: libraryKey,
                    externalScrollController: libraryScrollController,
                  ),
                );
              },
            ),
            const PremiumPage(),
            const CreatePage(),
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
            backgroundColor: const Color(0xFF191414),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Your Library'),
              BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'Premium'),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
            ],
          ),
        ),
        
        // === DI SINI PERUBAHANNYA ===
        // Kodingan panjang tadi diganti jadi 1 baris ini doang.
        // Hasilnya SAMA, tapi lebih rapi.
        bottomSheet: const MiniPlayerWidget(), 
      ),
    );
  }
}