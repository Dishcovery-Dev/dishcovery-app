import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _themeMode;
  Timer? _saveTimer;

  ThemeProvider(this._prefs) : _themeMode = _loadThemeMode(_prefs);

  ThemeMode get themeMode => _themeMode;

  /// Returns true if the app is currently displaying in dark mode
  /// This considers both the explicit mode setting and system preference
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // When in system mode, check the actual platform brightness
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final String? themeModeString = prefs.getString(_themeKey);
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;

    // Update theme immediately for instant UI response
    _themeMode = mode;
    notifyListeners();

    // Debounce SharedPreferences save to reduce I/O operations
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 100), () {
      _saveThemeToPrefs(mode);
    });
  }

  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await _prefs.setString(_themeKey, themeModeString);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
