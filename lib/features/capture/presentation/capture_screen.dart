import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/routes/app_routes.dart';
import '../../result/presentation/result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  static const String path = '/capture';

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermission = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera({int retryCount = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check camera permission
      final permissionStatus = await Permission.camera.status;

      if (permissionStatus.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _isPermanentlyDenied = true;
          _isLoading = false;
          _errorMessage = 'Akses kamera telah diblokir.\nSilakan aktifkan izin kamera di pengaturan aplikasi untuk melanjutkan.';
        });
        return;
      }

      if (permissionStatus.isDenied) {
        final result = await Permission.camera.request();

        if (result.isPermanentlyDenied) {
          setState(() {
            _hasPermission = false;
            _isPermanentlyDenied = true;
            _isLoading = false;
            _errorMessage = 'Akses kamera telah diblokir.\nSilakan aktifkan izin kamera di pengaturan aplikasi untuk melanjutkan.';
          });
          return;
        }

        if (!result.isGranted) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
            _errorMessage = 'Dishcovery memerlukan akses kamera untuk memindai makanan Anda.\nSilakan berikan izin untuk melanjutkan.';
          });
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Kamera tidak tersedia di perangkat ini.\nPastikan kamera berfungsi dengan baik.';
        });
        return;
      }

      // Initialize camera controller with back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      await _setupCameraController(backCamera);

      setState(() {
        _hasPermission = true;
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      // Retry logic for camera in use or closing state
      if (retryCount < 2 && (e.toString().contains('CameraException') ||
          e.toString().contains('in use') ||
          e.toString().contains('closing'))) {
        // Wait a bit for camera to be released
        await Future.delayed(Duration(milliseconds: 300 + (retryCount * 200)));
        if (mounted) {
          return _initializeCamera(retryCount: retryCount + 1);
        }
        return;
      }

      String friendlyMessage;

      // Handle specific platform exceptions
      if (e.toString().contains('PermissionHandler.PermissionManager')) {
        if (e.toString().contains('already running')) {
          friendlyMessage = 'Sedang memproses izin kamera.\nMohon tunggu sebentar dan coba lagi.';
        } else {
          friendlyMessage = 'Terjadi masalah dengan izin kamera.\nSilakan coba lagi dalam beberapa saat.';
        }
      } else if (e.toString().contains('CameraException')) {
        friendlyMessage = 'Kamera sedang digunakan aplikasi lain.\nTutup aplikasi kamera lain dan coba lagi.';
      } else {
        friendlyMessage = 'Terjadi masalah saat mengakses kamera.\nPastikan kamera berfungsi dengan baik dan coba lagi.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = friendlyMessage;
      });
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    // Dispose existing controller if any
    await _cameraController?.dispose();

    // Create new controller
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      throw Exception('Gagal menginisialisasi controller: $e');
    }
  }

  Future<void> _disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnackBar('Kamera belum siap, mohon tunggu sebentar');
      return;
    }

    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final XFile photo = await _cameraController!.takePicture();

      if (!mounted) return;

      // Navigate to result screen
      Navigator.of(context).pushReplacementNamed(
        ResultScreen.path,
        arguments: AppRoutes.createArguments(imagePath: photo.path),
      );
    } catch (e) {
      String friendlyMessage;
      if (e.toString().contains('CameraException')) {
        friendlyMessage = 'Gagal mengambil foto. Pastikan kamera berfungsi dengan baik dan coba lagi.';
      } else {
        friendlyMessage = 'Terjadi masalah saat mengambil foto. Silakan coba lagi.';
      }
      _showSnackBar(friendlyMessage);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isLoading || !_isInitialized) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Always reset loading state and ensure camera is properly reinitialized if needed
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Reinitialize camera if it was disposed during picker lifecycle
        if (!_isInitialized) {
          await _initializeCamera();
        }
      }

      // If user canceled selection, just return without doing anything
      if (image == null) {
        return;
      }

      if (!mounted) return;

      // Navigate to result screen with selected image
      Navigator.of(context).pushReplacementNamed(
        ResultScreen.path,
        arguments: AppRoutes.createArguments(imagePath: image.path),
      );
    } catch (e) {
      // Ensure loading state is reset and camera is reinitialized if needed
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Reinitialize camera if it was disposed during picker lifecycle
        if (!_isInitialized) {
          await _initializeCamera();
        }
      }

      String friendlyMessage;
      if (e.toString().contains('photo_access_denied')) {
        friendlyMessage = 'Akses galeri ditolak. Silakan berikan izin akses galeri di pengaturan aplikasi.';
      } else if (e.toString().contains('photo_access_restricted')) {
        friendlyMessage = 'Akses galeri dibatasi. Periksa pengaturan privasi perangkat Anda.';
      } else {
        friendlyMessage = 'Terjadi masalah saat memilih gambar dari galeri. Silakan coba lagi.';
      }
      _showSnackBar(friendlyMessage);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isInitialized) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      _showSnackBar('Flash tidak dapat digunakan pada perangkat ini');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewSize = _cameraController!.value.previewSize!;
    final previewRatio = previewSize.height / previewSize.width;

    return OverflowBox(
      maxHeight: deviceRatio < previewRatio
          ? size.height
          : size.width / previewRatio,
      maxWidth: deviceRatio < previewRatio
          ? size.height * previewRatio
          : size.width,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildGamificationOverlay() {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(painter: _FoodFramePainter()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized) _buildCameraPreview(),

          // Gamification Overlay (frame guide)
          if (_isInitialized) _buildGamificationOverlay(),

          // Loading State
          if (_isLoading && !_isInitialized)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),

          // Error State
          if (_errorMessage != null && !_isInitialized)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPermanentlyDenied
                          ? Icons.camera_alt_outlined
                          : Icons.error_outline,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (_isPermanentlyDenied)
                      FilledButton.icon(
                        onPressed: () async {
                          await openAppSettings();
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Buka Pengaturan'),
                      )
                    else if (!_hasPermission)
                      FilledButton.icon(
                        onPressed: _initializeCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Berikan Izin Kamera'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _initializeCamera,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                  ],
                ),
              ),
            ),

          // Top gradient overlay
          if (_isInitialized)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).padding.top + 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Bottom gradient overlay
          if (_isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).padding.bottom + 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Top Controls (Back button) - ABOVE gradients
          if (_isInitialized)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  _ControlButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

          // Bottom instruction and tips
          if (_isInitialized)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 140,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Tips container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pastikan pencahayaan cukup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Controls (Capture Button and Gallery Button) - ABOVE gradients
          if (_isInitialized)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: _isLoading ? null : _pickImageFromGallery,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Capture Button (Main)
                  GestureDetector(
                    onTap: _isLoading ? null : _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: theme.primaryColor,
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                  
                  // Flash Toggle Button
                  GestureDetector(
                    onTap: _isLoading ? null : _toggleFlash,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isFlashOn 
                            ? theme.primaryColor.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFlashOn ? theme.primaryColor : Colors.white, 
                          width: 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.white : Colors.black87,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Custom button widget for controls
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// Custom painter for food frame guide
class _FoodFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dottedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Calculate frame dimensions (circular frame in center)
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    // Draw circular dashed frame
    const dashWidth = 10.0;
    const dashSpace = 8.0;
    double startAngle = 0;

    while (startAngle < 360) {
      final endAngle = startAngle + dashWidth;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        _degreesToRadians(startAngle),
        _degreesToRadians(dashWidth),
        false,
        dottedPaint,
      );
      startAngle = endAngle + dashSpace;
    }

    // Draw corner brackets
    final bracketLength = 30.0;
    final bracketOffset = 15.0;

    // Top-left corner
    canvas.drawLine(
      Offset(centerX - radius - bracketOffset, centerY - radius),
      Offset(
        centerX - radius - bracketOffset + bracketLength,
        centerY - radius,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - radius - bracketOffset, centerY - radius),
      Offset(
        centerX - radius - bracketOffset,
        centerY - radius + bracketLength,
      ),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(centerX + radius + bracketOffset, centerY - radius),
      Offset(
        centerX + radius + bracketOffset - bracketLength,
        centerY - radius,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + radius + bracketOffset, centerY - radius),
      Offset(
        centerX + radius + bracketOffset,
        centerY - radius + bracketLength,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(centerX - radius - bracketOffset, centerY + radius),
      Offset(
        centerX - radius - bracketOffset + bracketLength,
        centerY + radius,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - radius - bracketOffset, centerY + radius),
      Offset(
        centerX - radius - bracketOffset,
        centerY + radius - bracketLength,
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(centerX + radius + bracketOffset, centerY + radius),
      Offset(
        centerX + radius + bracketOffset - bracketLength,
        centerY + radius,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + radius + bracketOffset, centerY + radius),
      Offset(
        centerX + radius + bracketOffset,
        centerY + radius - bracketLength,
      ),
      paint,
    );
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
