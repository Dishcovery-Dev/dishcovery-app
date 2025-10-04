import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/camera_model.dart';

class CameraViewController extends ChangeNotifier {
  CameraController? _cameraController;
  CameraModel _model = const CameraModel();
  List<CameraDescription> _cameras = [];
  bool _isDisposing = false;
  bool _isTakingPicture = false;
  bool _isPreviewPaused = false;

  CameraModel get model => _model;

  CameraController? get cameraController => _cameraController;

  bool get isInitialized => _model.isInitialized;

  Future<void> initializeCamera() async {
    try {
      _updateModel(_model.copyWith(isLoading: true, errorMessage: null));

      // Check current permission status first
      final permissionStatus = await Permission.camera.status;

      if (permissionStatus.isPermanentlyDenied) {
        _updateModel(
          _model.copyWith(
            isLoading: false,
            hasPermission: false,
            isPermanentlyDenied: true,
            // Don't set error message for permanent denial - let permission view handle it
          ),
        );
        return;
      }

      if (permissionStatus.isDenied) {
        // Try to request permission
        final requestResult = await Permission.camera.request();

        if (requestResult.isPermanentlyDenied) {
          _updateModel(
            _model.copyWith(
              isLoading: false,
              hasPermission: false,
              isPermanentlyDenied: true,
              // Don't set error message for permanent denial - let permission view handle it
            ),
          );
          return;
        }

        if (!requestResult.isGranted) {
          _updateModel(
            _model.copyWith(
              isLoading: false,
              hasPermission: false,
              isPermanentlyDenied: false,
              // Don't set error message for regular denial either - let permission view handle it
            ),
          );
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _updateModel(
          _model.copyWith(
            isLoading: false,
            hasPermission: true,
            errorMessage: 'Tidak ada kamera tersedia',
          ),
        );
        return;
      }

      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      await _setupCamera(backCamera);

      _updateModel(
        _model.copyWith(
          isLoading: false,
          hasPermission: true,
          isInitialized: true,
          isPermanentlyDenied: false,
          lensDirection: backCamera.lensDirection,
        ),
      );
    } catch (e) {
      _updateModel(
        _model.copyWith(
          isLoading: false,
          errorMessage: 'Gagal menginisialisasi kamera: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    // Aggressively dispose previous controller
    if (_cameraController != null) {
      try {
        await _cameraController!.pausePreview();
        await Future.delayed(const Duration(milliseconds: 100));
        await _cameraController!.dispose();
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('Error disposing previous camera: $e');
      }
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.low, // Minimal resolution to reduce buffer usage
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();

    // Extended delay for buffer stabilization
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void toggleFlash() {
    if (!_model.isInitialized || _cameraController == null) return;

    try {
      final newFlashState = !_model.isFlashOn;
      _cameraController!.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );

      _updateModel(_model.copyWith(isFlashOn: newFlashState));
    } catch (e) {
      _updateModel(
        _model.copyWith(errorMessage: 'Gagal mengubah flash: ${e.toString()}'),
      );
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || !_model.isInitialized) return;

    try {
      _updateModel(_model.copyWith(isLoading: true));

      final currentDirection = _model.lensDirection;
      final targetDirection = currentDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final targetCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == targetDirection,
        orElse: () => _cameras.first,
      );

      await _setupCamera(targetCamera);

      _updateModel(
        _model.copyWith(
          isLoading: false,
          lensDirection: targetCamera.lensDirection,
          isFlashOn: false,
        ),
      );
    } catch (e) {
      _updateModel(
        _model.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mengganti kamera: ${e.toString()}',
        ),
      );
    }
  }

  Future<String?> takePicture() async {
    if (!_model.isInitialized ||
        _cameraController == null ||
        _isTakingPicture) {
      _updateModel(
        _model.copyWith(
          errorMessage:
              'Kamera belum diinisialisasi atau sedang mengambil foto',
        ),
      );
      return null;
    }

    try {
      _isTakingPicture = true;
      _updateModel(_model.copyWith(isLoading: true, errorMessage: null));

      // More aggressive buffer management
      if (!_isPreviewPaused) {
        await _cameraController!.pausePreview();
        _isPreviewPaused = true;
        // Longer delay to ensure all buffers are released
        await Future.delayed(const Duration(milliseconds: 150));
      }

      final XFile photo = await _cameraController!.takePicture();
      final String savedPath = await _savePhotoToAppDirectory(photo);

      // Force garbage collection to free up buffers
      if (!kReleaseMode) {
        // Only in debug mode to avoid performance impact in release
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Resume preview after longer delay
      if (_isPreviewPaused) {
        await _cameraController!.resumePreview();
        _isPreviewPaused = false;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      _updateModel(_model.copyWith(isLoading: false, imagePath: savedPath));
      return savedPath;
    } catch (e) {
      // Ensure preview is resumed even if error occurs
      try {
        if (_isPreviewPaused) {
          await _cameraController!.resumePreview();
          _isPreviewPaused = false;
        }
      } catch (_) {}

      _updateModel(
        _model.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mengambil foto: ${e.toString()}',
        ),
      );
      return null;
    } finally {
      _isTakingPicture = false;
    }
  }

  Future<String> _savePhotoToAppDirectory(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName =
        'dishcovery_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${directory.path}/$fileName';

    final File savedFile = await File(photo.path).copy(filePath);
    return savedFile.path;
  }

  void clearError() {
    if (_model.errorMessage != null) {
      _updateModel(_model.copyWith(errorMessage: null));
    }
  }

  void _updateModel(CameraModel newModel) {
    _model = newModel;
    notifyListeners();
  }

  // Add method to manually pause/resume preview for lifecycle management
  Future<void> pausePreview() async {
    if (_cameraController != null && !_isPreviewPaused) {
      try {
        await _cameraController!.pausePreview();
        _isPreviewPaused = true;
      } catch (e) {
        debugPrint('Error pausing preview: $e');
      }
    }
  }

  Future<void> resumePreview() async {
    if (_cameraController != null && _isPreviewPaused) {
      try {
        await _cameraController!.resumePreview();
        _isPreviewPaused = false;
      } catch (e) {
        debugPrint('Error resuming preview: $e');
      }
    }
  }

  Future<void> setFocusPoint(Offset point) async {
    if (_cameraController == null || !_model.isInitialized) {
      debugPrint('Camera not initialized, cannot set focus point');
      return;
    }

    try {
      await _cameraController!.setFocusPoint(point);
      await _cameraController!.setExposurePoint(point);
    } catch (e) {
      debugPrint('Error setting focus point: $e');
      _updateModel(
        _model.copyWith(errorMessage: 'Gagal mengatur fokus: ${e.toString()}'),
      );
    }
  }

  @override
  void dispose() {
    if (_isDisposing) return;
    _isDisposing = true;

    // Aggressive cleanup to prevent buffer leaks
    if (_cameraController != null) {
      try {
        if (!_isPreviewPaused) {
          _cameraController!.pausePreview();
        }
        // Extended delay for buffer cleanup
        Future.delayed(const Duration(milliseconds: 150), () {
          _cameraController?.dispose();
        });
      } catch (e) {
        debugPrint('Error during camera disposal: $e');
        _cameraController?.dispose();
      }
    }

    _cameraController = null;
    super.dispose();
  }
}
