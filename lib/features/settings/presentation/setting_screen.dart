import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/settings_menu_item.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_section_header.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static const String path = '/settings';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _selectedLanguage = 'Bahasa Indonesia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            const SettingsProfileHeader(),

            // Account Section
            const SettingsSectionHeader(title: 'Account'),
            SettingsMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Manage your account details',
              onTap: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
            SettingsMenuItem(
              icon: Icons.restaurant_menu,
              title: 'Food Preferences',
              subtitle: 'Set your taste and allergies',
              onTap: () {
                Navigator.pushNamed(context, '/preferences');
              },
            ),

            // Appearance Section
            const SettingsSectionHeader(title: 'Appearance'),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final isDark = themeProvider.themeMode == ThemeMode.dark;
                return SettingsMenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme Mode',
                  subtitle: isDark ? 'Dark' : 'Light',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    themeProvider.setThemeMode(
                      isDark ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                );
              },
            ),
            SettingsMenuItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () {
                _showLanguageDialog();
              },
            ),

            // General Section
            const SettingsSectionHeader(title: 'General'),
            SettingsMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications settings coming soon'),
                  ),
                );
              },
            ),
            SettingsMenuItem(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Privacy and security settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Security settings coming soon'),
                  ),
                );
              },
            ),
            SettingsMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help and support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help center coming soon')),
                );
              },
            ),

            // Sign Out
            const SettingsSectionHeader(title: 'Account Actions'),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SettingsMenuItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out from your account',
                  iconColor: Theme.of(context).colorScheme.error,
                  textColor: Theme.of(context).colorScheme.error,
                  showDivider: false,
                  onTap: authProvider.isLoading
                      ? null
                      : () async {
                          _showSignOutDialog(authProvider);
                        },
                );
              },
            ),

            const SizedBox(height: 32),

            // Version Info
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Dishcovery v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.4 * 255).round()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: RadioGroup<String>(
          groupValue: _selectedLanguage,
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Bahasa Indonesia'),
                value: 'Bahasa Indonesia',
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await authProvider.signOut();

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );

      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
