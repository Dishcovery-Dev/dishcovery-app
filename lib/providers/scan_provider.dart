import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:dishcovery_app/core/services/firebase_ai_service.dart';
import 'package:dishcovery_app/core/services/firestore_service.dart';
import 'package:dishcovery_app/providers/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'dart:typed_data';

class ScanProvider extends ChangeNotifier {
  final FirebaseAiService _aiService = FirebaseAiService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _loading = false;
  ScanResult? _result;
  String? _error;
  String _loadingMessage = "Memproses gambar...";
  BuildContext? _lastContext;

  bool get loading => _loading;
  ScanResult? get result => _result;
  String? get error => _error;
  String get loadingMessage => _loadingMessage;

  /// Generate loading messages based on language code
  String _getLoadingMessage(String key, String languageCode) {
    if (languageCode == 'id') {
      switch (key) {
        case 'processing':
          return "Memproses gambar...";
        case 'optimizing':
          return "Mengoptimalkan gambar...";
        case 'identifying':
          return "Mengidentifikasi makanan...";
        case 'saving':
          return "Menyimpan hasil...";
        case 'loading_details':
          return "Memuat detail makanan...";
        case 'loading_recipe':
          return "Memuat resep...";
        default:
          return "Memproses...";
      }
    } else {
      switch (key) {
        case 'processing':
          return "Processing image...";
        case 'optimizing':
          return "Optimizing image...";
        case 'identifying':
          return "Identifying food...";
        case 'saving':
          return "Saving results...";
        case 'loading_details':
          return "Loading food details...";
        case 'loading_recipe':
          return "Loading recipe...";
        default:
          return "Processing...";
      }
    }
  }

  // Build prompt based on language code
  String _buildPrompt(String languageCode) {
    if (languageCode == 'id') {
      return """
Identifikasi makanan Indonesia dalam gambar ini.
Jika bukan makanan, set name="bukan makanan" dan isFood=false.
Jika makanan, berikan informasi singkat dan padat:
- Fokus pada informasi penting saja
- Deskripsi maksimal 2 paragraf
- History maksimal 1 paragraf
- Recipe dengan bahan dan langkah utama saja
- Tags maksimal 5
- Related foods maksimal 3
Jawab dalam Bahasa Indonesia.
""";
    } else {
      return """
Identify the Indonesian food in this image.
If it's not food, set name="not food" and isFood=false.
If it's food, provide concise information:
- Focus only on important details
- Description max 2 paragraphs
- History max 1 paragraph
- Recipe with main ingredients and steps only
- Tags max 5
- Related foods max 3
Respond in English.
""";
    }
  }

  /// Optimize image before sending to API
  Future<Uint8List> _optimizeImage(
    String imagePath, [
    String languageCode = 'id',
  ]) async {
    _loadingMessage = _getLoadingMessage('optimizing', languageCode);
    notifyListeners();

    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    // Decode the image
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Resize if image is too large (max 1024px on longest side)
    const maxSize = 1024;
    img.Image resized;

    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        resized = img.copyResize(image, width: maxSize);
      } else {
        resized = img.copyResize(image, height: maxSize);
      }
    } else {
      resized = image;
    }

    // Compress to JPEG with 85% quality
    final optimized = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(optimized);
  }

  Future<void> processImage(String imagePath, {BuildContext? context}) async {
    _loading = true;
    _error = null;

    // Get current language code from context
    String languageCode = 'id'; // default id
    if (context != null) {
      languageCode = context.locale.languageCode;
    }
    print("Language code nya: $languageCode");

    _loadingMessage = _getLoadingMessage('processing', languageCode);
    _lastContext = context;
    notifyListeners();

    try {
      // Optimize image first
      final optimizedBytes = await _optimizeImage(imagePath, languageCode);

      _loadingMessage = _getLoadingMessage('identifying', languageCode);
      notifyListeners();

      // Generate prompt based on language code from context
      final prompt = _buildPrompt(languageCode);

      // Use non-streaming version for stability
      final res = await _aiService.imageToDishcovery(
        imageBytes: optimizedBytes,
        prompt: prompt,
        languageCode: languageCode,
      );

      // Safe parsing with error handling
      final ScanResult parsed;
      try {
        parsed = ScanResult.fromJson(res).copyWith(imagePath: imagePath);
        debugPrint("Parsed result: ${parsed.name}");
        debugPrint("History: ${parsed.history}");
      } catch (parseError) {
        debugPrint("Error parsing result: $parseError");
        throw Exception("Failed to parse API response: $parseError");
      }

      _result = parsed;

      // Save to Firestore and cache locally
      if (parsed.name.toLowerCase() != "bukan makanan" &&
          parsed.name.toLowerCase() != "not food" &&
          parsed.isFood) {
        _loadingMessage = _getLoadingMessage('saving', languageCode);
        notifyListeners();

        try {
          // Save to Firestore (cloud-first)
          final firestoreId = await _firestoreService.saveScanResult(parsed);

          if (firestoreId != null) {
            // Update result with Firestore ID
            final updatedResult = parsed.copyWith(firestoreId: firestoreId);
            _result = updatedResult;

            // Cache locally using HistoryProvider (ObjectBox)
            if (_lastContext != null && _lastContext!.mounted) {
              final historyProvider = Provider.of<HistoryProvider>(
                _lastContext!,
                listen: false,
              );
              await historyProvider.addHistory(updatedResult);
            }
          }
        } catch (e) {
          debugPrint("Error saving scan result: $e");
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error processing image: ${e.toString()}");
      debugPrint("Stack trace: $stackTrace");
      _error = languageCode == 'id'
          ? "Gagal memproses gambar: ${e.toString()}"
          : "Failed to process image: ${e.toString()}";
    }

    _loading = false;
    notifyListeners();
  }

  /// Alternative: Process image with streaming (experimental)
  Future<void> processImageWithStream(
    String imagePath, {
    BuildContext? context,
  }) async {
    _loading = true;
    _error = null;

    // Get current language code from context
    String languageCode = 'id'; // default to Indonesian
    if (context != null) {
      languageCode = context.locale.languageCode;
    }

    _loadingMessage = _getLoadingMessage('processing', languageCode);
    _lastContext = context;
    notifyListeners();

    try {
      // Optimize image first
      final optimizedBytes = await _optimizeImage(imagePath, languageCode);

      _loadingMessage = _getLoadingMessage('identifying', languageCode);
      notifyListeners();

      // Generate prompt based on language
      final prompt = _buildPrompt(languageCode);

      // Use streaming for progressive response
      final stream = _aiService.imageToDishcoveryStream(
        imageBytes: optimizedBytes,
        prompt: prompt,
        languageCode: languageCode,
      );

      bool firstUpdate = true;
      await for (final res in stream) {
        try {
          final parsed = ScanResult.fromJson(
            res,
          ).copyWith(imagePath: imagePath);
          _result = parsed;

          if (firstUpdate) {
            _loading = false; // Stop loading as soon as we get first data
            firstUpdate = false;
          }

          // Update loading message based on what we have
          if (parsed.name.isNotEmpty && parsed.description.isEmpty) {
            _loadingMessage = _getLoadingMessage(
              'loading_details',
              languageCode,
            );
          } else if (parsed.description.isNotEmpty &&
              parsed.recipe.ingredients.isEmpty) {
            _loadingMessage = _getLoadingMessage(
              'loading_recipe',
              languageCode,
            );
          }

          notifyListeners(); // Update UI with partial data
        } catch (e) {
          // Continue if partial JSON can't be parsed yet
          continue;
        }
      }

      // Save to Firestore and cache locally after stream completes
      final result = _result;
      if (result != null &&
          result.name.toLowerCase() != "bukan makanan" &&
          result.name.toLowerCase() != "not food" &&
          result.isFood) {
        _loadingMessage = _getLoadingMessage('saving', languageCode);
        notifyListeners();

        try {
          // Save to Firestore (cloud-first)
          final firestoreId = await _firestoreService.saveScanResult(result);

          if (firestoreId != null) {
            // Update result with Firestore ID
            final updatedResult = result.copyWith(firestoreId: firestoreId);
            _result = updatedResult;

            // Cache locally using HistoryProvider (ObjectBox)
            if (_lastContext != null && _lastContext!.mounted) {
              final historyProvider = Provider.of<HistoryProvider>(
                _lastContext!,
                listen: false,
              );
              await historyProvider.addHistory(updatedResult);
            }
          }
        } catch (e) {
          debugPrint("Error saving scan result: $e");
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error processing image with stream: ${e.toString()}");
      debugPrint("Stack trace: $stackTrace");
      _error = languageCode == 'id'
          ? "Gagal memproses gambar: ${e.toString()}"
          : "Failed to process image: ${e.toString()}";
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _result = null;
    _error = null;
    _loading = false;

    // Defer notification to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setResult(ScanResult result) {
    _result = result;
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
