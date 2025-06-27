import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;

  // Maximum recording duration (5 minutes)
  static const Duration maxDuration = Duration(minutes: 5);

  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && micStatus.isGranted;
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use front camera for selfie-style videos
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
      rethrow;
    }
  }

  CameraController? get controller => _controller;
  bool get isRecording => _isRecording;

  Future<String?> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    if (_isRecording) {
      return null;
    }

    try {
      // Get temporary directory for video file
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/griboul_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller!.startVideoRecording();
      _isRecording = true;

      // Auto-stop after max duration
      Future.delayed(maxDuration, () {
        if (_isRecording) {
          stopRecording();
        }
      });

      return filePath;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<XFile?> stopRecording() async {
    if (_controller == null || !_isRecording) {
      return null;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      _isRecording = false;
      return videoFile;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
  }

  // Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentDirection = _controller!.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
    );

    await _controller!.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
  }
}
