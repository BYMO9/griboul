import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../constants/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        // Navigation is handled by AuthWrapper in main.dart
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Griboul Logo/Text with animation
            Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontFamily: AppFonts.primary,
                    fontSize: 56,
                    fontWeight: AppFonts.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: AppFonts.tightSpacing,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: AppSizes.sm),

            // Tagline with staggered animation
            Text(
                  AppStrings.tagline.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppFonts.secondary,
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                    color: AppColors.textSecondary,
                    letterSpacing: 2.0,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 400.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 80),

            // Subtle loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 800 + (index * 100)),
                      duration: 400.ms,
                    )
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      delay: Duration(milliseconds: 800 + (index * 100)),
                      duration: 400.ms,
                    )
                    .then()
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.3, 1.3),
                      duration: 600.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.3, 1.3),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeInOut,
                    );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative minimalist version without flutter_animate
class SplashScreenSimple extends StatelessWidget {
  const SplashScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontSize: 48,
                fontWeight: AppFonts.bold,
                color: AppColors.textPrimary,
                letterSpacing: AppFonts.tightSpacing,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.tagline,
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                fontSize: AppFonts.body1,
                fontWeight: AppFonts.regular,
                color: AppColors.textSecondary,
                letterSpacing: AppFonts.wideSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
