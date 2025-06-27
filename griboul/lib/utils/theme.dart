import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.accentBlue,
      scaffoldBackgroundColor: AppColors.primaryBlack,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentGreen,
        surface: AppColors.surfaceBlack,
        error: AppColors.accentRed,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.merriweather(
          fontSize: AppFonts.headline3,
          fontWeight: AppFonts.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Text Theme - NYTimes inspired
      textTheme: TextTheme(
        // Headlines - Serif font
        displayLarge: GoogleFonts.merriweather(
          fontSize: AppFonts.headline1,
          fontWeight: AppFonts.bold,
          color: AppColors.textPrimary,
          letterSpacing: AppFonts.tightSpacing,
        ),
        displayMedium: GoogleFonts.merriweather(
          fontSize: AppFonts.headline2,
          fontWeight: AppFonts.bold,
          color: AppColors.textPrimary,
          letterSpacing: AppFonts.tightSpacing,
        ),
        displaySmall: GoogleFonts.merriweather(
          fontSize: AppFonts.headline3,
          fontWeight: AppFonts.semiBold,
          color: AppColors.textPrimary,
        ),

        // Body text - Sans serif
        bodyLarge: GoogleFonts.inter(
          fontSize: AppFonts.body1,
          fontWeight: AppFonts.regular,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: AppFonts.body2,
          fontWeight: AppFonts.regular,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: AppFonts.caption,
          fontWeight: AppFonts.regular,
          color: AppColors.textTertiary,
        ),

        // Buttons
        labelLarge: GoogleFonts.inter(
          fontSize: AppFonts.button,
          fontWeight: AppFonts.semiBold,
          letterSpacing: AppFonts.wideSpacing,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: AppFonts.button,
            fontWeight: AppFonts.semiBold,
            letterSpacing: AppFonts.wideSpacing,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevatedBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: AppFonts.body1,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
