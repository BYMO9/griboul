import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../providers/feed_provider.dart';

class VideoCard extends StatelessWidget {
  final VideoPost post;
  final VoidCallback onTap;

  const VideoCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        color: AppColors.primaryBlack,
        child: Row(
          children: [
            // Circular video thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceBlack,
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: ClipOval(
                child:
                    post.thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: post.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: AppColors.surfaceBlack,
                                child: Center(
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: AppColors.textTertiary,
                                    size: 24,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AppColors.surfaceBlack,
                                child: Center(
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: AppColors.textTertiary,
                                    size: 24,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: AppColors.surfaceBlack,
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: AppColors.textTertiary,
                              size: 28,
                            ),
                          ),
                        ),
              ),
            ),

            const SizedBox(width: AppSizes.md),

            // Video info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Builder name
                  Text(
                    post.userName,
                    style: TextStyle(
                      fontFamily: AppFonts.secondary,
                      fontSize: AppFonts.body1,
                      fontWeight: AppFonts.medium,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Time and duration
                  Row(
                    children: [
                      Text(
                        post.timeAgo.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '${post.duration ~/ 60} MIN WATCH',
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Play indicator
            Icon(Icons.play_arrow, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
