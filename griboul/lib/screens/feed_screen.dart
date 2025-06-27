import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/griboul_theme.dart';
import '../widgets/circular_video_widget.dart';
import '../widgets/video_card.dart';
import '../widgets/daily_prompt_widget.dart';
import '../providers/feed_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  int _playingIndex = -1;
  bool _showDailyPrompt = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);

    // Listen to scroll for auto-play logic
    _scrollController.addListener(_handleScroll);

    // Load initial feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
    });

    // Add pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<FeedProvider>().loadMore();
      }
    });
  }

  void _handleScroll() {
    // Auto-play video in center of viewport
    if (!_scrollController.hasClients) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset = _scrollController.offset;
    final centerPosition = scrollOffset + (screenHeight / 2);

    // Calculate which video is in center
    int centerIndex = -1;
    double minDistance = double.infinity;

    final feedProvider = context.read<FeedProvider>();
    for (int i = 0; i < feedProvider.posts.length; i++) {
      // Approximate card position (header + cards above)
      final cardPosition = 120.0 + (i * 180.0); // Rough estimate
      final distance = (cardPosition - centerPosition).abs();

      if (distance < minDistance) {
        minDistance = distance;
        centerIndex = i;
      }
    }

    if (centerIndex != _playingIndex && mounted) {
      setState(() {
        _playingIndex = centerIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _getDailyPrompt() {
    final prompts = [
      "What's the hardest problem you faced today?",
      "Show us what you're building right now",
      "What small win are you celebrating?",
      "What's keeping you up at night?",
      "Share your workspace and current challenge",
    ];

    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return prompts[dayOfYear % prompts.length];
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();

    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(GriboulTheme.space3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Text(
                        'Griboul',
                        style: GriboulTheme.display.copyWith(
                          fontSize: 40,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: GriboulTheme.space1),

                      // Tagline with date
                      Row(
                        children: [
                          Text(
                            'BUILDERS\' DAILY TRUTH',
                            style: GriboulTheme.overline.copyWith(
                              color: GriboulTheme.ash,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _getCurrentDate(),
                            style: GriboulTheme.mono.copyWith(
                              color: GriboulTheme.ash,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Elegant divider
              SliverToBoxAdapter(
                child: Container(height: 1, color: GriboulTheme.smoke),
              ),

              // Tab bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: GriboulTheme.paper,
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelColor: GriboulTheme.paper,
                    unselectedLabelColor: GriboulTheme.ash,
                    labelStyle: GriboulTheme.button.copyWith(
                      letterSpacing: 1.0,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: GriboulTheme.space3,
                    ),
                    tabs: const [
                      Tab(text: 'WORLD'),
                      Tab(text: 'NEAR'),
                      Tab(text: 'FOLLOWING'),
                      Tab(text: 'TRENDING'),
                    ],
                    onTap: (index) {
                      final filters = [
                        'world',
                        'near',
                        'following',
                        'trending',
                      ];
                      feedProvider.changeFilter(filters[index]);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedContent(feedProvider),
              _buildEmptyState('No builders near you'),
              _buildEmptyState('Follow builders to see their updates'),
              _buildEmptyState('Trending updates will appear here'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedContent(FeedProvider feedProvider) {
    // Show error state if there's an error and no posts
    if (feedProvider.error != null && feedProvider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: GriboulTheme.smoke, width: 2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off, color: GriboulTheme.ash, size: 40),
            ),
            const SizedBox(height: GriboulTheme.space3),
            Text(
              'CONNECTION ERROR',
              style: GriboulTheme.overline.copyWith(
                color: GriboulTheme.ash,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: GriboulTheme.space1),
            Text(
              'Check your internet connection',
              style: GriboulTheme.body2.copyWith(
                fontFamily: 'Georgia',
                color: GriboulTheme.mist,
              ),
            ),
            const SizedBox(height: GriboulTheme.space3),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                feedProvider.loadFeed();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GriboulTheme.space3,
                  vertical: GriboulTheme.space2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: GriboulTheme.smoke, width: 1),
                ),
                child: Text(
                  'RETRY',
                  style: GriboulTheme.button.copyWith(letterSpacing: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show loading state if it's the first load
    if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(GriboulTheme.ash),
              ),
            ),
            const SizedBox(height: GriboulTheme.space3),
            Text(
              'LOADING STORIES',
              style: GriboulTheme.overline.copyWith(
                color: GriboulTheme.ash,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      );
    }

    // Show feed list
    return Column(
      children: [
        // Daily prompt banner
        if (_showDailyPrompt)
          DailyPromptBanner(
            prompt: _getDailyPrompt(),
            onRecord: () {
              Navigator.pushNamed(context, '/record');
            },
            onDismiss: () {
              setState(() {
                _showDailyPrompt = false;
              });
            },
          ),

        // Feed list
        Expanded(
          child: RefreshIndicator(
            color: GriboulTheme.paper,
            backgroundColor: GriboulTheme.charcoal,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await feedProvider.refreshFeed();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount:
                  feedProvider.posts.length +
                  (feedProvider.isLoading ? 1 : 0) +
                  (!feedProvider.hasMore && feedProvider.posts.isNotEmpty
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index == feedProvider.posts.length &&
                    feedProvider.isLoading) {
                  return _buildLoadingIndicator();
                }

                // End of feed message
                if (index == feedProvider.posts.length &&
                    !feedProvider.hasMore) {
                  return Container(
                    padding: const EdgeInsets.all(GriboulTheme.space4),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: GriboulTheme.smoke,
                                width: 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: GriboulTheme.ash,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: GriboulTheme.space2),
                          Text(
                            'YOU\'RE ALL CAUGHT UP',
                            style: GriboulTheme.overline.copyWith(
                              color: GriboulTheme.ash,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final post = feedProvider.posts[index];
                final isPlaying = index == _playingIndex;

                // First video can be featured if it has a prompt
                if (index == 0 && post.prompt != null) {
                  return FeaturedVideoCard(
                    videoUrl: post.videoUrl,
                    thumbnailUrl: post.thumbnailUrl,
                    builderName: post.userName,
                    buildingWhat: post.userBuilding,
                    miniStatement: post.miniStatement,
                    timeAgo: post.timeAgo,
                    duration: post.formattedDuration,
                    location: post.userLocation,
                    prompt: post.prompt,
                    status: post.videoStatus,
                    onTap: () => _navigateToVideo(post),
                  );
                }

                return VideoCard(
                  videoUrl: post.videoUrl,
                  thumbnailUrl: post.thumbnailUrl,
                  builderName: post.userName,
                  buildingWhat: post.userBuilding,
                  miniStatement: post.miniStatement,
                  timeAgo: post.timeAgo,
                  duration: post.formattedDuration,
                  location: post.userLocation,
                  status: post.videoStatus,
                  isPlaying: isPlaying,
                  onTap: () => _navigateToVideo(post),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: GriboulTheme.smoke, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_outlined,
              color: GriboulTheme.ash,
              size: 40,
            ),
          ),
          const SizedBox(height: GriboulTheme.space3),
          Text(
            'NO VIDEOS YET',
            style: GriboulTheme.overline.copyWith(
              color: GriboulTheme.ash,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: GriboulTheme.space1),
          Text(
            message,
            style: GriboulTheme.body2.copyWith(
              fontFamily: 'Georgia',
              color: GriboulTheme.mist,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(GriboulTheme.space4),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(GriboulTheme.ash),
              ),
            ),
            const SizedBox(height: GriboulTheme.space2),
            Text(
              'LOADING MORE STORIES',
              style: GriboulTheme.overline.copyWith(
                color: GriboulTheme.ash,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVideo(VideoPost post) {
    Navigator.pushNamed(
      context,
      '/video-player',
      arguments: {
        'id': post.id,
        'videoUrl': post.videoUrl,
        'thumbnailUrl': post.thumbnailUrl,
        'builderName': post.userName,
        'buildingWhat': post.userBuilding,
        'miniStatement': post.miniStatement,
        'timeAgo': post.timeAgo,
        'duration': post.formattedDuration,
        'location': post.userLocation,
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// Custom delegate for pinned tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: GriboulTheme.ink,
      child: Column(
        children: [tabBar, Container(height: 1, color: GriboulTheme.smoke)],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
