import 'package:camera/camera.dart' as camera;
import 'package:flutter/material.dart';

import '../core/controllers/camera_controller.dart';
import '../core/models/camera_model.dart';

class CameraProvider extends ChangeNotifier {
  late final CameraViewController _controller;

  CameraProvider() {
    _controller = CameraViewController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    notifyListeners();
  }

  CameraViewController get controller => _controller;

  CameraModel get model => _controller.model;

  camera.CameraController? get cameraController => _controller.cameraController;

  bool get isInitialized => _controller.isInitialized;

  bool get hasPermission => model.hasPermission;

  bool get isPermanentlyDenied => model.isPermanentlyDenied;

  bool get isLoading => model.isLoading;

  String? get errorMessage => model.errorMessage;

  String? get imagePath => model.imagePath;

  bool get isFlashOn => model.isFlashOn;

  Future<void> initializeCamera() async {
    await _controller.initializeCamera();
  }

  void toggleFlash() {
    _controller.toggleFlash();
  }

  Future<void> switchCamera() async {
    await _controller.switchCamera();
  }

  Future<String?> takePicture() async {
    return await _controller.takePicture();
  }

  void clearError() {
    _controller.clearError();
  }

  Future<void> setFocusPoint(Offset point) async {
    await _controller.setFocusPoint(point);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
}
