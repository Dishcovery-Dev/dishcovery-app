import 'package:dishcovery_app/features/home/presentation/widgets/food_feed_card.dart';
import 'package:dishcovery_app/features/result/presentation/result_screen.dart';
import 'package:dishcovery_app/providers/feeds_provider.dart';
import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:dishcovery_app/core/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DishcoveryHomePage extends StatefulWidget {
  const DishcoveryHomePage({super.key});

  static const String path = '/home';

  @override
  State<DishcoveryHomePage> createState() => _DishcoveryHomePageState();
}

class _DishcoveryHomePageState extends State<DishcoveryHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedsProvider>().loadInitialFeeds();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedsProvider>().loadMoreFeeds();
    }
  }

  void _navigateToDetail(FeedData feed) {
    // Convert FeedData to ScanResult for detail view
    final scanResult = ScanResult(
      firestoreId: feed.id,
      userId: feed.userId,
      userEmail: feed.userEmail,
      userName: feed.userName,
      isFood: true,
      imagePath: feed.imageUrl,
      imageUrl: feed.imageUrl,
      name: feed.name,
      origin: feed.origin,
      description: feed.description,
      history: feed.history,
      recipe: Recipe.fromJson(feed.recipe),
      tags: feed.tags,
      isPublic: true,
      createdAt: feed.createdAt,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(initialData: scanResult),
      ),
    );
  }

  void _showCommentSheet(String feedId) {
    final provider = context.read<FeedsProvider>();
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          provider.addComment(feedId, text);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = textController.text;
                      if (text.trim().isNotEmpty) {
                        provider.addComment(feedId, text);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FeedsProvider>().refreshFeeds();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: true,
              title: Text(
                'Dishcovery',
                style: GoogleFonts.niconne(
                  fontSize: 32,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement search
                  },
                ),
              ],
            ),
            Consumer<FeedsProvider>(
              builder: (context, provider, child) {
                if (provider.feeds.isEmpty && provider.isLoading) {
                  // Initial loading state
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSkeletonCard(),
                      childCount: 3,
                    ),
                  );
                }

                if (provider.feeds.isEmpty && !provider.isLoading) {
                  // Empty state
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.no_meals_outlined,
                            size: 80,
                            color: colorScheme.onSurfaceVariant.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada feeds',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai scan makanan untuk berbagi',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Feed list with infinite scroll
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < provider.feeds.length) {
                        final feed = provider.feeds[index];
                        return FoodFeedCard(
                          feed: feed,
                          onTap: () => _navigateToDetail(feed),
                          onLike: provider.toggleLike,
                          onSave: provider.toggleSave,
                          onComment: _showCommentSheet,
                        );
                      } else if (provider.hasMore) {
                        // Loading more indicator
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      } else {
                        // End of list
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Anda sudah melihat semua feeds',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    childCount:
                        provider.feeds.length +
                        (provider.hasMore || provider.isLoading ? 1 : 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Skeletonizer(
      enabled: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Bone.square(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bone.text(words: 2),
                  const SizedBox(height: 8),
                  const Bone.text(words: 1),
                  const SizedBox(height: 12),
                  const Bone.text(words: 10),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Bone.icon(),
                      const SizedBox(width: 8),
                      const Bone.text(width: 30),
                      const SizedBox(width: 16),
                      const Bone.icon(),
                      const SizedBox(width: 8),
                      const Bone.text(width: 30),
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
}
