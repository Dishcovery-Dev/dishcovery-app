import 'package:flutter/material.dart';

import '../../features/capture/presentation/capture_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/dishcovery_home_page.dart';
import '../../features/settings/presentation/setting_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DishcoveryHomePage(),
    const HistoryScreen(),
    const Placeholder(),
    const SettingScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: 'History',
    ),
    BottomNavigationBarItem(
      icon: Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),
      label: 'Scan',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_outline),
      activeIcon: Icon(Icons.bookmark),
      label: 'Saved',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _getScreenIndex(_currentIndex),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Special handling for Scan button (index 2)
          if (index == 2) {
            // Navigate to camera without changing current index
            Navigator.of(context).pushNamed(CaptureScreen.path);
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  /// Maps bottom nav bar index to screen index
  /// Since Scan button (index 2) doesn't have a corresponding screen,
  /// we need to adjust indices for items after it
  int _getScreenIndex(int navIndex) {
    if (navIndex < 2) {
      return navIndex; // Home (0) and History (1) map directly
    } else if (navIndex == 2) {
      return 0; // Scan button should never be selected, default to Home
    } else {
      return navIndex -
          1; // Saved (3) -> screen index 2, Settings (4) -> screen index 3
    }
  }
}
