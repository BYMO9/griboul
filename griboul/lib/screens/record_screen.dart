import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:ui';
import '../utils/griboul_theme.dart';
import '../providers/video_provider.dart';
import '../widgets/circular_video_widget.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRecording = false;
  bool _showInstructions = true;
  String _recordingTime = '00:00';

  // Daily prompts
  final List<String> _prompts = [
    'What\'s the hardest problem you faced today?',
    'Show us what you\'re building right now',
    'What small win are you celebrating?',
    'What\'s keeping you up at night?',
    'Share your workspace and current challenge',
  ];

  String get _todaysPrompt {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _prompts[dayOfYear % _prompts.length];
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // Pulse animation for record button
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Fade animation for instructions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_fadeController);
  }

  Future<void> _initializeCamera() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.initializeCamera();
  }

  void _startRecording() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    setState(() {
      _isRecording = true;
      _showInstructions = false;
    });

    _fadeController.forward();
    HapticFeedback.heavyImpact();

    await videoProvider.startRecording();
    _startTimer();
  }

  void _stopRecording() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    setState(() {
      _isRecording = false;
    });

    HapticFeedback.mediumImpact();

    await videoProvider.stopRecording();

    if (videoProvider.currentVideoPath != null && mounted) {
      _showProcessingOverlay();
    }
  }

  void _startTimer() {
    int seconds = 0;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording) return false;

      seconds++;
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;

      if (mounted) {
        setState(() {
          _recordingTime =
              '${minutes.toString().padLeft(2, '0')}:'
              '${remainingSeconds.toString().padLeft(2, '0')}';
        });
      }

      // Auto-stop at 5 minutes
      if (seconds >= 300) {
        _stopRecording();
        return false;
      }

      return true;
    });
  }

  void _showProcessingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: GriboulTheme.ink.withOpacity(0.9),
      builder:
          (context) => _ProcessingOverlay(
            onComplete: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview (full screen)
          if (videoProvider.isInitialized)
            Positioned.fill(
              child: CameraPreview(videoProvider.cameraController!),
            )
          else
            Container(
              color: GriboulTheme.charcoal,
              child: const Center(
                child: CircularProgressIndicator(
                  color: GriboulTheme.ash,
                  strokeWidth: 2,
                ),
              ),
            ),

          // Gradient overlays
          _buildGradientOverlay(),

          // UI Layer
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(videoProvider),

                const Spacer(),

                // Center content
                if (_showInstructions && !_isRecording)
                  FadeTransition(
                    opacity: _fadeAnimation.drive(
                      Tween<double>(begin: 1.0, end: 0.0),
                    ),
                    child: _buildPromptCard(),
                  ),

                const Spacer(),

                // Bottom controls
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GriboulTheme.ink.withOpacity(0.6),
            Colors.transparent,
            Colors.transparent,
            GriboulTheme.ink.withOpacity(0.8),
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildTopBar(VideoProvider videoProvider) {
    return Container(
      padding: const EdgeInsets.all(GriboulTheme.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () {
              if (!_isRecording) {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GriboulTheme.ink.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: GriboulTheme.paper, size: 24),
            ),
          ),

          // Recording indicator
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GriboulTheme.space2,
                vertical: GriboulTheme.space1,
              ),
              decoration: BoxDecoration(
                color: GriboulTheme.recordRed,
                borderRadius: BorderRadius.circular(GriboulTheme.radiusCircle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: GriboulTheme.paper,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: GriboulTheme.space1),
                  Text(
                    _recordingTime,
                    style: GriboulTheme.mono.copyWith(
                      color: GriboulTheme.paper,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Flip camera
          GestureDetector(
            onTap: () async {
              if (!_isRecording) {
                await videoProvider.switchCamera();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GriboulTheme.ink.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flip_camera_ios,
                color: GriboulTheme.paper,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: GriboulTheme.space5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GriboulTheme.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(GriboulTheme.space3),
            decoration: BoxDecoration(
              color: GriboulTheme.charcoal.withOpacity(0.8),
              borderRadius: BorderRadius.circular(GriboulTheme.radiusMedium),
              border: Border.all(color: GriboulTheme.smoke, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TODAY\'S PROMPT',
                  style: GriboulTheme.overline.copyWith(
                    color: GriboulTheme.ash,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: GriboulTheme.space2),
                Text(
                  _todaysPrompt,
                  style: GriboulTheme.headline4.copyWith(
                    color: GriboulTheme.paper,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(GriboulTheme.space4),
      child: Column(
        children: [
          // Instructions
          if (!_isRecording)
            Text(
              'HOLD TO RECORD • 5 MIN MAX',
              style: GriboulTheme.overline.copyWith(
                color: GriboulTheme.ash,
                letterSpacing: 1.5,
              ),
            ),

          const SizedBox(height: GriboulTheme.space3),

          // Record button
          GestureDetector(
            onLongPressStart: (_) {
              if (!_isRecording) {
                _startRecording();
              }
            },
            onLongPressEnd: (_) {
              if (_isRecording) {
                _stopRecording();
              }
            },
            onTap: () {
              HapticFeedback.lightImpact();
              // Show hint
              if (!_isRecording) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hold to record', style: GriboulTheme.body2),
                    backgroundColor: GriboulTheme.charcoal,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isRecording
                              ? GriboulTheme.recordRed
                              : GriboulTheme.paper,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? GriboulTheme.recordRed
                                  : GriboulTheme.paper)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isRecording ? 24 : 32,
                        height: _isRecording ? 24 : 32,
                        decoration: BoxDecoration(
                          color:
                              _isRecording
                                  ? GriboulTheme.paper
                                  : GriboulTheme.ink,
                          shape:
                              _isRecording
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                          borderRadius:
                              _isRecording ? BorderRadius.circular(4) : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 60), // Space for gesture indicators
        ],
      ),
    );
  }
}

// Processing overlay widget
class _ProcessingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _ProcessingOverlay({required this.onComplete});

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay> {
  @override
  void initState() {
    super.initState();
    // Simulate processing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: GriboulTheme.smoke, width: 2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(GriboulTheme.paper),
                ),
              ),
            ),
          ),
          const SizedBox(height: GriboulTheme.space3),
          Text(
            'PROCESSING',
            style: GriboulTheme.overline.copyWith(
              color: GriboulTheme.ash,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: GriboulTheme.space1),
          Text(
            'Creating your moment...',
            style: GriboulTheme.body2.copyWith(color: GriboulTheme.mist),
          ),
        ],
      ),
    );
  }
}
