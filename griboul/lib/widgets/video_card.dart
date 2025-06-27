import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/griboul_theme.dart';
import 'circular_video_widget.dart';

/// Video card component that displays builder's moment
/// Combines NYT editorial design with WhatsApp circular video
class VideoCard extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String builderName;
  final String buildingWhat;
  final String miniStatement;
  final String timeAgo;
  final String duration;
  final String location;
  final CircularVideoStatus? status;
  final VoidCallback onTap;
  final bool isPlaying;

  const VideoCard({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.builderName,
    required this.buildingWhat,
    required this.miniStatement,
    required this.timeAgo,
    required this.duration,
    required this.location,
    this.status,
    required this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        color: GriboulTheme.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content area
            Padding(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular video
                  Hero(
                    tag: 'video_$videoUrl',
                    child: CircularVideoWidget(
                      videoUrl: videoUrl,
                      thumbnailUrl: thumbnailUrl,
                      size: GriboulTheme.circularVideoSize,
                      duration: duration,
                      status: status,
                      autoPlay: isPlaying,
                      showPlayButton: !isPlaying,
                    ),
                  ),

                  const SizedBox(width: GriboulTheme.space2),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Builder name
                        Text(
                          builderName,
                          style: GriboulTheme.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: GriboulTheme.paper,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // What they're building
                        Text(
                          buildingWhat,
                          style: GriboulTheme.caption.copyWith(
                            color: GriboulTheme.ash,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: GriboulTheme.space1),

                        // Time and location
                        Row(
                          children: [
                            Text(
                              timeAgo.toUpperCase(),
                              style: GriboulTheme.overline.copyWith(
                                color: GriboulTheme.mist,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: GriboulTheme.space1,
                              ),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: GriboulTheme.mist,
                                shape: BoxShape.circle,
                              ),
                            ),

                            Text(
                              '$duration WATCH',
                              style: GriboulTheme.overline.copyWith(
                                color: GriboulTheme.mist,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mini-statement (the hook)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GriboulTheme.space3,
                0,
                GriboulTheme.space3,
                GriboulTheme.space3,
              ),
              child: Text(
                '"$miniStatement"',
                style: GriboulTheme.quote.copyWith(
                  fontSize: 18,
                  height: 1.4,
                  color: GriboulTheme.paper.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subtle divider
            GriboulTheme.divider(indent: GriboulTheme.space3),
          ],
        ),
      ),
    );
  }
}

/// Alternative layout for featured videos (larger)
class FeaturedVideoCard extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String builderName;
  final String buildingWhat;
  final String miniStatement;
  final String timeAgo;
  final String duration;
  final String location;
  final String? prompt;
  final CircularVideoStatus? status;
  final VoidCallback onTap;

  const FeaturedVideoCard({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.builderName,
    required this.buildingWhat,
    required this.miniStatement,
    required this.timeAgo,
    required this.duration,
    required this.location,
    this.prompt,
    this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        color: GriboulTheme.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily prompt (if applicable)
                  if (prompt != null) ...[
                    GriboulTheme.buildStatus('TODAY\'S PROMPT'),
                    const SizedBox(height: GriboulTheme.space1),
                    Text(
                      prompt!,
                      style: GriboulTheme.caption.copyWith(
                        color: GriboulTheme.ash,
                      ),
                    ),
                    const SizedBox(height: GriboulTheme.space2),
                  ],

                  // Builder info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: GriboulTheme.charcoal,
                        child: Text(
                          builderName.substring(0, 1).toUpperCase(),
                          style: GriboulTheme.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: GriboulTheme.paper,
                          ),
                        ),
                      ),
                      const SizedBox(width: GriboulTheme.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              builderName,
                              style: GriboulTheme.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: GriboulTheme.paper,
                              ),
                            ),
                            Text(
                              '$location • $buildingWhat',
                              style: GriboulTheme.caption.copyWith(
                                color: GriboulTheme.ash,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Large circular video
            Center(
              child: Hero(
                tag: 'video_$videoUrl',
                child: CircularVideoWidget(
                  videoUrl: videoUrl,
                  thumbnailUrl: thumbnailUrl,
                  size: 200,
                  duration: duration,
                  status: status,
                ),
              ),
            ),

            // Mini-statement
            Padding(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    miniStatement,
                    style: GriboulTheme.headline3.copyWith(
                      height: 1.3,
                      color: GriboulTheme.paper,
                    ),
                  ),
                  const SizedBox(height: GriboulTheme.space2),

                  // Metadata
                  Row(
                    children: [
                      GriboulTheme.buildTimeContext(timeAgo),
                      const SizedBox(width: GriboulTheme.space2),
                      Text(
                        'VIEW',
                        style: GriboulTheme.overline.copyWith(
                          color: GriboulTheme.linkBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: GriboulTheme.smoke),
          ],
        ),
      ),
    );
  }
}
