import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/circular_video_widget.dart';
import 'dart:io';

class FeedProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  // Feed states
  List<VideoPost> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String _currentFilter = 'for_you'; // Keep original filter name

  // Getters
  List<VideoPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get currentFilter => _currentFilter;

  // API URL
  String get apiUrl {
    if (Platform.isIOS) {
      return 'http://192.168.192.76:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  /// Load initial feed
  Future<void> loadFeed() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      final token = user != null ? await user.getIdToken() : null;

      final response = await _dio.get(
        '$apiUrl/videos/feed',
        queryParameters: {
          'page': _currentPage,
          'filter': _currentFilter,
          'limit': 20,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
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
      print('Load feed error: $e');
      _error = e.toString();
      _isLoading = false;

      // Load mock data as fallback
      _loadMockData();
      notifyListeners();
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;
      _currentPage++;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      final token = user != null ? await user.getIdToken() : null;

      final response = await _dio.get(
        '$apiUrl/videos/feed',
        queryParameters: {
          'page': _currentPage,
          'filter': _currentFilter,
          'limit': 20,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
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

  /// Refresh feed
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

  /// Change filter
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

  /// Load mock data as fallback
  void _loadMockData() {
    _posts = [
      VideoPost(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Chen',
        userAvatar: '',
        videoUrl: 'https://example.com/video1.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1557804506-669a67965ba0',
        miniStatement:
            'Third day debugging this API. Finally seeing the light at the end of the tunnel.',
        duration: 222, // 3:42
        views: 128,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isLiked: false,
        likeCount: 0,
        userLocation: 'San Francisco',
        userBuilding: 'AI Climate Dashboard',
        status: 'debugging',
      ),
      VideoPost(
        id: '2',
        userId: 'user2',
        userName: 'Marcus Rodriguez',
        userAvatar: '',
        videoUrl: 'https://example.com/video2.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1553877522-43269d4ea984',
        miniStatement:
            'Just lost our biggest client. Time to rethink everything.',
        duration: 138, // 2:18
        views: 89,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isLiked: false,
        likeCount: 0,
        userLocation: 'Berlin',
        userBuilding: 'B2B SaaS Platform',
        status: 'struggling',
      ),
    ];
  }
}

// Video Post Model - Updated to include all fields
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

  // Additional fields for our UI
  final String userLocation;
  final String userBuilding;
  final String? status;
  final String? prompt;

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
    required this.userLocation,
    required this.userBuilding,
    this.status,
    this.prompt,
  });

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    // Handle nested user data
    final user = json['userId'] ?? json['user'] ?? {};

    return VideoPost(
      id: json['_id'] ?? json['id'],
      userId: user['_id'] ?? user['uid'] ?? json['userId'] ?? 'unknown',
      userName: user['name'] ?? json['userName'] ?? 'Unknown Builder',
      userAvatar: user['avatar'] ?? json['userAvatar'] ?? '',
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      miniStatement: json['miniStatement'] ?? '',
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      userLocation: user['location'] ?? json['location'] ?? 'Earth',
      userBuilding: user['building'] ?? json['building'] ?? 'Something amazing',
      status: json['mood'] ?? json['status'],
      prompt: json['prompt'],
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

  CircularVideoStatus? get videoStatus {
    switch (status) {
      case 'lateNight':
        return CircularVideoStatus.lateNight;
      case 'debugging':
        return CircularVideoStatus.debugging;
      case 'celebrating':
        return CircularVideoStatus.celebrating;
      case 'struggling':
        return CircularVideoStatus.struggling;
      case 'building':
        return CircularVideoStatus.building;
      default:
        return null;
    }
  }
}
