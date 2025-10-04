import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/user_preferences_service.dart';
import 'core/theme/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'utils/routes/app_routes.dart';

class App extends StatelessWidget {
  final SharedPreferences preferences;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  App({super.key, required this.preferences});

  String get _initialRoute {
    // Check if user has seen the onboarding
    final hasSeenOnboarding = preferences.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      return AppRoutes.onboarding;
    }

    // If onboarding is complete, go to main route (which has auth guards)
    return AppRoutes.main;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserPreferencesProvider>(
          create: (context) => UserPreferencesProvider(
            service: UserPreferencesService(),
            auth: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) {
            if (previous != null) {
              previous.auth = auth;
              return previous;
            }
            return UserPreferencesProvider(
              service: UserPreferencesService(),
              auth: auth,
            );
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dishcovery App',
            themeMode: Provider.of<ThemeProvider>(context).themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            initialRoute: _initialRoute,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
