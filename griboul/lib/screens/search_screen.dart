import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  List<String> _recentSearches = [
    'founders working on AI at night',
    'solo builders in Europe',
    'struggling with fundraising',
    'just launched today',
    'building in public',
  ];

  final List<String> _trendingSearches = [
    'failed launch stories',
    'first customer celebration',
    'working weekends',
    'bootstrapped founders',
    'pivot moments',
    'debugging at 3am',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    });

    // Navigate to results after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? initialQuery =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (initialQuery != null && _searchController.text.isEmpty) {
      _searchController.text = initialQuery;
      _performSearch(initialQuery);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe what you\'re looking for...',
                              hintStyle: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      )
                                      : null,
                            ),
                            onSubmitted: _performSearch,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              height: 0.5,
              color: AppColors.textPrimary.withOpacity(0.2),
            ),

            // Search content
            Expanded(
              child:
                  _isSearching
                      ? _buildSearchingState()
                      : _searchController.text.isEmpty
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
      padding: const EdgeInsets.all(20),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Text(
            'RECENT',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentSearches.map((search) => _buildSearchItem(search, true)),
          const SizedBox(height: 32),
        ],

        // Trending searches
        Text(
          'TRENDING SEARCHES',
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ..._trendingSearches.map((search) => _buildSearchItem(search, false)),
      ],
    );
  }

  Widget _buildSearchItem(String search, bool isRecent) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textPrimary.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRecent ? Icons.history : Icons.trending_up,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                search,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isRecent)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
                child: Icon(
                  Icons.close,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'SEARCHING',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // Mock results
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '3 BUILDERS FOUND',
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildResultCard(
          'Alex Chen',
          'Building AI tools at night after my 9-5',
          'San Francisco',
          '2 hours ago',
        ),
        _buildResultCard(
          'Maria Rodriguez',
          'Solo founder struggling with user acquisition',
          'Barcelona',
          '5 hours ago',
        ),
        _buildResultCard(
          'James Wilson',
          'Just pivoted after 6 months of no traction',
          'London',
          '1 day ago',
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String name,
    String description,
    String location,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.elevatedBlack,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$location • $time',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_outline,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              color: AppColors.textPrimary.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
