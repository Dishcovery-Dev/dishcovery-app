import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});
  static const String path = '/preferences';

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  // User selections
  List<String> _likedFlavors = [];
  List<String> _avoidedFlavors = [];
  List<String> _allergies = [];
  List<String> _categories = [];

  // Custom inputs
  final TextEditingController _customFlavorController = TextEditingController();
  final TextEditingController _customAllergyController =
      TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final provider = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    await provider.load();
    final p = provider.prefs;
    setState(() {
      _likedFlavors = List<String>.from(p.likedFlavors);
      _avoidedFlavors = List<String>.from(p.avoidedFlavors);
      _categories = List<String>.from(p.categories);
      _allergies = List<String>.from(p.allergies);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customFlavorController.dispose();
    _customAllergyController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    final provider = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final prefs = UserPreferences(
      likedFlavors: _likedFlavors,
      avoidedFlavors: _avoidedFlavors,
      allergies: _allergies,
      categories: _categories,
      latitude: provider.prefs.latitude,
      longitude: provider.prefs.longitude,
    );

    await provider.save(prefs);
    if (!mounted) return;

    if (provider.error == null) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Preferensi berhasil disimpan'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${provider.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
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
        title: Text(
          'Edit Preferensi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
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
    );
  }

  Widget _buildLikedFlavorsPage(ThemeData theme) {
    return _buildPreferencePage(
      theme: theme,
      title: 'Rasa Favorit Anda',
      subtitle: 'Pilih rasa yang Anda sukai',
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFE63946),
      options: _flavorOptions,
      selectedOptions: _likedFlavors,
      customController: _customFlavorController,
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
      subtitle: 'Pilih rasa yang ingin Anda hindari',
      icon: Icons.block_rounded,
      iconColor: const Color(0xFFF77F00),
      options: _flavorOptions,
      selectedOptions: _avoidedFlavors,
      customController: _customFlavorController,
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
      subtitle: 'Beri tahu kami tentang alergi Anda',
      icon: Icons.health_and_safety_rounded,
      iconColor: const Color(0xFF06A77D),
      options: _allergyOptions,
      selectedOptions: _allergies,
      customController: _customAllergyController,
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
      title: 'Kategori Makanan',
      subtitle: 'Pilih jenis makanan yang Anda sukai',
      icon: Icons.restaurant_menu_rounded,
      iconColor: const Color(0xFF7209B7),
      options: _categoryOptions,
      selectedOptions: _categories,
      customController: _customCategoryController,
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
    required IconData icon,
    required Color iconColor,
    required List<String> options,
    required List<String> selectedOptions,
    required TextEditingController customController,
    required Function(String) onToggle,
    required Function(String) onAddCustom,
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
          // Badge/Chip selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: allOptions.map((option) {
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
            }).toList(),
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

  Widget _buildBottomNavigation(ThemeData theme) {
    final isLastPage = _currentPage == 3;

    return Consumer<UserPreferencesProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  IconButton.filledTonal(
                    onPressed: _previousPage,
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
                    onPressed: isLastPage ? _savePreferences : _nextPage,
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
