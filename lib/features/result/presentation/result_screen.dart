import 'package:dishcovery_app/providers/scan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/related_foods_widget.dart';
import 'widgets/result_actions_widget.dart';
import 'widgets/result_image_widget.dart';
import 'widgets/result_info_widget.dart';
import 'widgets/result_skeleton_loader.dart';
import 'widgets/result_tags_widget.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final bool fromHistory;

  const ResultScreen({
    super.key,
    required this.imagePath,
    this.fromHistory = false,
  });

  static const String path = '/result';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _translated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().processImage(widget.imagePath);
    });
  }

  void _toggleTranslate() {
    setState(() => _translated = !_translated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _translated
              ? "Hasil diterjemahkan ke English 🇬🇧 (coming soon)"
              : "Kembali ke Bahasa Indonesia 🇮🇩",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Result"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _toggleTranslate,
          ),
        ],
      ),
      body: scanProvider.loading
          ? const ResultSkeletonLoader()
          : scanProvider.error != null
          ? Center(child: Text("Error: ${scanProvider.error}"))
          : scanProvider.result == null
          ? const Center(child: Text("No result"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResultImageWidget(imagePath: widget.imagePath),
                  const SizedBox(height: 16),
                  ResultInfoWidget(
                    name: scanProvider.result!.name,
                    origin: scanProvider.result!.origin,
                    description: scanProvider.result!.description,
                    history: scanProvider.result!.history,
                    recipe: scanProvider.result!.recipe,
                  ),
                  const SizedBox(height: 12),
                  if (scanProvider.result!.tags.isNotEmpty)
                    ResultTagsWidget(tags: scanProvider.result!.tags),
                  const SizedBox(height: 12),
                  const ResultActionsWidget(),
                  const SizedBox(height: 20),
                  if (scanProvider.result!.relatedFoods.isNotEmpty)
                    RelatedFoodsWidget(
                      related: scanProvider.result!.relatedFoods,
                    ),
                  if (widget.fromHistory)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Dibuka dari History",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
