import 'package:flutter/material.dart';
import 'griboul_theme.dart';

class AppTheme {
  static ThemeData get darkTheme => GriboulTheme.darkTheme;

  // Keep this for backward compatibility
  static ThemeData get lightTheme => GriboulTheme.darkTheme;
}
