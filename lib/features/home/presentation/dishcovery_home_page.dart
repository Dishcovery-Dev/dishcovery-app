import 'package:dishcovery_app/core/models/feed_model.dart';
import 'package:dishcovery_app/features/home/presentation/widgets/feed_card.dart';
import 'package:flutter/material.dart';

class DishcoveryHomePage extends StatefulWidget {
  const DishcoveryHomePage({super.key});

  static const String path = '/home';

  @override
  State<DishcoveryHomePage> createState() => _DishcoveryHomePageState();
}

class _DishcoveryHomePageState extends State<DishcoveryHomePage> {
  late List<FeedItem> _feedItems;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeedData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFeedData() {
    setState(() {
      _feedItems = FakeFeedData.generateFakeFeedItems();
    });
  }

  void _handleLike(FeedItem item) {
    // Handle like action
    debugPrint('Liked: ${item.username}\'s post');
  }

  void _handleComment(FeedItem item) {
    // Handle comment action
    debugPrint('Comment on: ${item.username}\'s post');
    // TODO: Navigate to comments page
  }

  void _handleShare(FeedItem item) {
    // Handle share action
    debugPrint('Share: ${item.username}\'s post');
    // TODO: Implement share functionality
  }

  void _handleSave(FeedItem item) {
    // Handle save action
    debugPrint('Saved: ${item.username}\'s post');
  }

  void _handleMoreOptions(FeedItem item) {
    // Show more options bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement copy link
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share to...'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement report
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Turn off notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement notification settings
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Dishcovery',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Navigate to likes/activity page
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // TODO: Navigate to messages
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _loadFeedData();
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _feedItems.length,
          itemBuilder: (context, index) {
            final item = _feedItems[index];
            return FeedCard(
              feedItem: item,
              onLike: () => _handleLike(item),
              onComment: () => _handleComment(item),
              onShare: () => _handleShare(item),
              onSave: () => _handleSave(item),
              onMoreOptions: () => _handleMoreOptions(item),
            );
          },
        ),
      ),
    );
  }
}
