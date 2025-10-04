import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../utils/routes/app_routes.dart';

class PreferencesOnboardingScreen extends StatefulWidget {
  const PreferencesOnboardingScreen({super.key});
  static const String path = '/preferences-onboarding';

  @override
  State<PreferencesOnboardingScreen> createState() =>
      _PreferencesOnboardingScreenState();
}

class _PreferencesOnboardingScreenState
    extends State<PreferencesOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Preference data
  final List<String> _likedFlavors = [];
  final List<String> _avoidedFlavors = [];
  final List<String> _allergies = [];
  final List<String> _categories = [];

  // Controllers for custom inputs
  final TextEditingController _customFlavorController = TextEditingController();
  final TextEditingController _customAllergyController =
      TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  // Predefined options
  final List<String> _flavorOptions = const [
    'Pedas',
    'Manis',
    'Asin',
    'Asam',
    'Gurih',
    'Pahit',
  ];
  final List<String> _allergyOptions = const [
    'Kacang',
    'Seafood',
    'Gluten',
    'Susu',
    'Telur',
    'Kedelai',
  ];
  final List<String> _categoryOptions = const [
    'Fastfood',
    'Snack',
    'Dessert',
    'Healthy',
    'Traditional',
    'Street Food',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _customFlavorController.dispose();
    _customAllergyController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipOnboarding() async {
    final provider = context.read<UserPreferencesProvider>();

    try {
      // Save empty preferences to mark onboarding as complete
      final preferences = const UserPreferences(
        likedFlavors: [],
        avoidedFlavors: [],
        allergies: [],
        categories: [],
      );

      await provider.save(preferences);

      if (mounted) {
        // Navigate to main app and clear navigation stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melewati onboarding: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    final provider = context.read<UserPreferencesProvider>();

    try {
      // Request location permission and get current location
      double? latitude, longitude;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.whileInUse ||
            requested == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition();
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final preferences = UserPreferences(
        likedFlavors: _likedFlavors,
        avoidedFlavors: _avoidedFlavors,
        allergies: _allergies,
        categories: _categories,
        latitude: latitude,
        longitude: longitude,
      );

      await provider.save(preferences);

      if (mounted) {
        // Navigate to main app and clear navigation stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan preferensi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Lewati',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLikedFlavorsPage(theme),
                  _buildAvoidedFlavorsPage(theme),
                  _buildAllergiesPage(theme),
                  _buildCategoriesPage(theme),
                ],
              ),
            ),

            // Bottom navigation
            _buildBottomNavigation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedFlavorsPage(ThemeData theme) {
    return _buildPreferencePage(
      theme: theme,
      title: 'Selamat Datang! 👋',
      subtitle: 'Mari mulai dengan rasa favorit Anda',
      description:
          'Pilih rasa yang Anda sukai agar kami bisa memberikan rekomendasi terbaik',
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFE63946),
      options: _flavorOptions,
      selectedOptions: _likedFlavors,
      customController: _customFlavorController,
      showNoPreference: false,
      onToggle: (flavor) {
        setState(() {
          if (_likedFlavors.contains(flavor)) {
            _likedFlavors.remove(flavor);
          } else {
            _likedFlavors.add(flavor);
            _avoidedFlavors.remove(flavor);
          }
        });
      },
      onAddCustom: (custom) {
        if (custom.isNotEmpty && !_likedFlavors.contains(custom)) {
          setState(() {
            _likedFlavors.add(custom);
            _avoidedFlavors.remove(custom);
          });
          _customFlavorController.clear();
        }
      },
    );
  }

  Widget _buildAvoidedFlavorsPage(ThemeData theme) {
    return _buildPreferencePage(
      theme: theme,
      title: 'Rasa yang Dihindari',
      subtitle: 'Beri tahu kami rasa yang tidak Anda sukai',
      description: 'Kami akan menghindari rekomendasi dengan rasa ini',
      icon: Icons.block_rounded,
      iconColor: const Color(0xFFF77F00),
      options: _flavorOptions,
      selectedOptions: _avoidedFlavors,
      customController: _customFlavorController,
      showNoPreference: true,
      onToggle: (flavor) {
        setState(() {
          if (_avoidedFlavors.contains(flavor)) {
            _avoidedFlavors.remove(flavor);
          } else {
            _avoidedFlavors.add(flavor);
            _likedFlavors.remove(flavor);
          }
        });
      },
      onAddCustom: (custom) {
        if (custom.isNotEmpty && !_avoidedFlavors.contains(custom)) {
          setState(() {
            _avoidedFlavors.add(custom);
            _likedFlavors.remove(custom);
          });
          _customFlavorController.clear();
        }
      },
    );
  }

  Widget _buildAllergiesPage(ThemeData theme) {
    return _buildPreferencePage(
      theme: theme,
      title: 'Alergi Makanan',
      subtitle: 'Keamanan Anda adalah prioritas kami',
      description: 'Pilih alergi yang Anda miliki untuk rekomendasi aman',
      icon: Icons.health_and_safety_rounded,
      iconColor: const Color(0xFF06A77D),
      options: _allergyOptions,
      selectedOptions: _allergies,
      customController: _customAllergyController,
      showNoPreference: true,
      isAllergy: true,
      onToggle: (allergy) {
        setState(() {
          if (_allergies.contains(allergy)) {
            _allergies.remove(allergy);
          } else {
            _allergies.add(allergy);
          }
        });
      },
      onAddCustom: (custom) {
        if (custom.isNotEmpty && !_allergies.contains(custom)) {
          setState(() {
            _allergies.add(custom);
          });
          _customAllergyController.clear();
        }
      },
    );
  }

  Widget _buildCategoriesPage(ThemeData theme) {
    return _buildPreferencePage(
      theme: theme,
      title: 'Kategori Favorit',
      subtitle: 'Hampir selesai! 🎉',
      description: 'Pilih jenis makanan yang paling Anda nikmati',
      icon: Icons.restaurant_menu_rounded,
      iconColor: const Color(0xFF7209B7),
      options: _categoryOptions,
      selectedOptions: _categories,
      customController: _customCategoryController,
      showNoPreference: true,
      onToggle: (category) {
        setState(() {
          if (_categories.contains(category)) {
            _categories.remove(category);
          } else {
            _categories.add(category);
          }
        });
      },
      onAddCustom: (custom) {
        if (custom.isNotEmpty && !_categories.contains(custom)) {
          setState(() {
            _categories.add(custom);
          });
          _customCategoryController.clear();
        }
      },
    );
  }

  Widget _buildPreferencePage({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<String> options,
    required List<String> selectedOptions,
    required TextEditingController customController,
    required Function(String) onToggle,
    required Function(String) onAddCustom,
    bool showNoPreference = false,
    bool isAllergy = false,
  }) {
    final colorScheme = theme.colorScheme;

    // Get all options including custom ones
    final allOptions = [...options];
    for (final custom in selectedOptions) {
      if (!allOptions.contains(custom)) {
        allOptions.add(custom);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Badge selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...allOptions.map((option) {
                final isSelected = selectedOptions.contains(option);
                final isCustom = !options.contains(option);

                return _buildBadgeChip(
                  theme: theme,
                  label: option,
                  isSelected: isSelected,
                  isCustom: isCustom,
                  isAllergy: isAllergy,
                  onTap: () => onToggle(option),
                  onDelete: isCustom
                      ? () {
                          setState(() {
                            selectedOptions.remove(option);
                          });
                        }
                      : null,
                );
              }),
              if (showNoPreference)
                _buildNoPreferenceChip(
                  theme: theme,
                  isEmpty: selectedOptions.isEmpty,
                  onTap: () {
                    setState(() {
                      selectedOptions.clear();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom input
          TextField(
            controller: customController,
            decoration: InputDecoration(
              hintText: 'Tambahkan lainnya...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(Icons.add_rounded, color: colorScheme.primary),
                onPressed: () => onAddCustom(customController.text.trim()),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onSubmitted: onAddCustom,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required bool isCustom,
    required VoidCallback onTap,
    VoidCallback? onDelete,
    bool isAllergy = false,
  }) {
    final colorScheme = theme.colorScheme;
    final badgeColor = isAllergy && isSelected
        ? const Color(0xFFFFE5E5)
        : (isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent);
    final borderColor = isAllergy && isSelected
        ? const Color(0xFFE63946)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);
    final textColor = isAllergy && isSelected
        ? const Color(0xFFD32F2F)
        : (isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubicEmphasized,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: badgeColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                if (isCustom && isSelected && onDelete != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isAllergy && isSelected
                          ? const Color(0xFFD32F2F)
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPreferenceChip({
    required ThemeData theme,
    required bool isEmpty,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: isEmpty
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                : Colors.transparent,
            border: Border.all(
              color: isEmpty
                  ? colorScheme.outline
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            'Tidak ada',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: isEmpty ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    final isLastPage = _currentStep == 3;

    return Consumer<UserPreferencesProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  IconButton.filledTonal(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back_rounded),
                    iconSize: 24,
                  )
                else
                  const SizedBox(width: 48),
                if (provider.isLoading)
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  IconButton.filled(
                    onPressed: isLastPage ? _savePreferences : _nextStep,
                    icon: Icon(
                      isLastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    iconSize: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
