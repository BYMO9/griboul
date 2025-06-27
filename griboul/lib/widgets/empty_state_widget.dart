import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textTertiary.withOpacity(0.5),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textTertiary,
                size: iconSize * 0.5,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 12),
              // Subtitle
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ],

            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              // Button
              GestureDetector(
                onTap: onButtonPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textPrimary, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    buttonText!.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
