import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de tipografía de Edaptia basado en Inter.
class EdaptiaTypography {
  // Títulos principales
  static TextStyle largeTitle = GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.2,
  );

  static TextStyle title1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  static TextStyle title2 = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.35,
  );

  static TextStyle title3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Cuerpo
  static TextStyle body = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.294,
    letterSpacing: -0.41,
  );

  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.294,
  );

  static TextStyle callout = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  static TextStyle subheadline = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static TextStyle footnote = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6B7280),
  );
}
