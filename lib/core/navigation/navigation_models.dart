import 'package:flutter/material.dart';
import 'navigation_service.dart';

enum NavigationTab {
  home,
  history,
  settings;

  int get tabIndex {
    switch (this) {
      case NavigationTab.home:
        return 0;
      case NavigationTab.history:
        return 1;
      case NavigationTab.settings:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case NavigationTab.home:
        return 'Home';
      case NavigationTab.history:
        return 'History';
      case NavigationTab.settings:
        return 'Settings';
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final NavigationTab tab;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.title,
    required this.tab,
    required this.screen,
  });
}

class NavigationContext {
  static NavigationService get nav => NavigationService();

  static void toHome() => nav.goToHome();
  static void toHistory() => nav.goToHistory();
  static void toSettings() => nav.navigateToTab(NavigationTab.settings);

  static void pop() => nav.pop();
  static void popToRoot() => nav.popToRoot();

  static NavigationTab get currentTab => nav.currentTab;
  static BuildContext? get context => nav.context;

  static void showSnackBar(String message, {Color? backgroundColor}) {
    nav.showSnackBar(message, backgroundColor: backgroundColor);
  }

  static Future<T?> showDialog<T>(Widget dialog, {bool dismissible = true}) {
    return nav.showAppDialog<T>(
      dialog: dialog,
      barrierDismissible: dismissible,
    );
  }

  static Future<T?> showBottomSheet<T>(Widget bottomSheet) {
    return nav.showAppBottomSheet<T>(bottomSheet: bottomSheet);
  }
}
