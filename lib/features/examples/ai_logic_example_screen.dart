import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/ai_provider.dart';

class AiLogicExampleScreen extends StatefulWidget {
  const AiLogicExampleScreen({super.key});

  static const String path = '/ai-example';

  @override
  State<AiLogicExampleScreen> createState() => _AiLogicExampleScreenState();
}

class _AiLogicExampleScreenState extends State<AiLogicExampleScreen> {
  final _promptController = TextEditingController(
    text: 'Jelaskan isi gambar secara ringkas.',
  );
  final _textPromptController = TextEditingController(
    text:
        'Buat struktur JSON ringkas untuk 3 poin penting tentang masakan rendang.',
  );
  Uint8List? _imageBytes;
  String? _imagePreviewInfo;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imagePreviewInfo = '${file.name} • ${bytes.lengthInBytes ~/ 1024} KB';
    });
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imagePreviewInfo = '${file.name} • ${bytes.lengthInBytes ~/ 1024} KB';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiProvider(),
      child: Consumer<AiProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Firebase AI Logic — Examples')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.isLoading ? null : _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Pilih Gambar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.isLoading ? null : _captureImage,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Ambil Foto'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _imageBytes!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_imagePreviewInfo != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _imagePreviewInfo!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      labelText: 'Prompt untuk gambar',
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: provider.isLoading || _imageBytes == null
                              ? null
                              : () => provider.generateTextFromImage(
                                  imageBytes: _imageBytes!,
                                  prompt: _promptController.text,
                                ),
                          child: const Text('Gambar → Teks'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: provider.isLoading || _imageBytes == null
                              ? null
                              : () => provider.generateStructuredFromImage(
                                  imageBytes: _imageBytes!,
                                  prompt: _promptController.text,
                                ),
                          child: const Text('Gambar → JSON'),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),
                  TextField(
                    controller: _textPromptController,
                    decoration: const InputDecoration(
                      labelText: 'Prompt teks → JSON',
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.generateStructuredFromText(
                              prompt: _textPromptController.text,
                            ),
                      child: const Text('Teks → JSON'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (provider.isLoading) const LinearProgressIndicator(),
                  if (provider.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (provider.textResult != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hasil Teks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    SelectableText(provider.textResult!),
                  ],
                  if (provider.jsonResult != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hasil JSON',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(provider.jsonResult),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
