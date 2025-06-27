import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  // Feed states
  List<VideoPost> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String _currentFilter = 'for_you'; // for_you, following, trending, new

  // Getters
  List<VideoPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get currentFilter => _currentFilter;

  // API URL
  String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  // Load initial feed
  Future<void> loadFeed() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$apiUrl/videos/feed',
        queryParameters: {'page': _currentPage, 'filter': _currentFilter},
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      _posts =
          (response.data['videos'] as List)
              .map((json) => VideoPost.fromJson(json))
              .toList();
      _hasMore = response.data['hasMore'] ?? false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more posts (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;
      _currentPage++;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$apiUrl/videos/feed',
        queryParameters: {'page': _currentPage, 'filter': _currentFilter},
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      final newPosts =
          (response.data['videos'] as List)
              .map((json) => VideoPost.fromJson(json))
              .toList();

      _posts.addAll(newPosts);
      _hasMore = response.data['hasMore'] ?? false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _currentPage--; // Revert page increment on error
      notifyListeners();
    }
  }

  // Refresh feed
  Future<void> refreshFeed() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      _error = null;
      notifyListeners();

      await loadFeed();

      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Change filter
  Future<void> changeFilter(String filter) async {
    if (_currentFilter == filter) return;

    _currentFilter = filter;
    notifyListeners();
    await loadFeed();
  }

  // Add new post to top of feed (after recording)
  void addNewPost(VideoPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Video Post Model
class VideoPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String videoUrl;
  final String thumbnailUrl;
  final String miniStatement;
  final int duration; // in seconds
  final int views;
  final DateTime createdAt;
  final bool isLiked;
  final int likeCount;

  VideoPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.miniStatement,
    required this.duration,
    required this.views,
    required this.createdAt,
    this.isLiked = false,
    this.likeCount = 0,
  });

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    return VideoPost(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown',
      userAvatar: json['userAvatar'] ?? '',
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      miniStatement: json['miniStatement'] ?? '',
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
