import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../providers/feed_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  // Mock data for testing
  final List<Map<String, dynamic>> mockVideos = [
    {
      'id': '1',
      'userName': 'Sarah Chen',
      'location': 'San Francisco',
      'headline': 'Building an AI-Powered Climate Dashboard at 2AM',
      'description':
          'After three failed deployment attempts, finally got the real-time data pipeline working. The key was switching from WebSockets to Server-Sent Events.',
      'duration': '3:42',
      'timeAgo': '2 HOURS AGO',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800',
    },
    {
      'id': '2',
      'userName': 'Marcus Rodriguez',
      'location': 'Berlin',
      'headline': 'Why Our B2B SaaS Almost Failed This Week',
      'description':
          'Lost our biggest client. Spent the day talking to customers and realized we\'ve been building the wrong features for 6 months.',
      'duration': '5:00',
      'timeAgo': '5 HOURS AGO',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=800',
    },
    {
      'id': '3',
      'userName': 'Amara Okafor',
      'location': 'Lagos',
      'headline': 'First Customer Payment Just Hit Our Account',
      'description':
          'After 8 months of building in stealth, we finally have revenue. Starting with 500 MRR but it feels like a million.',
      'duration': '2:18',
      'timeAgo': '12 HOURS AGO',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Column(
        children: [
          // Custom App Bar
          Container(
            color: AppColors.primaryBlack,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Logo and page indicator
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Griboul logo
                        Text(
                          'Griboul',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        // Page indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _currentPage == 0 ? 'WORLD' : 'NEAR',
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: AppColors.textPrimary.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [_buildVideoFeed('world'), _buildVideoFeed('near')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeed(String feedType) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: mockVideos.length,
      itemBuilder: (context, index) {
        final video = mockVideos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to video player
      },
      child: Container(
        color: AppColors.primaryBlack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail with overlay
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail
                  Container(
                    color: AppColors.surfaceBlack,
                    child: CachedNetworkImage(
                      imageUrl: video['thumbnailUrl'],
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Container(color: AppColors.surfaceBlack),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppColors.surfaceBlack,
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: AppColors.textTertiary,
                              size: 48,
                            ),
                          ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.primaryBlack.withOpacity(0.7),
                          AppColors.primaryBlack.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.textPrimary,
                        size: 36,
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video['duration'],
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline
                  Text(
                    video['headline'],
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    video['description'],
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Metadata
                  Row(
                    children: [
                      Text(
                        video['userName'].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        video['location'].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        video['timeAgo'],
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: AppColors.textPrimary.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
