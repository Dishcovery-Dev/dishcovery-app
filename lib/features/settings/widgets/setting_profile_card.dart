import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/user_preferences_provider.dart';

class SettingProfileCard extends StatelessWidget {
  const SettingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, UserPreferencesProvider>(
      builder: (context, authProvider, prefsProvider, child) {
        final user = authProvider.user;
        final prefs = prefsProvider.prefs;

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Section
                  Row(
                    children: [
                      // Profile Picture
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.1 * 255).round(),
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user?.photoURL != null
                              ? Image.network(
                                  user!.photoURL!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Dishcovery User',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'user@example.com',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withAlpha((0.8 * 255).round()),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Edit Button
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-profile');
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha((0.3 * 255).round()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Preferences Summary Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withAlpha((0.5 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Preferensi Makanan',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/preferences');
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreferenceItem(
                          context,
                          Icons.favorite,
                          'Rasa Disukai',
                          prefs.likedFlavors.isEmpty
                              ? 'Belum diatur'
                              : prefs.likedFlavors.take(3).join(', ') +
                                    (prefs.likedFlavors.length > 3
                                        ? ', +${prefs.likedFlavors.length - 3} lagi'
                                        : ''),
                        ),
                        const SizedBox(height: 8),
                        _buildPreferenceItem(
                          context,
                          Icons.category,
                          'Kategori',
                          prefs.categories.isEmpty
                              ? 'Belum diatur'
                              : prefs.categories.take(3).join(', ') +
                                    (prefs.categories.length > 3
                                        ? ', +${prefs.categories.length - 3} lagi'
                                        : ''),
                        ),
                        const SizedBox(height: 8),
                        _buildPreferenceItem(
                          context,
                          Icons.warning_amber,
                          'Alergi',
                          prefs.allergies.isEmpty
                              ? 'Tidak ada'
                              : prefs.allergies.take(3).join(', ') +
                                    (prefs.allergies.length > 3
                                        ? ', +${prefs.allergies.length - 3} lagi'
                                        : ''),
                        ),
                        const SizedBox(height: 8),
                        _buildPreferenceItem(
                          context,
                          Icons.location_on,
                          'Lokasi',
                          prefs.latitude != null && prefs.longitude != null
                              ? '${prefs.latitude!.toStringAsFixed(2)}, ${prefs.longitude!.toStringAsFixed(2)}'
                              : 'Belum diatur',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
