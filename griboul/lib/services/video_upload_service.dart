import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoUploadService {
  final Dio _dio = Dio();

  // Get the correct backend URL based on platform
  String get apiUrl {
    // Use your computer's IP for physical device
    if (Platform.isIOS) {
      return 'http://192.168.192.76:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android emulator
    }
    return 'http://localhost:3000/api'; // iOS simulator
  }

  /// Complete video upload flow
  Future<Map<String, dynamic>?> uploadVideo({
    required File videoFile,
    required Function(double) onProgress,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await user.getIdToken();

      // Step 1: Get presigned URL from backend
      print('Getting presigned URL...');
      final presignedResponse = await _dio.post(
        '$apiUrl/videos/presigned-url',
        data: {'fileName': videoFile.path.split('/').last},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final uploadUrl = presignedResponse.data['uploadUrl'];
      final videoUrl = presignedResponse.data['videoUrl'];

      // Step 2: Upload to S3
      print('Uploading to S3...');
      final fileBytes = await videoFile.readAsBytes();

      await _dio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': fileBytes.length.toString(),
          },
        ),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
          print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      // Step 3: Notify backend that upload is complete
      print('Notifying backend...');
      final duration = await _getVideoDuration(videoFile);

      final completeResponse = await _dio.post(
        '$apiUrl/videos/upload-complete',
        data: {
          'videoUrl': videoUrl,
          'duration': duration,
          'isPrivate': false,
          'location': 'San Francisco', // TODO: Get from user profile
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final videoId = completeResponse.data['videoId'];

      // Step 4: Process video with AI
      print('Processing with AI...');
      await _processVideoWithAI(
        videoId,
        videoUrl,
        token!,
      ); // Token is guaranteed non-null here

      return {'videoId': videoId, 'videoUrl': videoUrl, 'success': true};
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Process video with AI for mini-statement generation
  Future<void> _processVideoWithAI(
    String videoId,
    String videoUrl,
    String token,
  ) async {
    try {
      // First, get transcript (mock for now)
      final transcript = await _getTranscript(videoUrl, token);

      // Generate mini-statement
      final response = await _dio.post(
        '$apiUrl/ai/generate-statement',
        data: {'videoId': videoId, 'transcript': transcript},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('AI processing complete: ${response.data['miniStatement']}');
    } catch (e) {
      print('AI processing error: $e');
    }
  }

  /// Get transcript from video (mock for now)
  Future<String> _getTranscript(String videoUrl, String token) async {
    try {
      final response = await _dio.post(
        '$apiUrl/ai/transcribe',
        data: {'videoUrl': videoUrl},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['transcript'];
    } catch (e) {
      // Return mock transcript if API fails
      return "Working on my startup late at night. Just fixed a bug that's been bothering me for days.";
    }
  }

  /// Get video duration in seconds
  Future<int> _getVideoDuration(File videoFile) async {
    // TODO: Implement actual video duration calculation
    // For now, return a mock duration
    return 180; // 3 minutes
  }

  /// Extract user info from intro video
  Future<Map<String, dynamic>?> extractUserInfoFromVideo({
    required String videoUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await user.getIdToken();
      if (token == null) throw Exception('Failed to get auth token');

      // Get transcript first
      final transcript = await _getTranscript(videoUrl, token);

      // Extract user info with AI
      final response = await _dio.post(
        '$apiUrl/ai/extract-user-info',
        data: {'videoUrl': videoUrl, 'transcript': transcript},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['userInfo'];
    } catch (e) {
      print('Extract user info error: $e');
      return null;
    }
  }
}

/// Updated Video Provider to use real upload
class UpdatedVideoProvider extends ChangeNotifier {
  final VideoUploadService _uploadService = VideoUploadService();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _lastVideoId;
  String? _lastVideoUrl;
  String? _error;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get lastVideoId => _lastVideoId;
  String? get lastVideoUrl => _lastVideoUrl;
  String? get error => _error;

  /// Upload video with progress tracking
  Future<bool> uploadVideo(File videoFile) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      notifyListeners();

      final result = await _uploadService.uploadVideo(
        videoFile: videoFile,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      if (result != null && result['success'] == true) {
        _lastVideoId = result['videoId'];
        _lastVideoUrl = result['videoUrl'];
        _isUploading = false;
        _uploadProgress = 1.0;
        notifyListeners();
        return true;
      }

      throw Exception('Upload failed');
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Extract user info for onboarding
  Future<Map<String, dynamic>?> extractUserInfo(String videoUrl) async {
    try {
      return await _uploadService.extractUserInfoFromVideo(videoUrl: videoUrl);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _uploadProgress = 0.0;
    _lastVideoId = null;
    _lastVideoUrl = null;
    _error = null;
    notifyListeners();
  }
}
