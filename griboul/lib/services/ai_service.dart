import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AIService {
  final Dio _dio = Dio();

  // Use the same backend URL pattern
  String get apiUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  // Generate mini-statement from video
  Future<String?> generateMiniStatement(String videoUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Generating mini-statement for video: $videoUrl');

      final response = await _dio.post(
        '$apiUrl/ai/generate-statement',
        data: {'videoUrl': videoUrl, 'userId': user.uid},
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      print('Mini-statement generated: ${response.data['miniStatement']}');
      return response.data['miniStatement'];
    } catch (e) {
      print('Error generating mini-statement: $e');
      return null;
    }
  }

  // Extract user info from intro video
  Future<Map<String, dynamic>?> extractUserInfo(String videoUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Extracting user info from video: $videoUrl');

      final response = await _dio.post(
        '$apiUrl/ai/extract-user-info',
        data: {
          'videoUrl': videoUrl,
          'userId': user.uid,
          // For now, send mock transcript since video processing isn't implemented
          'transcript':
              'Hi, I\'m ${user.displayName ?? "a builder"}. I\'m 25 years old, from San Francisco, and I\'m building an AI startup to help with climate change.',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      print('Extracted user info: ${response.data['userInfo']}');
      return response.data['userInfo'];
      // Expected format:
      // {
      //   'name': 'John Doe',
      //   'age': 25,
      //   'location': 'San Francisco',
      //   'building': 'AI startup for climate change',
      //   'transcript': 'Full transcript...'
      // }
    } catch (e) {
      print('Error extracting user info: $e');
      // Return mock data for testing
      final currentUser = FirebaseAuth.instance.currentUser;
      return {
        'name': currentUser?.displayName ?? 'Test User',
        'age': 25,
        'location': 'San Francisco',
        'building': 'An amazing startup',
      };
    }
  }

  // Search by description
  Future<List<Map<String, dynamic>>> searchByDescription(String query) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Searching for: $query');

      final response = await _dio.get(
        '$apiUrl/search/descriptive',
        queryParameters: {'q': query},
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      print('Search results: ${response.data['results'].length} found');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } catch (e) {
      print('Error searching: $e');
      return [];
    }
  }
}
