import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../utils/griboul_theme.dart';
import '../widgets/circular_video_widget.dart';
import '../providers/feed_provider.dart'; // For VideoPost

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Dio _dio = Dio();

  String _searchQuery = '';
  bool _isSearching = false;
  List<VideoPost> _searchResults = [];

  // Recent searches
  List<String> _recentSearches = [
    'founders debugging at night',
    'solo builders in Europe',
    'struggling with fundraising',
    'just launched today',
    'building in public',
  ];

  // Trending topics
  final List<Map<String, String>> _trendingTopics = [
    {'topic': 'FAILED LAUNCHES', 'count': '23 stories'},
    {'topic': 'FIRST CUSTOMER', 'count': '45 stories'},
    {'topic': 'WORKING WEEKENDS', 'count': '128 stories'},
    {'topic': 'BOOTSTRAPPED', 'count': '67 stories'},
    {'topic': 'PIVOT MOMENTS', 'count': '34 stories'},
    {'topic': '3AM DEBUGGING', 'count': '89 stories'},
  ];

  String get apiUrl {
    if (Platform.isIOS) {
      return 'http://192.168.192.76:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus search on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchQuery = query;
      _isSearching = true;
      _searchResults = [];
    });

    HapticFeedback.lightImpact();

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = user != null ? await user.getIdToken() : null;

      // Try API search first
      final response = await _dio
          .get(
            '$apiUrl/search/text',
            queryParameters: {'q': query, 'limit': 20},
            options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : null,
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.data['results'] != null) {
        final results = response.data['results'] as List;

        setState(() {
          _searchResults =
              results.map((result) {
                // Transform search result to VideoPost
                final video = result['video'] ?? {};
                final user = result['user'] ?? {};

                return VideoPost(
                  id: video['_id'] ?? '',
                  userId: user['_id'] ?? '',
                  userName: user['name'] ?? 'Unknown Builder',
                  userAvatar: user['avatar'] ?? '',
                  videoUrl: video['videoUrl'] ?? '',
                  thumbnailUrl: video['thumbnailUrl'] ?? '',
                  miniStatement: result['miniStatement'] ?? '',
                  duration: video['duration'] ?? 0,
                  views: video['views'] ?? 0,
                  createdAt: DateTime.parse(
                    video['createdAt'] ?? DateTime.now().toIso8601String(),
                  ),
                  isLiked: false,
                  likeCount: 0,
                  userLocation: user['location'] ?? 'Unknown',
                  userBuilding: user['building'] ?? 'Something',
                  status: result['entities']?['mood'],
                );
              }).toList();
          _isSearching = false;
        });
      } else {
        _loadMockResults(query);
      }
    } catch (e) {
      print('Search error: $e');
      // Fallback to mock data
      _loadMockResults(query);
    }
  }

  void _loadMockResults(String query) {
    // Mock search results
    setState(() {
      _searchResults = [
        VideoPost(
          id: '1',
          userId: 'user1',
          userName: 'Alex Chen',
          userAvatar: '',
          videoUrl: 'https://example.com/video1.mp4',
          thumbnailUrl: '',
          miniStatement:
              'Debugging payment integration at 3am. Why do we do this to ourselves?',
          duration: 222,
          views: 45,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isLiked: false,
          likeCount: 0,
          userLocation: 'San Francisco',
          userBuilding: 'AI Writing Tools',
          status: 'lateNight',
        ),
        VideoPost(
          id: '2',
          userId: 'user2',
          userName: 'Maria Rodriguez',
          userAvatar: '',
          videoUrl: 'https://example.com/video2.mp4',
          thumbnailUrl: '',
          miniStatement:
              'Finally fixed the memory leak that\'s been haunting me for weeks',
          duration: 138,
          views: 89,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isLiked: false,
          likeCount: 0,
          userLocation: 'Barcelona',
          userBuilding: 'Climate Tech SaaS',
          status: 'debugging',
        ),
      ];
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _searchResults = [];
    });
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GriboulTheme.smoke, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: GriboulTheme.paper,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: GriboulTheme.space2),
                      Text('Search Builders', style: GriboulTheme.headline3),
                    ],
                  ),

                  const SizedBox(height: GriboulTheme.space3),

                  // Search input - NYT style
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: GriboulTheme.charcoal,
                      borderRadius: BorderRadius.circular(
                        GriboulTheme.radiusSmall,
                      ),
                      border: Border.all(
                        color:
                            _searchFocus.hasFocus
                                ? GriboulTheme.paper
                                : GriboulTheme.smoke,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: GriboulTheme.space2),
                        Icon(Icons.search, color: GriboulTheme.ash, size: 20),
                        const SizedBox(width: GriboulTheme.space2),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            style: GriboulTheme.body1.copyWith(
                              fontFamily: 'Georgia',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe what you\'re looking for...',
                              hintStyle: GriboulTheme.body1.copyWith(
                                fontFamily: 'Georgia',
                                color: GriboulTheme.ash,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _performSearch,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              padding: const EdgeInsets.all(
                                GriboulTheme.space1,
                              ),
                              child: Icon(
                                Icons.close,
                                color: GriboulTheme.ash,
                                size: 20,
                              ),
                            ),
                          ),
                        const SizedBox(width: GriboulTheme.space1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  _isSearching
                      ? _buildSearchingState()
                      : _searchQuery.isEmpty
                      ? _buildSuggestions()
                      : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(GriboulTheme.space3),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Text(
            'RECENT SEARCHES',
            style: GriboulTheme.overline.copyWith(
              color: GriboulTheme.ash,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: GriboulTheme.space2),
          ..._recentSearches.map((search) => _buildSearchItem(search)),
          const SizedBox(height: GriboulTheme.space5),
        ],

        // Trending topics
        Text(
          'TRENDING IN THE COMMUNITY',
          style: GriboulTheme.overline.copyWith(
            color: GriboulTheme.ash,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: GriboulTheme.space2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: GriboulTheme.space2,
            mainAxisSpacing: GriboulTheme.space2,
            childAspectRatio: 2.5,
          ),
          itemCount: _trendingTopics.length,
          itemBuilder: (context, index) {
            final topic = _trendingTopics[index];
            return _buildTrendingTopic(topic);
          },
        ),
      ],
    );
  }

  Widget _buildSearchItem(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: GriboulTheme.space2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GriboulTheme.smoke, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: GriboulTheme.ash, size: 20),
            const SizedBox(width: GriboulTheme.space2),
            Expanded(
              child: Text(
                search,
                style: GriboulTheme.body1.copyWith(fontFamily: 'Georgia'),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _recentSearches.remove(search);
                });
              },
              child: Icon(Icons.close, color: GriboulTheme.ash, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTopic(Map<String, String> topic) {
    return GestureDetector(
      onTap: () {
        _searchController.text = topic['topic']!.toLowerCase();
        _performSearch(topic['topic']!.toLowerCase());
      },
      child: Container(
        padding: const EdgeInsets.all(GriboulTheme.space2),
        decoration: BoxDecoration(
          color: GriboulTheme.charcoal,
          borderRadius: BorderRadius.circular(GriboulTheme.radiusSmall),
          border: Border.all(color: GriboulTheme.smoke, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topic['topic']!,
              style: GriboulTheme.overline.copyWith(
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic['count']!,
              style: GriboulTheme.caption.copyWith(color: GriboulTheme.ash),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingState() {
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
            'SEARCHING',
            style: GriboulTheme.overline.copyWith(
              color: GriboulTheme.ash,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: GriboulTheme.space1),
          Text(
            'Finding builders like you...',
            style: GriboulTheme.body2.copyWith(
              fontFamily: 'Georgia',
              color: GriboulTheme.mist,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: GriboulTheme.ash, size: 48),
            const SizedBox(height: GriboulTheme.space3),
            Text(
              'NO RESULTS FOUND',
              style: GriboulTheme.overline.copyWith(
                color: GriboulTheme.ash,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: GriboulTheme.space1),
            Text(
              'Try different keywords',
              style: GriboulTheme.body2.copyWith(
                fontFamily: 'Georgia',
                color: GriboulTheme.mist,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.all(GriboulTheme.space3),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} BUILDERS FOUND',
                style: GriboulTheme.overline.copyWith(
                  color: GriboulTheme.ash,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              Text(
                'RELEVANCE',
                style: GriboulTheme.overline.copyWith(
                  color: GriboulTheme.ash,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        GriboulTheme.divider(),

        // Results list
        Expanded(
          child: ListView.separated(
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => GriboulTheme.divider(),
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return _buildResultCard(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(VideoPost result) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          '/video-player',
          arguments: {
            'id': result.id,
            'videoUrl': result.videoUrl,
            'thumbnailUrl': result.thumbnailUrl,
            'builderName': result.userName,
            'buildingWhat': result.userBuilding,
            'miniStatement': result.miniStatement,
            'timeAgo': result.timeAgo,
            'duration': result.formattedDuration,
            'location': result.userLocation,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(GriboulTheme.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular video preview
            CircularVideoWidget(
              size: 72,
              thumbnailUrl: result.thumbnailUrl,
              duration: result.formattedDuration,
              status: result.videoStatus,
            ),

            const SizedBox(width: GriboulTheme.space2),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and location
                  Row(
                    children: [
                      Text(
                        result.userName,
                        style: GriboulTheme.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        result.timeAgo.toUpperCase(),
                        style: GriboulTheme.overline.copyWith(
                          color: GriboulTheme.ash,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Building and location
                  Text(
                    '${result.userBuilding} • ${result.userLocation}',
                    style: GriboulTheme.caption.copyWith(
                      color: GriboulTheme.ash,
                    ),
                  ),

                  const SizedBox(height: GriboulTheme.space1),

                  // Statement
                  Text(
                    '"${result.miniStatement}"',
                    style: GriboulTheme.body2.copyWith(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
