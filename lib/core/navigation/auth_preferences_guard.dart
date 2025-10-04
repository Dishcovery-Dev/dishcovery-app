import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/login/presentation/login_screen.dart';
import '../../features/preference_onboarding/presentation/preferences_onboarding_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_preferences_provider.dart';

class AuthPreferencesGuard extends StatefulWidget {
  final Widget child;

  const AuthPreferencesGuard({super.key, required this.child});

  @override
  State<AuthPreferencesGuard> createState() => _AuthPreferencesGuardState();
}

class _AuthPreferencesGuardState extends State<AuthPreferencesGuard> {
  bool _hasCheckedPreferences = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadPreferences();
    });
  }

  void _checkAndLoadPreferences() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated || _hasCheckedPreferences) {
      return;
    }

    _hasCheckedPreferences = true;

    try {
      final prefsProvider = context.read<UserPreferencesProvider>();
      await prefsProvider.checkOnboardingStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat preferensi: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, UserPreferencesProvider>(
      builder: (context, authProvider, prefsProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        if (prefsProvider.isLoading ||
            prefsProvider.hasCompletedOnboarding == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        if (prefsProvider.hasCompletedOnboarding == false) {
          return const PreferencesOnboardingScreen();
        }

        return widget.child;
      },
    );
  }
}

/// Helper function to create authenticated routes with preferences check
Route<T> createAuthenticatedRouteWithPreferences<T extends Object?>(
  RouteSettings settings,
  Widget Function(BuildContext) builder,
) {
  return MaterialPageRoute<T>(
    settings: settings,
    builder: (context) => AuthPreferencesGuard(child: builder(context)),
  );
}
