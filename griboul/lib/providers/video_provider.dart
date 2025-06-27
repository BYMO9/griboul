import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/video_service.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/video_upload_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService = VideoService();
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();
  final VideoUploadService _uploadService = VideoUploadService();

  // States
  bool _isRecording = false;
  bool _isUploading = false;
  bool _isProcessing = false;
  double _uploadProgress = 0.0;
  String? _currentVideoPath;
  String? _lastUploadedUrl;
  String? _lastMiniStatement;
  String? _error;
  CameraController? _cameraController;

  // Getters
  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;
  bool get isProcessing => _isProcessing;
  double get uploadProgress => _uploadProgress;
  String? get currentVideoPath => _currentVideoPath;
  String? get lastUploadedUrl => _lastUploadedUrl;
  String? get lastMiniStatement => _lastMiniStatement;
  String? get error => _error;
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      await _videoService.initializeCamera();
      _cameraController = _videoService.controller;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize camera: $e';
      notifyListeners();
    }
  }

  // Start recording
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      _error = null;
      final path = await _videoService.startRecording();
      if (path != null) {
        _isRecording = true;
        _currentVideoPath = path;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  // Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      final videoFile = await _videoService.stopRecording();
      _isRecording = false;

      if (videoFile != null) {
        _currentVideoPath = videoFile.path;
        notifyListeners();

        // Automatically start upload process
        await uploadVideo(File(videoFile.path));
      }
    } catch (e) {
      _error = 'Failed to stop recording: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  // Upload video with new integration
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
        _lastUploadedUrl = result['videoUrl'];
        _isUploading = false;
        _uploadProgress = 1.0;
        notifyListeners();
        return true;
      }

      throw Exception('Upload failed');
    } catch (e) {
      _error = 'Failed to upload video: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // Generate mini-statement
  Future<void> generateMiniStatement(String videoUrl) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final miniStatement = await _aiService.generateMiniStatement(videoUrl);
      _lastMiniStatement = miniStatement;
      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate mini-statement: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Extract user info from intro video with real API
  Future<Map<String, dynamic>?> extractUserInfo(String videoUrl) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final userInfo = await _uploadService.extractUserInfoFromVideo(
        videoUrl: videoUrl,
      );

      _isProcessing = false;
      notifyListeners();

      return userInfo;
    } catch (e) {
      _error = 'Failed to extract user info: $e';
      _isProcessing = false;
      notifyListeners();

      // Return mock data as fallback
      return {
        'name': 'Test User',
        'age': 25,
        'location': 'San Francisco',
        'building': 'An amazing startup',
      };
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    try {
      await _videoService.switchCamera();
      _cameraController = _videoService.controller;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to switch camera: $e';
      notifyListeners();
    }
  }

  // Clean up
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset states
  void reset() {
    _currentVideoPath = null;
    _lastUploadedUrl = null;
    _lastMiniStatement = null;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();
  }
}
