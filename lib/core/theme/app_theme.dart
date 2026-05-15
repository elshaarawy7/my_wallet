import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const darkSurface = Color(0xFF16201D);
    const darkSurfaceSoft = Color(0xFF1D2A26);
    const darkBackground = Color(0xFF0F1513);
    const darkTextPrimary = Color(0xFFF2F5F3);
    const darkTextSecondary = Color(0xFFB5C3BE);

    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: AppConstants.primaryGreen,
      primary: AppConstants.primaryGreen,
      surface: isDark ? darkSurface : Colors.white,
      onSurface: isDark ? darkTextPrimary : AppConstants.darkText,
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFF8FD0B6) : AppConstants.lightMint,
    );

    final textTheme = GoogleFonts.cairoTextTheme().apply(
      bodyColor: isDark ? darkTextPrimary : AppConstants.darkText,
      displayColor: isDark ? darkTextPrimary : AppConstants.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? darkBackground : AppConstants.softBackground,
      textTheme: textTheme,
      dividerColor: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.07),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? darkTextPrimary : AppConstants.darkText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkSurface : Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      iconTheme: IconThemeData(
        color: isDark ? darkTextPrimary : AppConstants.darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceSoft : Colors.white,
        labelStyle: TextStyle(
          color: isDark ? darkTextSecondary : Colors.grey[700],
        ),
        hintStyle: TextStyle(
          color: isDark ? darkTextSecondary : Colors.grey[500],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : Colors.white,
        indicatorColor: isDark
            ? AppConstants.primaryGreen.withOpacity(0.25)
            : AppConstants.lightMint,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: isDark ? darkTextPrimary : AppConstants.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? (isDark ? Colors.white : AppConstants.primaryGreen)
                : (isDark ? darkTextSecondary : Colors.grey[600]),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? darkTextPrimary : AppConstants.darkText,
        textColor: isDark ? darkTextPrimary : AppConstants.darkText,
      ),
    );
  }
}
