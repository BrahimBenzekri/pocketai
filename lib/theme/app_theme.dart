import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Dark Theme Colors
  static const Color primaryColor = Color(0xFF6C63FF); // Keep the signature purple but maybe tweak
  static const Color primaryVariant = Color(0xFF554AF0);
  static const Color secondaryColor = Color(0xFF00E676); // Vibrant Green for money/success
  static const Color accentColor = Color(0xFFFF4081); // Pink for highlights
  
  static const Color backgroundColor = Color(0xFF0F1115); // Deep rich dark
  static const Color surfaceColor = Color(0xFF181B21); // Slightly lighter for cards
  static const Color surfaceVariant = Color(0xFF23262F); // For elevated surfaces
  
  static const Color errorColor = Color(0xFFFF5252);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A3BD);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: onPrimary,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
      // cardTheme: CardTheme(
      //   color: surfaceColor,
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
