import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/griboul_theme.dart';

/// Daily recording prompt that appears once per day
/// Inspired by NYT breaking news banners
class DailyPromptBanner extends StatefulWidget {
  final String prompt;
  final VoidCallback onRecord;
  final VoidCallback onDismiss;

  const DailyPromptBanner({
    super.key,
    required this.prompt,
    required this.onRecord,
    required this.onDismiss,
  });

  @override
  State<DailyPromptBanner> createState() => _DailyPromptBannerState();
}

class _DailyPromptBannerState extends State<DailyPromptBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation.drive(
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: GriboulTheme.charcoal,
            border: Border(
              bottom: BorderSide(color: GriboulTheme.smoke, width: 1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: GriboulTheme.recordRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: GriboulTheme.space1),
                                Text(
                                  'DAILY PROMPT',
                                  style: GriboulTheme.overline.copyWith(
                                    color: GriboulTheme.recordRed,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: GriboulTheme.space1),

                            // The prompt
                            Text(
                              widget.prompt,
                              style: GriboulTheme.headline4.copyWith(
                                color: GriboulTheme.paper,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _handleDismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(GriboulTheme.space1),
                          child: Icon(
                            Icons.close,
                            color: GriboulTheme.ash,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: GriboulTheme.space2),

                  // Action buttons
                  Row(
                    children: [
                      // Record button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onRecord();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: GriboulTheme.space3,
                              vertical: GriboulTheme.space2,
                            ),
                            decoration: BoxDecoration(
                              color: GriboulTheme.paper,
                              borderRadius: BorderRadius.circular(
                                GriboulTheme.radiusCircle,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'RECORD YOUR RESPONSE',
                                style: GriboulTheme.button.copyWith(
                                  color: GriboulTheme.ink,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: GriboulTheme.space2),

                      // Skip button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _handleDismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GriboulTheme.space3,
                            vertical: GriboulTheme.space2,
                          ),
                          child: Text(
                            'SKIP',
                            style: GriboulTheme.button.copyWith(
                              color: GriboulTheme.ash,
                              letterSpacing: 1.0,
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
        ),
      ),
    );
  }
}

/// Inline prompt card that appears in the feed
class InlinePromptCard extends StatelessWidget {
  final String prompt;
  final VoidCallback onTap;

  const InlinePromptCard({
    super.key,
    required this.prompt,
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
        margin: const EdgeInsets.symmetric(
          horizontal: GriboulTheme.space3,
          vertical: GriboulTheme.space2,
        ),
        padding: const EdgeInsets.all(GriboulTheme.space3),
        decoration: BoxDecoration(
          color: GriboulTheme.charcoal,
          borderRadius: BorderRadius.circular(GriboulTheme.radiusMedium),
          border: Border.all(color: GriboulTheme.smoke, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt indicator
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: GriboulTheme.recordRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: GriboulTheme.space1),
                Text(
                  'TODAY\'S PROMPT',
                  style: GriboulTheme.overline.copyWith(
                    color: GriboulTheme.recordRed,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: GriboulTheme.space2),

            // Prompt text
            Text(
              prompt,
              style: GriboulTheme.headline4.copyWith(color: GriboulTheme.paper),
            ),

            const SizedBox(height: GriboulTheme.space2),

            // CTA
            Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  color: GriboulTheme.ash,
                  size: 20,
                ),
                const SizedBox(width: GriboulTheme.space1),
                Text(
                  'TAP TO RECORD',
                  style: GriboulTheme.overline.copyWith(
                    color: GriboulTheme.ash,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
