import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:ui';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../providers/video_provider.dart';
import '../widgets/whatsapp_record_button.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isPrivate = false;
  late AnimationController _promptController;
  late Animation<double> _promptAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _promptController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _promptAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _promptController, curve: Curves.easeOut),
    );

    _promptController.forward();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.initializeCamera();
  }

  Future<void> _handleVideoComplete(String videoPath) async {
    setState(() => _isProcessing = true);

    try {
      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Show success and go back
        HapticFeedback.heavyImpact();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Posted successfully',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _getDailyPrompt() {
    final prompts = [
      "What's the hardest problem you faced today?",
      "Show us what you're building right now",
      "What small win are you celebrating?",
      "What's keeping you up at night?",
      "Share your workspace and current challenge",
    ];

    final now = DateTime.now();
    final index = now.day % prompts.length;
    return prompts[index];
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    if (_isProcessing) {
      return _buildProcessingScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Camera preview full screen
          if (videoProvider.isInitialized)
            Positioned.fill(
              child: CameraPreview(videoProvider.cameraController!),
            )
          else
            Container(
              color: AppColors.surfaceBlack,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.textSecondary,
                  strokeWidth: 2,
                ),
              ),
            ),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryBlack.withOpacity(0.8),
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.primaryBlack.withOpacity(0.9),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                      if (videoProvider.isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.recordRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'RECORDING',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 11,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: () async => await videoProvider.switchCamera(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flip_camera_ios,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Daily prompt
                FadeTransition(
                  opacity: _promptAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_promptAnimation),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TODAY\'S PROMPT',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getDailyPrompt(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Privacy toggle
                GestureDetector(
                  onTap: () {
                    setState(() => _isPrivate = !_isPrivate);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isPrivate
                              ? AppColors.accentBlue.withOpacity(0.2)
                              : AppColors.primaryBlack.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _isPrivate
                                ? AppColors.accentBlue
                                : AppColors.textPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPrivate ? Icons.lock : Icons.public,
                          color:
                              _isPrivate
                                  ? AppColors.accentBlue
                                  : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPrivate ? 'PRIVATE VIDEO' : 'PUBLIC VIDEO',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color:
                                _isPrivate
                                    ? AppColors.accentBlue
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Recording controls
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        'HOLD TO RECORD • 5 MIN MAX',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      WhatsAppRecordButton(
                        onRecordStart: () async {
                          await videoProvider.startRecording();
                        },
                        onRecordEnd: () async {
                          await videoProvider.stopRecording();
                          if (videoProvider.currentVideoPath != null) {
                            _handleVideoComplete(
                              videoProvider.currentVideoPath!,
                            );
                          }
                        },
                        isRecording: videoProvider.isRecording,
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSecondary, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'POSTING',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sharing your moment...',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
