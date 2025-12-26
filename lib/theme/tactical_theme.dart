import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TacticalTheme {
  // Color Palette [Source: Visual Spec Sheet]
  static const Color gunmetal = Color(0xFF2A2D31);
  static const Color oliveDrab = Color(0xFF4B5320);
  static const Color desertTan = Color(0xFFD8D0C0);
  static const Color rangerGreen = Color(0xFF354230);
  static const Color safetyOrange = Color(0xFFFF5F00); // Accent
  static const Color crtGreen = Color(0xFF00FF41);     // Digital Readouts

  // Text Styles
  static TextStyle get headerStencil => GoogleFonts.blackOpsOne(
    color: desertTan,
    fontSize: 24,
    letterSpacing: 1.5,
  );

  static TextStyle get dataMono => GoogleFonts.shareTechMono(
    color: Colors.black87,
    fontSize: 14,
  );

  static TextStyle get digitalReadout => GoogleFonts.shareTechMono(
    color: crtGreen,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // The Main App Theme
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: oliveDrab,
      scaffoldBackgroundColor: gunmetal,
      colorScheme: const ColorScheme.dark(
        primary: oliveDrab,
        secondary: safetyOrange,
        surface: Color(0xFF1F2226), // Darker Gunmetal for cards
      ),
      // Default to the "Field Manual" font family
      textTheme: GoogleFonts.shareTechMonoTextTheme(),
    );
  }
}
