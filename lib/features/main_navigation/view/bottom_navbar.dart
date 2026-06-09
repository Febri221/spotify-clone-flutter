import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percobaan/features/player/viewmodel/audio_viewmodel.dart';

import 'package:percobaan/features/home/view/home_page.dart';
import 'package:percobaan/features/premium/view/premium_page.dart';
import 'package:percobaan/features/profile/view/profile_page.dart';

import 'package:percobaan/features/player/widgets/mini_player.dart';
import 'package:percobaan/features/library/view/library_page.dart';
import 'package:percobaan/features/search/widgets/trigger_search.dart';
import 'package:provider/provider.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> libraryNavKey = GlobalKey<NavigatorState>();
  final ScrollController libraryScrollController = ScrollController();
  final GlobalKey<LibraryPageState> libraryKey = GlobalKey<LibraryPageState>();

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    // if (index == 4) {
    //   setState(() => _selectedIndex = 2);
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     libraryKey.currentState?.showCreateModalFromOutside();
    //   });
    //   return;
    // }

    context.read<AudioViewModel>().updateTabIndex(index);

    if (_selectedIndex == index && index == 2) {
      libraryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      libraryNavKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> currentPages = [
      HomePage(),
      const TriggerSearch(),

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
      const ProfilePage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final isLibraryTab = _selectedIndex == 2;
        if (isLibraryTab &&
            libraryNavKey.currentState != null &&
            libraryNavKey.currentState!.canPop()) {
          libraryNavKey.currentState!.pop();
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: currentPages, // Halaman-halaman lo (Home, Library, dll)
            ),

            // Miniplayer ditaruh di sini agar melayang murni di atas page
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight - 55, // Pas di atas bottom bar
              child: const MiniPlayerWidget(),
            ),
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
            backgroundColor: const Color(0xFF1E1E1E),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Your Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium),
                label: 'Premium',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'My Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
