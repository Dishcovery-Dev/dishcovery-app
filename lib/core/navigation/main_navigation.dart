import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';

import 'package:dishcovery_app/features/capture/presentation/capture_screen.dart';
import 'package:dishcovery_app/features/history/presentation/history_screen.dart';
import 'package:dishcovery_app/features/home/presentation/dishcovery_home_page.dart';
import 'package:dishcovery_app/features/settings/presentation/setting_screen.dart';

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
    BottomNavigationBarItem(
      icon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:home-angle-linear',
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      activeIcon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:home-smile-angle-bold',
          color: Theme.of(context).primaryColor,
        ),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:history-line-duotone',
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      activeIcon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:clock-circle-bold',
          color: Theme.of(context).primaryColor,
        ),
      ),
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
          child: IconifyIcon(
            icon: 'solar:camera-minimalistic-bold',
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      label: 'Scan',
    ),
    BottomNavigationBarItem(
      icon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:bookmark-outline',
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      activeIcon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:bookmark-bold',
          color: Theme.of(context).primaryColor,
        ),
      ),
      label: 'Saved',
    ),
    BottomNavigationBarItem(
      icon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:settings-minimalistic-linear',
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      activeIcon: Builder(
        builder: (context) => IconifyIcon(
          icon: 'solar:settings-minimalistic-bold',
          color: Theme.of(context).primaryColor,
        ),
      ),
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
