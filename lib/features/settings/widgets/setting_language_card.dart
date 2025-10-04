import 'package:flutter/material.dart';
import '../../../core/navigation/navigation_models.dart';

class SettingLanguageCard extends StatefulWidget {
  const SettingLanguageCard({super.key});

  @override
  State<SettingLanguageCard> createState() => _SettingLanguageCardState();
}

class _SettingLanguageCardState extends State<SettingLanguageCard> {
  String selectedLanguage = 'ID';

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
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  // TODO: Implement ganti bahasa
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedLanguage = newValue;
                      });
                      NavigationContext.showSnackBar(
                        'Language changed to $newValue (Not implemented yet)',
                      );
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'ID',
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.red,
                            ),
                            child: const Center(
                              child: Text(
                                '🇮🇩',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Bahasa Indonesia'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'EN',
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.blue,
                            ),
                            child: const Center(
                              child: Text(
                                '🇺🇸',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
