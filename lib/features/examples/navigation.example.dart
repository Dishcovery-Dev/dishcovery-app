import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_models.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/theme_switcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings', actions: [ThemeSwitcher()]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation Service Demo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Tab: ${NavigationContext.currentTab.displayName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Navigation buttons
            Text(
              'Quick Navigation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Go to Home',
              onPressed: () {
                NavigationContext.toHome();
                NavigationContext.showSnackBar('Navigated to Home tab');
              },
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Go to History',
              onPressed: () {
                NavigationContext.toHistory();
                NavigationContext.showSnackBar('Navigated to History tab');
              },
            ),

            const SizedBox(height: 24),

            // Dialog dan bottom sheet examples
            Text(
              'Show Examples',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Show Dialog',
              onPressed: () {
                NavigationContext.showDialog(
                  AlertDialog(
                    title: const Text('Navigation Service'),
                    content: const Text(
                      'This dialog was shown using NavigationContext!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => NavigationContext.pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Show Bottom Sheet',
              onPressed: () {
                NavigationContext.showBottomSheet(
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Navigation Service Bottom Sheet'),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Close',
                          onPressed: () => NavigationContext.pop(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Pop examples
            Text(
              'Pop Examples',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Pop Current',
              onPressed: () {
                NavigationContext.pop();
              },
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Pop to Root',
              onPressed: () {
                NavigationContext.popToRoot();
                NavigationContext.showSnackBar('Popped to root');
              },
            ),
          ],
        ),
      ),
    );
  }
}
