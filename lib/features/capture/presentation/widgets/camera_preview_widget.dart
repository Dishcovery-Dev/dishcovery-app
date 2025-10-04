import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../providers/camera_provider.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraProvider provider;
  final Function(TapDownDetails details, CameraProvider provider) onTapToFocus;

  const CameraPreviewWidget({
    super.key,
    required this.provider,
    required this.onTapToFocus,
  });

  @override
  Widget build(BuildContext context) {
    final cameraController = provider.cameraController!;

    return Positioned.fill(
      child: GestureDetector(
        onTapDown: (details) => onTapToFocus(details, provider),
        child: Container(
          color: Colors.black,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: cameraController.value.previewSize?.height ?? 1,
              height: cameraController.value.previewSize?.width ?? 1,
              child: CameraPreview(cameraController),
            ),
          ),
        ),
      ),
    );
  }
}
