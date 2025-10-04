import 'package:dishcovery_app/core/models/feed_model.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedCard extends StatefulWidget {
  final FeedItem feedItem;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMoreOptions;

  const FeedCard({
    super.key,
    required this.feedItem,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onMoreOptions,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.feedItem.isLiked;
    _isSaved = widget.feedItem.isSaved;
    _likes = widget.feedItem.likes;

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likes++;
        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse();
        });
      } else {
        _likes--;
      }
    });
    widget.onLike?.call();
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.feedItem.userAvatarUrl),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Username and Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feedItem.username,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.feedItem.location.isNotEmpty)
                      Text(
                        widget.feedItem.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // More Options Button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: widget.onMoreOptions,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),

        // Image Section
        GestureDetector(
          onDoubleTap: () {
            if (!_isLiked) {
              _handleLike();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Image.network(
                    widget.feedItem.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Rating Badge (if available)
              if (widget.feedItem.rating != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.feedItem.rating!.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Action Buttons Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            children: [
              // Like Button
              IconButton(
                icon: AnimatedBuilder(
                  animation: _heartAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartAnimation.value,
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : colorScheme.onSurface,
                      ),
                    );
                  },
                ),
                onPressed: _handleLike,
              ),
              // Comment Button
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: widget.onComment,
                color: colorScheme.onSurface,
              ),
              // Share Button
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: widget.onShare,
                color: colorScheme.onSurface,
              ),
              const Spacer(),
              // Save Button
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: colorScheme.onSurface,
                ),
                onPressed: _handleSave,
              ),
            ],
          ),
        ),

        // Likes and Caption Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Likes Count
              if (_likes > 0)
                Text(
                  _likes == 1 ? '1 like' : '$_likes likes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),

              // Caption
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: widget.feedItem.username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: widget.feedItem.caption),
                  ],
                ),
              ),

              // Tags
              if (widget.feedItem.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: widget.feedItem.tags.map((tag) {
                    return Text(
                      tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Comments Count
              if (widget.feedItem.comments > 0) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.onComment,
                  child: Text(
                    'View all ${widget.feedItem.comments} comments',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],

              // Ingredients (Food specific)
              if (widget.feedItem.ingredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.feedItem.ingredients.take(3).join(', ') +
                            (widget.feedItem.ingredients.length > 3 ? '...' : ''),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Timestamp
              const SizedBox(height: 8),
              Text(
                timeago.format(widget.feedItem.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Divider between posts
        Divider(
          height: 1,
          thickness: 0.5,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}