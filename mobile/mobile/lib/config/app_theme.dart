import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // App colors - updated for better readability
  static const Color primaryColor = Color(0xFF1D7A4A);  // Medium Green (slightly brighter)
  static const Color accentColor = Color(0xFFBAFF72);   // Lighter Lime Green (better contrast)
  static const Color primaryGreen = Color(0xFF2D9D58);  // Brighter Medium Green
  static const Color secondaryGreen = Color(0xFF8EE269); // Light Green
  static const Color textColor = Color(0xFF212121);     // Nearly Black
  static const Color lightTextColor = Color(0xFFF5F5F5); // Off-white text for dark backgrounds
  static const Color backgroundColor = Color(0xFF1A3828); // Less dark green background
  static const Color surfaceColor = Color(0xFF244636);   // Surface color for cards
  static const Color cardColor = Color(0xFFF8FCF5);     // Very light green/white for cards
  static const Color errorColor = Color(0xFFE53935);    // Brighter Red
  
  // Input text style with black color
  static TextStyle getInputTextStyle() {
    return GoogleFonts.roboto(
      color: Colors.black87,
      fontSize: 16,
    );
  }
  
  // Input hint style with gray color
  static TextStyle getInputHintStyle() {
    return GoogleFonts.roboto(
      color: Colors.grey.shade600,
      fontSize: 16,
    );
  }
  
  // Logo Widget with Fallback
  static Widget getLogoWidget({double size = 100, bool withBackground = false}) {
    final logoContent = ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: size,
        height: size,
        placeholderBuilder: (BuildContext context) {
          // Fallback icon if the image fails to load
          return Icon(
            Icons.eco,
            size: size * 0.7,
            color: primaryColor,
          );
        },
      ),
    );
    
    if (withBackground) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: logoContent,
      );
    } else {
      return logoContent;
    }
  }
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: primaryGreen,
      error: errorColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: lightTextColor,
      onSecondary: textColor,
      onTertiary: lightTextColor,
      onBackground: lightTextColor,
      onSurface: lightTextColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 2,
      iconTheme: const IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.roboto(
        color: lightTextColor,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.roboto(
        color: lightTextColor,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.roboto(
        color: lightTextColor.withOpacity(0.8),
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: textColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Color(0xFF212121),
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF448866), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF448866), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: GoogleFonts.roboto(
        color: lightTextColor.withOpacity(0.8),
      ),
      hintStyle: GoogleFonts.roboto(
        color: lightTextColor.withOpacity(0.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: surfaceColor,
      contentTextStyle: GoogleFonts.roboto(
        color: lightTextColor,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: lightTextColor.withOpacity(0.2),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: accentColor,
      size: 24,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return null;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor.withOpacity(0.5);
        }
        return null;
      }),
    ),
  );
} 