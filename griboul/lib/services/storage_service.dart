import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final Dio _dio = Dio();

  // Use the same backend URL as AuthService
  String get apiUrl {
    // For Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    // For iOS Simulator
    return 'http://localhost:3000/api';
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Starting video upload process...');
      print('File size: ${videoFile.lengthSync()} bytes');

      // Get presigned URL from your backend
      final presignedResponse = await _dio.post(
        '$apiUrl/videos/presigned-url',
        data: {'fileName': path.basename(videoFile.path)},
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      print('Got presigned URL: ${presignedResponse.data}');

      final presignedUrl = presignedResponse.data['uploadUrl'];
      final videoUrl = presignedResponse.data['videoUrl'];

      // Upload directly to S3
      print('Uploading to S3...');

      final fileBytes = await videoFile.readAsBytes();

      await _dio.put(
        presignedUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': fileBytes.length.toString(),
          },
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('Upload progress: $progress%');
        },
      );

      print('Upload complete! Video URL: $videoUrl');

      // Notify backend that upload is complete
      await _dio.post(
        '$apiUrl/videos/upload-complete',
        data: {
          'videoUrl': videoUrl,
          'duration': 180, // TODO: Get actual duration
          'isPrivate': false,
          'location': 'San Francisco', // TODO: Get from user profile
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      return videoUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  // Generate thumbnail from video (for preview)
  Future<File?> generateThumbnail(String videoPath) async {
    // TODO: Implement thumbnail generation
    // For now, return null - we'll use video preview instead
    return null;
  }
}
