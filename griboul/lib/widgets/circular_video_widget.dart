import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../utils/griboul_theme.dart';

/// Circular video component inspired by WhatsApp video notes
/// Used throughout the app for video previews and playback
class CircularVideoWidget extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final double size;
  final bool autoPlay;
  final bool showPlayButton;
  final bool isRecording;
  final VoidCallback? onTap;
  final String? duration;
  final CircularVideoStatus? status;

  const CircularVideoWidget({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.size = GriboulTheme.circularVideoSize,
    this.autoPlay = false,
    this.showPlayButton = true,
    this.isRecording = false,
    this.onTap,
    this.duration,
    this.status,
  });

  @override
  State<CircularVideoWidget> createState() => _CircularVideoWidgetState();
}

class _CircularVideoWidgetState extends State<CircularVideoWidget>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for recording state
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.videoUrl != null && widget.autoPlay) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl!);
      await _controller!.initialize();

      if (mounted) {
        setState(() => _isLoading = false);

        if (widget.autoPlay) {
          _controller!.play();
          _controller!.setLooping(true);
          setState(() => _isPlaying = true);
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GriboulTheme.charcoal,
                border: Border.all(
                  color:
                      widget.isRecording
                          ? GriboulTheme.recordRed
                          : GriboulTheme.smoke,
                  width: widget.isRecording ? 3 : 1,
                ),
                boxShadow:
                    widget.isRecording
                        ? [
                          BoxShadow(
                            color: GriboulTheme.recordRed.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                        : GriboulTheme.shadowSmall,
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video or Thumbnail
                    _buildVideoContent(),

                    // Overlays
                    if (!widget.isRecording) ...[
                      // Play button overlay
                      if (widget.showPlayButton && !_isPlaying)
                        _buildPlayButton(),

                      // Duration overlay
                      if (widget.duration != null) _buildDurationBadge(),

                      // Status overlay (LATE NIGHT, etc)
                      if (widget.status != null) _buildStatusOverlay(),
                    ],

                    // Recording indicator
                    if (widget.isRecording) _buildRecordingIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoContent() {
    // If we have an initialized video controller
    if (_controller != null && _controller!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    // If we have a thumbnail
    if (widget.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    // Loading or placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    if (_isLoading && widget.videoUrl != null) {
      return Container(
        color: GriboulTheme.charcoal,
        child: Center(
          child: SizedBox(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(GriboulTheme.ash),
            ),
          ),
        ),
      );
    }

    return Container(
      color: GriboulTheme.charcoal,
      child: Icon(
        Icons.videocam_outlined,
        color: GriboulTheme.ash,
        size: widget.size * 0.4,
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(color: GriboulTheme.ink.withOpacity(0.6)),
      child: Center(
        child: Container(
          width: widget.size * 0.4,
          height: widget.size * 0.4,
          decoration: BoxDecoration(
            color: GriboulTheme.ink.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: GriboulTheme.paper,
            size: widget.size * 0.25,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size * 0.08,
          vertical: widget.size * 0.04,
        ),
        decoration: BoxDecoration(
          color: GriboulTheme.ink.withOpacity(0.8),
          borderRadius: BorderRadius.circular(GriboulTheme.radiusSmall),
        ),
        child: Text(
          widget.duration!,
          style: GriboulTheme.mono.copyWith(
            fontSize: widget.size * 0.12,
            color: GriboulTheme.paper,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Positioned(
      top: 4,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size * 0.1,
            vertical: widget.size * 0.04,
          ),
          decoration: BoxDecoration(
            color: GriboulTheme.ink.withOpacity(0.8),
            borderRadius: BorderRadius.circular(GriboulTheme.radiusSmall),
          ),
          child: Text(
            widget.status!.label.toUpperCase(),
            style: GriboulTheme.overline.copyWith(
              fontSize: widget.size * 0.1,
              color: widget.status!.color,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      color: GriboulTheme.recordRed.withOpacity(0.1),
      child: Center(
        child: Container(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          decoration: BoxDecoration(
            color: GriboulTheme.recordRed,
            shape: BoxShape.circle,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.fiber_manual_record,
                  color: GriboulTheme.paper,
                  size: widget.size * 0.2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Status types for circular videos
class CircularVideoStatus {
  final String label;
  final Color color;

  const CircularVideoStatus({required this.label, required this.color});

  // Predefined statuses (no emojis!)
  static const lateNight = CircularVideoStatus(
    label: 'LATE NIGHT',
    color: GriboulTheme.mist,
  );

  static const debugging = CircularVideoStatus(
    label: 'DEBUGGING',
    color: GriboulTheme.recordRed,
  );

  static const building = CircularVideoStatus(
    label: 'BUILDING',
    color: GriboulTheme.successGreen,
  );

  static const struggling = CircularVideoStatus(
    label: 'STRUGGLING',
    color: GriboulTheme.ash,
  );

  static const celebrating = CircularVideoStatus(
    label: 'WIN',
    color: GriboulTheme.successGreen,
  );
}
