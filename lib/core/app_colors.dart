import 'package:flutter/material.dart';

import 'design_system/colors.dart';

/// Compat legacy para los sitios que aún importan `AppColors`.
/// Internamente delega en la paleta moderna de Edaptia.
class AppColors {
  static const primary = EdaptiaColors.primary;
  static const secondary = EdaptiaColors.primaryDark;
  static const accent = EdaptiaColors.primaryLight;

  static const background = EdaptiaColors.backgroundLight;
  static const surface = EdaptiaColors.surface;
  static const neutral = EdaptiaColors.border;

  static const onPrimary = Colors.white;
  static const onSecondary = Colors.white;
  static const onSurface = EdaptiaColors.textPrimary;
  static const onBackground = EdaptiaColors.textPrimary;

  static const success = EdaptiaColors.success;
  static const warning = EdaptiaColors.warning;
  static const error = EdaptiaColors.error;
}
