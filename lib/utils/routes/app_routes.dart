import 'package:dishcovery_app/features/result/presentation/result_screen.dart';
import 'package:flutter/material.dart';

import '../../core/navigation/auth_guard.dart';
import '../../core/navigation/auth_preferences_guard.dart';
import '../../core/navigation/main_navigation.dart';
import '../../features/auth/forgot_password/presentation/forgot_password_screen.dart';
import '../../features/auth/login/presentation/login_screen.dart';
import '../../features/auth/register/presentation/register_screen.dart';
import '../../features/capture/presentation/capture_screen.dart';
import '../../features/examples/ai_logic_example_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/dishcovery_home_page.dart';
import '../../features/onboarding/presentation/app_onboarding_screen.dart';
import '../../features/preference_onboarding/presentation/preferences_onboarding_screen.dart';
import '../../features/settings/presentation/edit_profile_screen.dart';
import '../../features/settings/presentation/setting_screen.dart';
import '../../features/user_preference/presentation/user_preferences_screen.dart';

/// App routing configuration following Flutter best practices
///
/// This class provides:
/// - Route generation with screen paths
/// - Type-safe navigation using screen static paths
/// - Clean navigation patterns
/// - Authentication guards for protected routes
class AppRoutes {
  /// Onboarding route
  static const String onboarding = '/onboarding';

  /// Main navigation route
  static const String main = '/';
  static const String aiExample = '/ai-example';
  static const String preferences = '/preferences';
  static const String preferencesOnboarding = '/preferences-onboarding';
  static const String editProfile = '/edit-profile';

  /// Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  /// Route generator that maps screen paths to widgets
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding route
      case onboarding:
        return MaterialPageRoute(builder: (_) => const AppOnboardingScreen());

      // Authentication routes (no guard needed)
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Protected routes (require authentication and preferences)
      case main:
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => const MainNavigation(),
        );
      case DishcoveryHomePage.path:
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => const DishcoveryHomePage(),
        );
      case CaptureScreen.path:
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => const CaptureScreen(),
        );
      case HistoryScreen.path:
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => const HistoryScreen(),
        );
      case SettingScreen.path:
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => const SettingScreen(),
        );
      case ResultScreen.path:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final imagePath = args['imagePath'] as String? ?? '';
        return createAuthenticatedRouteWithPreferences(
          settings,
          (_) => ResultScreen(imagePath: imagePath),
        );

      // Protected routes (require only authentication, no preferences needed)
      case preferences:
        return createAuthenticatedRoute(
          settings,
          (_) => const UserPreferencesScreen(),
        );
      case preferencesOnboarding:
        return createAuthenticatedRoute(
          settings,
          (_) => const PreferencesOnboardingScreen(),
        );
      case editProfile:
        return createAuthenticatedRoute(
          settings,
          (_) => const EditProfileScreen(),
        );

      // Public routes (no authentication required)
      case AiLogicExampleScreen.path:
        return MaterialPageRoute(builder: (_) => const AiLogicExampleScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  /// Route configuration for better navigation
  static final Map<String, WidgetBuilder> routes = {
    // Authentication routes
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),

    // Protected routes (wrapped with AuthGuard)
    main: (_) => const AuthGuard(child: MainNavigation()),
    DishcoveryHomePage.path: (_) =>
        const AuthGuard(child: DishcoveryHomePage()),
    CaptureScreen.path: (_) => const AuthGuard(child: CaptureScreen()),
    HistoryScreen.path: (_) => const AuthGuard(child: HistoryScreen()),
    SettingScreen.path: (_) => const AuthGuard(child: SettingScreen()),

    // Public routes
    AiLogicExampleScreen.path: (_) => const AiLogicExampleScreen(),
  };

  /// Helper method to navigate with typed arguments
  static Map<String, dynamic> createArguments({
    String? imagePath,
    Map<String, dynamic>? additionalArgs,
  }) {
    final args = <String, dynamic>{};

    if (imagePath != null) {
      args['imagePath'] = imagePath;
    }

    if (additionalArgs != null) {
      args.addAll(additionalArgs);
    }

    return args;
  }
}
