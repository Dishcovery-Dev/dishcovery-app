import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotFoodWidget extends StatelessWidget {
  final bool isLoading;

  const NotFoodWidget({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Skeletonizer(
        enabled: isLoading,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.errorContainer.withValues(alpha: 0.8),
              width: 2,
            ),
            color: colorScheme.errorContainer.withValues(alpha: 0.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                "Gambar tidak terdeteksi sebagai makanan 🍽️",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Silakan coba lagi dengan gambar yang lebih jelas atau berbeda.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
