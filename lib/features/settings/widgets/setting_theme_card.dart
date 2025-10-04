import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class SettingThemeCard extends StatelessWidget {
  const SettingThemeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          if (themeProvider.themeMode == ThemeMode.system) {
                            final isDark = themeProvider.isDarkMode(context);
                            return Text(
                              'Currently: ${isDark ? 'Dark' : 'Light'} (System)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeProvider.setThemeMode(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            children: [
                              Icon(Icons.light_mode, size: 20),
                              const SizedBox(width: 8),
                              const Text('Light'),
                              if (themeProvider.themeMode == ThemeMode.light) ...[
                                const Spacer(),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            children: [
                              Icon(Icons.dark_mode, size: 20),
                              const SizedBox(width: 8),
                              const Text('Dark'),
                              if (themeProvider.themeMode == ThemeMode.dark) ...[
                                const Spacer(),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            children: [
                              Icon(Icons.auto_mode, size: 20),
                              const SizedBox(width: 8),
                              const Text('System'),
                              if (themeProvider.themeMode == ThemeMode.system) ...[
                                const Spacer(),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
