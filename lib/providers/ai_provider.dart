import 'package:flutter/foundation.dart';

import '../core/services/firebase_ai_service.dart';

class AiProvider extends ChangeNotifier {
  AiProvider({FirebaseAiService? service})
    : _service = service ?? FirebaseAiService();

  final FirebaseAiService _service;

  bool _loading = false;
  String? _error;
  String? _textResult;
  Map<String, dynamic>? _jsonResult;

  bool get isLoading => _loading;
  String? get error => _error;
  String? get textResult => _textResult;
  Map<String, dynamic>? get jsonResult => _jsonResult;

  void _start() {
    _loading = true;
    _error = null;
    _textResult = null;
    _jsonResult = null;
    notifyListeners();
  }

  void _finish() {
    _loading = false;
    notifyListeners();
  }

  Future<void> generateTextFromImage({
    required Uint8List imageBytes,
    String prompt = '',
  }) async {
    _start();
    try {
      final text = await _service.imageToText(
        imageBytes: imageBytes,
        prompt: prompt,
      );
      _textResult = text;
    } catch (e) {
      _error = e.toString();
    } finally {
      _finish();
    }
  }

  Future<void> generateStructuredFromImage({
    required Uint8List imageBytes,
    String prompt = '',
  }) async {
    _start();
    try {
      final obj = await _service.imageToStructured(
        imageBytes: imageBytes,
        prompt: prompt,
      );
      _jsonResult = obj;
    } catch (e) {
      _error = e.toString();
    } finally {
      _finish();
    }
  }

  Future<void> generateStructuredFromText({required String prompt}) async {
    _start();
    try {
      final obj = await _service.textToStructured(prompt: prompt);
      _jsonResult = obj;
    } catch (e) {
      _error = e.toString();
    } finally {
      _finish();
    }
  }
}
