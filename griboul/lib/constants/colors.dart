import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - NYTimes inspired
  static const Color primaryBlack = Color(0xFF121212); // Softer than pure black
  static const Color surfaceBlack = Color(0xFF1A1A1A); // Slightly elevated
  static const Color elevatedBlack = Color(
    0xFF222222,
  ); // Cards and elevated surfaces

  // Text Colors - Better contrast
  static const Color textPrimary = Color(
    0xFFFFFFFF,
  ); // Pure white for headlines
  static const Color textSecondary = Color(0xFF999999); // Medium gray
  static const Color textTertiary = Color(0xFF666666); // Darker gray

  // Accent Colors
  static const Color accentBlue = Color(0xFF326891); // NYTimes signature blue
  static const Color accentGreen = Color(0xFF00C853); // Success
  static const Color accentRed = Color(0xFFE53935); // Softer red for record

  // UI Elements
  static const Color divider = Color(0xFF2C2C2C); // Subtle dividers
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color shimmer = Color(0xFF2A2A2A);

  // Video Recording
  static const Color recordRed = Color(0xFFE53935);
  static const Color recordPulse = Color(0xFFFF5252);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlack, surfaceBlack],
  );
}
