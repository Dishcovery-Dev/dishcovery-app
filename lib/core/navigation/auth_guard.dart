import 'package:dishcovery_app/core/extensions/route_service_extension.dart';
import 'package:dishcovery_app/features/capture/presentation/capture_screen.dart';
import 'package:dishcovery_app/features/history/presentation/history_screen.dart';
import 'package:dishcovery_app/features/home/presentation/dishcovery_home_page.dart';
import 'package:dishcovery_app/features/result/presentation/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/settings/presentation/setting_screen.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login/presentation/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectRoute;

  const AuthGuard({super.key, required this.child, this.redirectRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return child;
        }

        return const LoginScreen();
      },
    );
  }
}

mixin AuthenticationMixin<T extends StatefulWidget> on State<T> {
  bool checkAuthentication({bool redirectToLogin = true}) {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      if (redirectToLogin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pushReplacement(LoginScreen.path);
        });
      }
      return false;
    }

    return true;
  }

  Future<bool> requireAuthentication({
    String title = 'Authentication Required',
    String message = 'Please sign in to continue.',
  }) async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.pop(true);
              context.push(LoginScreen.path);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

class AuthenticatedRoute extends StatelessWidget {
  final Widget child;
  final String? redirectRoute;

  const AuthenticatedRoute({
    super.key,
    required this.child,
    this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(redirectRoute: redirectRoute, child: child);
  }
}

Route<T> createAuthenticatedRoute<T extends Object?>(
  RouteSettings settings,
  Widget Function(BuildContext) builder, {
  String? redirectRoute,
}) {
  return MaterialPageRoute<T>(
    settings: settings,
    builder: (context) => AuthenticatedRoute(
      redirectRoute: redirectRoute,
      child: builder(context),
    ),
  );
}

bool isAuthenticationRequired(String routeName) {
  const authenticatedRoutes = {
    DishcoveryHomePage.path,
    CaptureScreen.path,
    HistoryScreen.path,
    SettingScreen.path,
    ResultScreen.path,
  };

  return authenticatedRoutes.contains(routeName);
}

String getInitialRoute(bool isAuthenticated) {
  return isAuthenticated ? DishcoveryHomePage.path : LoginScreen.path;
}
