import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Font Families - NYTimes inspired
  static String get primary =>
      GoogleFonts.merriweather().fontFamily!; // Serif for headlines
  static String get secondary =>
      GoogleFonts.inter().fontFamily!; // Sans for body

  // Font Sizes
  static const double headline1 = 32.0;
  static const double headline2 = 24.0;
  static const double headline3 = 20.0;
  static const double body1 = 16.0;
  static const double body2 = 14.0;
  static const double caption = 12.0;
  static const double button = 16.0;

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Letter Spacing
  static const double tightSpacing = -0.5;
  static const double normalSpacing = 0.0;
  static const double wideSpacing = 0.5;
}
