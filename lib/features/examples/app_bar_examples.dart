import 'package:flutter/material.dart';
import '../../core/widgets/custom_app_bar.dart';

class AppBarExamples extends StatelessWidget {
  const AppBarExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Basic usage
      appBar: CustomAppBar(
        title: 'Basic AppBar',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          // Example with back button
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Scaffold(
              appBar: CustomAppBar.withBack(
                context: context,
                title: 'AppBar with Back',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {},
                  ),
                ],
              ),
              body: const Center(
                child: Text('AppBar with Back Button Example'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Transparent example
          Container(
            height: 200,
            color: Colors.blue[100],
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomAppBar.transparent(
                title: 'Transparent AppBar',
                actions: [
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                ],
              ),
              body: const Center(child: Text('Transparent AppBar Example')),
            ),
          ),
          const SizedBox(height: 20),
          // Custom title widget example
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Scaffold(
              appBar: CustomAppBar(
                titleWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Custom Title'),
                        Text(
                          'Subtitle',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              body: const Center(child: Text('Custom Title Widget Example')),
            ),
          ),
        ],
      ),
    );
  }
}
