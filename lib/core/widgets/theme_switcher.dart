import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;

  const ThemeSwitcher({
    super.key,
    this.iconSize = 24.0,
    this.padding,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.select<ThemeProvider, ThemeMode>(
      (provider) => provider.themeMode,
    );

    // Determine if current theme is dark (including system mode)
    final isDark =
        themeProvider == ThemeMode.dark ||
        (themeProvider == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        size: iconSize,
        color: iconColor ?? theme.appBarTheme.iconTheme?.color,
      ),
      onPressed: () => _toggleTheme(context),
      padding: padding ?? const EdgeInsets.all(8.0),
    );
  }

  void _toggleTheme(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.themeMode;
    final theme = Theme.of(context);

    // Toggle between light and dark only
    if (currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system &&
            theme.brightness == Brightness.dark)) {
      themeProvider.setThemeMode(ThemeMode.light);
    } else {
      themeProvider.setThemeMode(ThemeMode.dark);
    }
  }
}
