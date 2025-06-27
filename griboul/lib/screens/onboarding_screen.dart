import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:griboul/widgets/whatsapp_record_button.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:ui';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../constants/strings.dart';
import '../providers/auth_provider.dart';
import '../providers/video_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  bool _showRecording = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _extractedInfo;

  // Animation controllers
  late AnimationController _buttonAnimationController;
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayFadeAnimation;
  late Animation<double> _videoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _overlayFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _videoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.initializeCamera();
  }

  void _startRecording() {
    setState(() {
      _showRecording = true;
    });
    _overlayAnimationController.forward();
  }

  void _cancelRecording() {
    _overlayAnimationController.reverse().then((_) {
      setState(() {
        _showRecording = false;
      });
    });
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    if (videoProvider.isRecording) {
      videoProvider.stopRecording();
    }
  }

  Future<void> _handleVideoComplete(String videoPath) async {
    setState(() {
      _showRecording = false;
      _isProcessing = true;
    });

    try {
      // TEMPORARY: Skip actual upload and AI processing since backend doesn't exist
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock extracted info
      final mockUserInfo = {
        'name': 'Test User',
        'age': '25',
        'location': 'San Francisco',
        'building': 'AI startup for climate change',
      };

      if (mounted) {
        setState(() {
          _extractedInfo = mockUserInfo;
          _isProcessing = false;
        });

        // Show confirmation dialog
        _showConfirmationDialog(mockUserInfo, 'mock-video-url');
      }

      /* ORIGINAL CODE - uncomment when backend is ready
      final videoProvider = Provider.of<VideoProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Upload video
      final videoFile = File(videoPath);
      final success = await videoProvider.uploadVideo(videoFile);

      if (success && videoProvider.lastUploadedUrl != null) {
        // Extract user info with AI
        final userInfo = await videoProvider.extractUserInfo(
          videoProvider.lastUploadedUrl!,
        );

        if (userInfo != null && mounted) {
          setState(() {
            _extractedInfo = userInfo;
            _isProcessing = false;
          });
          
          // Show confirmation dialog
          _showConfirmationDialog(userInfo, videoProvider.lastUploadedUrl!);
        }
      }
      */
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> userInfo, String videoUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: AppColors.primaryBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Profile',
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: AppFonts.headline3,
                      fontWeight: AppFonts.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _buildInfoRow('NAME', userInfo['name'] ?? 'Unknown'),
                  _buildInfoRow(
                    'AGE',
                    userInfo['age']?.toString() ?? 'Unknown',
                  ),
                  _buildInfoRow('LOCATION', userInfo['location'] ?? 'Unknown'),
                  _buildInfoRow('BUILDING', userInfo['building'] ?? 'Unknown'),
                  const SizedBox(height: AppSizes.xl),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _extractedInfo = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.md,
                            ),
                          ),
                          child: Text(
                            'RETAKE',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              fontSize: AppFonts.caption,
                              fontWeight: AppFonts.semiBold,
                              letterSpacing: 1.2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            // TEMPORARY: Mock completion since backend doesn't exist
                            try {
                              // Update user profile locally
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );

                              // Mark as completed in Firebase metadata
                              await authProvider.updateProfile({
                                ...userInfo,
                                'hasCompletedOnboarding': true,
                              });

                              // Navigate to main app
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/main',
                                );
                              }
                            } catch (e) {
                              print('Error completing onboarding: $e');
                              // Still navigate even if update fails
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/main',
                                );
                              }
                            }

                            /* ORIGINAL CODE - uncomment when backend is ready
                        await authProvider.updateProfile(userInfo);
                        await authProvider.completeOnboarding(videoUrl);
                        
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/main');
                        }
                        */
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.md,
                            ),
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              fontSize: AppFonts.caption,
                              fontWeight: AppFonts.semiBold,
                              letterSpacing: 1.2,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.secondary,
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.textTertiary,
              fontWeight: AppFonts.medium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.primary,
              fontSize: AppFonts.body1,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
          // Main content
          _buildInstructionsScreen(),

          // Recording overlay
          if (_showRecording) _buildRecordingOverlay(videoProvider),
        ],
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            child: Row(
              children: [
                Text(
                  'GRIBOUL',
                  style: TextStyle(
                    fontFamily: AppFonts.secondary,
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: AppFonts.semiBold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: AppColors.divider),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.xl),

                  // Section label
                  Text(
                    'FIRST POST',
                    style: TextStyle(
                      fontFamily: AppFonts.secondary,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: AppColors.textTertiary,
                      fontWeight: AppFonts.medium,
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Title
                  Text(
                    'Introduce Yourself',
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: 40,
                      fontWeight: AppFonts.bold,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Body text
                  Text(
                    'Record a brief video sharing your story. Help others understand who you are and what you\'re building.',
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: 18,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Instructions with minimal styling
                  Container(
                    padding: const EdgeInsets.only(left: AppSizes.md),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.divider, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstruction('State your name clearly'),
                        _buildInstruction('Mention your age and location'),
                        _buildInstruction('Describe what you\'re building'),
                        _buildInstruction('Keep it under 5 minutes'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // NYT-style button with hover effect
                  _NYTButton(onTap: _startRecording, text: 'Begin Recording'),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.secondary,
          fontSize: AppFonts.body2,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay(VideoProvider videoProvider) {
    return AnimatedBuilder(
      animation: _overlayFadeAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _cancelRecording,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * _overlayFadeAnimation.value,
              sigmaY: 10 * _overlayFadeAnimation.value,
            ),
            child: Container(
              color: AppColors.primaryBlack.withOpacity(
                0.8 * _overlayFadeAnimation.value,
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _overlayFadeAnimation,
                  child: Column(
                    children: [
                      // Top controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg,
                          vertical: AppSizes.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _cancelRecording,
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  fontFamily: AppFonts.secondary,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: AppFonts.medium,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (videoProvider.isRecording)
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.recordRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.xs),
                                  Text(
                                    'RECORDING',
                                    style: TextStyle(
                                      fontFamily: AppFonts.secondary,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                      fontWeight: AppFonts.medium,
                                      color: AppColors.recordRed,
                                    ),
                                  ),
                                ],
                              ),
                            GestureDetector(
                              onTap:
                                  () async =>
                                      await videoProvider.switchCamera(),
                              child: Text(
                                'FLIP',
                                style: TextStyle(
                                  fontFamily: AppFonts.secondary,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: AppFonts.medium,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Circular video preview with scale animation
                      Expanded(
                        child: Center(
                          child: ScaleTransition(
                            scale: _videoScaleAnimation,
                            child: GestureDetector(
                              onTap:
                                  () {}, // Prevent closing when tapping video
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textPrimary.withOpacity(
                                      0.3,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      videoProvider.isInitialized
                                          ? FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width:
                                                  videoProvider
                                                      .cameraController!
                                                      .value
                                                      .previewSize!
                                                      .height,
                                              height:
                                                  videoProvider
                                                      .cameraController!
                                                      .value
                                                      .previewSize!
                                                      .width,
                                              child: CameraPreview(
                                                videoProvider.cameraController!,
                                              ),
                                            ),
                                          )
                                          : Container(
                                            color: AppColors.surfaceBlack,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.textTertiary),
                                              ),
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom controls
                      Container(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          children: [
                            Text(
                              'SLIDE UP TO LOCK • SLIDE LEFT TO CANCEL',
                              style: TextStyle(
                                fontFamily: AppFonts.secondary,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.textTertiary,
                                fontWeight: AppFonts.medium,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xl),
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
                            const SizedBox(
                              height: 60,
                            ), // Space for slide indicators
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalRecordButton(VideoProvider videoProvider) {
    return GestureDetector(
      onLongPressStart: (_) async {
        HapticFeedback.selectionClick();
        await videoProvider.startRecording();
      },
      onLongPressEnd: (_) async {
        HapticFeedback.selectionClick();
        await videoProvider.stopRecording();
        if (videoProvider.currentVideoPath != null) {
          _handleVideoComplete(videoProvider.currentVideoPath!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryBlack,
          border: Border.all(
            color:
                videoProvider.isRecording
                    ? AppColors.recordRed
                    : AppColors.textPrimary,
            width: videoProvider.isRecording ? 3 : 2,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: videoProvider.isRecording ? 24 : 56,
            height: videoProvider.isRecording ? 24 : 56,
            decoration: BoxDecoration(
              color:
                  videoProvider.isRecording
                      ? AppColors.recordRed
                      : AppColors.textPrimary,
              shape:
                  videoProvider.isRecording
                      ? BoxShape.rectangle
                      : BoxShape.circle,
              borderRadius:
                  videoProvider.isRecording ? BorderRadius.circular(4) : null,
            ),
          ),
        ),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textTertiary, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'PROCESSING',
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: AppFonts.medium,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Analyzing your introduction',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontSize: AppFonts.body2,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _overlayAnimationController.dispose();
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    videoProvider.dispose();
    super.dispose();
  }
}

// NYT-style button widget
class _NYTButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;

  const _NYTButton({required this.onTap, required this.text});

  @override
  State<_NYTButton> createState() => _NYTButtonState();
}

class _NYTButtonState extends State<_NYTButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.elevatedBlack : AppColors.primaryBlack,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              fontFamily: AppFonts.secondary,
              fontSize: 13,
              fontWeight: AppFonts.semiBold,
              letterSpacing: 1.5,
              color:
                  _isPressed ? AppColors.textSecondary : AppColors.textPrimary,
            ),
            child: Text(widget.text.toUpperCase()),
          ),
        ),
      ),
    );
  }
}
