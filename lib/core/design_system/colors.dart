import 'package:flutter/material.dart';

/// Paleta de colores oficial de Edaptia.
class EdaptiaColors {
  // Primarios
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);

  // Fondos
  static const backgroundLight = Color(0xFFFAFAFA);
  static const backgroundDark = Color(0xFF121212);
  static const surface = Color(0xFFFFFFFF);

  // Tarjetas
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E1E1E);

  // Texto
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Gradientes
  static const hookGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // Semánticos
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Bordes
  static const border = Color(0xFFE5E7EB);
  static const borderFocus = primary;
}
