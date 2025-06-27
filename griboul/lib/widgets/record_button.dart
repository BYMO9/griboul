import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class RecordButton extends StatefulWidget {
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final bool isRecording;

  const RecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordEnd,
    this.isRecording = false,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    widget.onRecordStart();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onRecordEnd();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onRecordEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: AppSizes.recordButtonSize,
              height: AppSizes.recordButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    widget.isRecording
                        ? AppColors.recordRed
                        : AppColors.textPrimary,
                boxShadow: [
                  if (widget.isRecording)
                    BoxShadow(
                      color: AppColors.recordRed.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  if (widget.isRecording)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(minutes: 5),
                      builder: (context, value, child) {
                        return SizedBox(
                          width: AppSizes.recordButtonSize + 8,
                          height: AppSizes.recordButtonSize + 8,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.recordPulse,
                            ),
                          ),
                        );
                      },
                    ),

                  // Center icon
                  Icon(
                    widget.isRecording ? Icons.stop : Icons.videocam,
                    color:
                        widget.isRecording
                            ? AppColors.textPrimary
                            : AppColors.primaryBlack,
                    size: 32,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
