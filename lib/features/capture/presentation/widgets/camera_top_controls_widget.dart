import 'package:flutter/material.dart';

import '../../../../providers/camera_provider.dart';

class CameraTopControlsWidget extends StatelessWidget {
  final CameraProvider provider;
  final VoidCallback onBackPressed;

  const CameraTopControlsWidget({
    super.key,
    required this.provider,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: onBackPressed,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // Flash Toggle
          IconButton(
            onPressed: provider.toggleFlash,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                provider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: provider.isFlashOn ? Colors.yellow : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
