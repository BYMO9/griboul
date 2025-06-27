import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class WhatsAppRecordButton extends StatefulWidget {
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final bool isRecording;

  const WhatsAppRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.isRecording,
  });

  @override
  State<WhatsAppRecordButton> createState() => _WhatsAppRecordButtonState();
}

class _WhatsAppRecordButtonState extends State<WhatsAppRecordButton>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _lockController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _lockSlideAnimation;

  // States
  bool _isPressed = false;
  bool _isLocked = false;
  double _dragOffset = 0.0;

  // Constants
  static const double _lockThreshold = -80.0;
  static const double _cancelThreshold = 100.0;

  @override
  void initState() {
    super.initState();

    // Scale animation for press
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Pulse animation for recording
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Lock slide animation
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _lockSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lockController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _lockController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isPressed = true;
      _dragOffset = 0.0;
    });
    _scaleController.forward();
    _lockController.forward();
    widget.onRecordStart();

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    HapticFeedback.mediumImpact();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isLocked) return;

    setState(() {
      _dragOffset += details.delta.dx;

      // Check for lock
      if (details.localPosition.dy < _lockThreshold) {
        _isLocked = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isLocked) return;

    _stopRecording();
  }

  void _stopRecording() {
    setState(() {
      _isPressed = false;
      _isLocked = false;
      _dragOffset = 0.0;
    });

    _scaleController.reverse();
    _lockController.reverse();
    _pulseController.stop();
    _pulseController.reset();

    widget.onRecordEnd();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Lock indicator (slides up when recording)
        if (_isPressed && !_isLocked)
          Positioned(
            bottom: 100,
            child: FadeTransition(
              opacity: _lockSlideAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_lockSlideAnimation),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 2,
                      height: 30,
                      color: AppColors.textTertiary.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Cancel indicator (when sliding left)
        if (_isPressed && _dragOffset < -20)
          Positioned(
            left: -60,
            child: Opacity(
              opacity: (_dragOffset.abs() / _cancelThreshold).clamp(0.0, 1.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Main button
        GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Transform.translate(
            offset: Offset(_isLocked ? 0 : _dragOffset.clamp(-100, 0), 0),
            child: AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
              builder: (context, child) {
                final scale =
                    _isPressed
                        ? (_scaleAnimation.value *
                            (_isLocked ? _pulseAnimation.value : 1.0))
                        : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.isRecording
                              ? AppColors.recordRed
                              : AppColors.textPrimary,
                      boxShadow:
                          widget.isRecording
                              ? [
                                BoxShadow(
                                  color: AppColors.recordRed.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      widget.isRecording ? Icons.stop : Icons.mic,
                      color:
                          widget.isRecording
                              ? AppColors.textPrimary
                              : AppColors.primaryBlack,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Lock icon (when locked)
        if (_isLocked)
          Positioned(
            bottom: 100,
            child: GestureDetector(
              onTap: _stopRecording,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.recordRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stop,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),

        // Timer (when recording)
        if (widget.isRecording)
          Positioned(
            left: -80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.recordRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  StreamBuilder<int>(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                      (i) => i,
                    ),
                    builder: (context, snapshot) {
                      final seconds = snapshot.data ?? 0;
                      final minutes = seconds ~/ 60;
                      final remainingSeconds = seconds % 60;
                      return Text(
                        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
