import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Griboul Design System
/// Inspired by NYTimes editorial design with WhatsApp intimacy
class GriboulTheme {
  // Private constructor to prevent instantiation
  GriboulTheme._();

  /// Color Palette - Refined for better contrast and elegance
  static const Color ink = Color(0xFF0A0A0A); // Rich black, not pure black
  static const Color paper = Color(0xFFFAFAF8); // Warm white like newspaper
  static const Color charcoal = Color(0xFF1A1A1A); // Elevated surfaces
  static const Color smoke = Color(0xFF2D2D2D); // Borders and dividers
  static const Color ash = Color(0xFF666666); // Secondary text
  static const Color mist = Color(0xFF999999); // Tertiary text
  static const Color fog = Color(0xFFCCCCCC); // Disabled states

  // Accent colors - Muted and sophisticated
  static const Color ink60 = Color(0x99000000); // 60% black
  static const Color recordRed = Color(0xFFDC2626); // Sophisticated red
  static const Color successGreen = Color(0xFF059669); // Emerald
  static const Color linkBlue = Color(0xFF326891); // NYT blue

  /// Typography Scale - NYT Inspired
  static const TextStyle display = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body text - Clean sans-serif
  static const TextStyle body1 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  // UI Text - Precise and minimal
  static const TextStyle button = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'Courier',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Spacing System - Based on 8px grid
  static const double space1 = 8.0;
  static const double space2 = 16.0;
  static const double space3 = 24.0;
  static const double space4 = 32.0;
  static const double space5 = 40.0;
  static const double space6 = 48.0;
  static const double space7 = 56.0;
  static const double space8 = 64.0;
  static const double space9 = 72.0;
  static const double space10 = 80.0;

  /// Component Sizes
  static const double circularVideoSize = 88.0; // WhatsApp-inspired
  static const double circularVideoSizeLarge = 280.0; // Recording mode
  static const double recordButtonSize = 72.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  /// Border Radius
  static const double radiusNone = 0.0;
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusCircle = 999.0;

  /// Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Curve animationCurve = Curves.easeOutCubic;

  /// Shadows - Subtle depth
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: ink.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: ink.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: ink.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Get the complete theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      primaryColor: ink,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: ink,
        secondary: linkBlue,
        surface: charcoal,
        error: recordRed,
        onPrimary: paper,
        onSecondary: paper,
        onSurface: paper,
        onError: paper,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: headline3.copyWith(color: paper),
        centerTitle: false,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: display.copyWith(color: paper),
        displayMedium: headline1.copyWith(color: paper),
        displaySmall: headline2.copyWith(color: paper),
        headlineLarge: headline1.copyWith(color: paper),
        headlineMedium: headline2.copyWith(color: paper),
        headlineSmall: headline3.copyWith(color: paper),
        titleLarge: headline4.copyWith(color: paper),
        titleMedium: body1.copyWith(color: paper, fontWeight: FontWeight.w600),
        titleSmall: body2.copyWith(color: paper, fontWeight: FontWeight.w600),
        bodyLarge: body1.copyWith(color: paper),
        bodyMedium: body2.copyWith(color: paper),
        bodySmall: caption.copyWith(color: mist),
        labelLarge: button.copyWith(color: paper),
        labelMedium: caption.copyWith(
          color: paper,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: overline.copyWith(color: mist),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: smoke, thickness: 0.5, space: 0),

      // Icon Theme
      iconTheme: const IconThemeData(color: paper, size: iconSizeMedium),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ink,
        selectedItemColor: paper,
        unselectedItemColor: ash,
        selectedLabelStyle: caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Elevated Button (Primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: paper,
          foregroundColor: ink,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCircle),
          ),
          elevation: 0,
          textStyle: button,
        ),
      ),

      // Text Button (Secondary CTA)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: paper,
          minimumSize: const Size(64, 48),
          textStyle: button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: paper,
          side: BorderSide(color: smoke, width: 1),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCircle),
          ),
          textStyle: button,
        ),
      ),
    );
  }

  /// Typography Helpers
  static TextStyle status = overline; // For LATE NIGHT, DEBUGGING, etc.
  static TextStyle quote = body1.copyWith(
    fontFamily: 'Georgia',
    fontStyle: FontStyle.italic,
  );

  /// Layout Helpers
  static EdgeInsets get pagePadding => const EdgeInsets.all(space3);
  static EdgeInsets get cardPadding => const EdgeInsets.all(space2);
  static EdgeInsets get listItemPadding =>
      const EdgeInsets.symmetric(horizontal: space3, vertical: space2);

  /// Status Typography (No emojis!)
  static Widget buildStatus(String text, {Color? color}) {
    return Text(
      text.toUpperCase(),
      style: status.copyWith(color: color ?? mist, letterSpacing: 2.0),
    );
  }

  /// Time Context Badge
  static Widget buildTimeContext(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: space1, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: smoke, width: 0.5),
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      child: Text(
        time.toUpperCase(),
        style: overline.copyWith(color: ash, fontSize: 10, letterSpacing: 1.0),
      ),
    );
  }

  /// NYT Style Divider
  static Widget divider({double indent = 0}) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.only(left: indent),
      color: smoke,
    );
  }

  /// Loading Placeholder (NYT style)
  static Widget buildLoadingPlaceholder({
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: charcoal,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radiusSmall),
      ),
    );
  }
}
