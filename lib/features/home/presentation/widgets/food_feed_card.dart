import 'dart:io';
import 'package:dishcovery_app/providers/feeds_provider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class FoodFeedCard extends StatefulWidget {
  final FeedData feed;
  final VoidCallback? onTap;
  final Function(String feedId)? onLike;
  final Function(String feedId)? onSave;
  final Function(String feedId)? onComment;

  const FoodFeedCard({
    super.key,
    required this.feed,
    this.onTap,
    this.onLike,
    this.onSave,
    this.onComment,
  });

  @override
  State<FoodFeedCard> createState() => _FoodFeedCardState();
}

class _FoodFeedCardState extends State<FoodFeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike?.call(widget.feed.id);
    if (!widget.feed.isLiked) {
      _heartController.forward().then((_) {
        _heartController.reverse();
      });
    }
  }

  void _handleShare() async {
    final shortDescription = widget.feed.description.length > 100
        ? '${widget.feed.description.substring(0, 100)}...'
        : widget.feed.description;

    final shareText =
        '''
🍽️ ${widget.feed.name}
📍 ${widget.feed.origin}

$shortDescription

Lihat detail selengkapnya di Dishcovery App
https://bit.ly/dishcover-this
''';

    try {
      if (widget.feed.imageUrl.startsWith('http')) {
        await Share.share(shareText);
      } else {
        // For local images
        final file = File(widget.feed.imageUrl);
        if (file.existsSync()) {
          await Share.shareXFiles([
            XFile(widget.feed.imageUrl),
          ], text: shareText);
        } else {
          await Share.share(shareText);
        }
      }
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ingredients = (widget.feed.recipe['ingredients'] as List?) ?? [];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay info
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AspectRatio(aspectRatio: 16 / 9, child: _buildImage()),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(128),
                        ],
                      ),
                    ),
                  ),
                ),
                // User info overlay
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            widget.feed.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.feed.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              timeago.format(widget.feed.createdAt),
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name and origin
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.feed.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.feed.origin,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    widget.feed.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Recipe preview
                  if (ingredients.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Bahan-bahan',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${ingredients.length} items',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ingredients.take(3).join(' • ') +
                                (ingredients.length > 3 ? ' ...' : ''),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Tags
                  if (widget.feed.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.feed.tags.take(5).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${tag.replaceAll('#', '')}',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      // Like button
                      _ActionButton(
                        icon: widget.feed.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.feed.isLiked ? Colors.red : null,
                        label: widget.feed.likesCount.toString(),
                        onTap: _handleLike,
                        animation: _heartAnimation,
                      ),
                      const SizedBox(width: 16),

                      // Comment button
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: widget.feed.commentsCount.toString(),
                        onTap: () => widget.onComment?.call(widget.feed.id),
                      ),
                      const SizedBox(width: 16),

                      // Share button
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: _handleShare,
                      ),
                      const Spacer(),

                      // Save button
                      IconButton(
                        icon: Icon(
                          widget.feed.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: widget.feed.isSaved
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => widget.onSave?.call(widget.feed.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.feed.imageUrl.startsWith('http')) {
      return Image.network(
        widget.feed.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, size: 64),
            ),
          );
        },
      );
    } else {
      final file = File(widget.feed.imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 64),
              ),
            );
          },
        );
      } else {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 64),
          ),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final Animation<double>? animation;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget child = Row(
      children: [
        Icon(icon, size: 20, color: color ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color ?? colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (animation != null) {
      child = AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(scale: animation!.value, child: child);
        },
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ),
    );
  }
}
