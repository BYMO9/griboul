import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String? thumbnailUrl;
  final String duration;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showPlayButton;
  final bool isPrivate;
  final BorderRadius? borderRadius;

  const VideoThumbnailWidget({
    super.key,
    this.thumbnailUrl,
    required this.duration,
    this.onTap,
    this.width,
    this.height,
    this.showPlayButton = true,
    this.isPrivate = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceBlack,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail image
            ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(4),
              child:
                  thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget:
                            (context, url, error) => _buildPlaceholder(),
                      )
                      : _buildPlaceholder(),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryBlack.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Play button
            if (showPlayButton)
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                ),
              ),

            // Private indicator
            if (isPrivate)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: AppColors.textPrimary,
                    size: 14,
                  ),
                ),
              ),

            // Duration badge
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceBlack,
      child: Icon(
        Icons.videocam_outlined,
        color: AppColors.textTertiary,
        size: 32,
      ),
    );
  }
}
