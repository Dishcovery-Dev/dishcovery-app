import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/theme_switcher.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const String path = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mock data for testing
  final List<Map<String, dynamic>> _historyItems = [
    {
      'dish': 'Nasi Padang',
      'date': '2024-01-15',
      'calories': '650 kcal',
      'image': Icons.rice_bowl,
    },
    {
      'dish': 'Rendang',
      'date': '2024-01-14',
      'calories': '420 kcal',
      'image': Icons.restaurant,
    },
    {
      'dish': 'Gado-gado',
      'date': '2024-01-13',
      'calories': '320 kcal',
      'image': Icons.local_dining,
    },
    {
      'dish': 'Sate Ayam',
      'date': '2024-01-12',
      'calories': '380 kcal',
      'image': Icons.kebab_dining,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'History', actions: [ThemeSwitcher()]),
      body: _historyItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start capturing food to see your history',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withAlpha((0.1 * 255).round()),
                      child: Icon(
                        item['image'] as IconData,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      item['dish'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(item['date'] as String),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['calories'] as String,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate ke Detail Screen dari History tsb
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing ${item['dish']}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
