import 'package:flutter/material.dart';

/// Paleta Aelion — limpia, tranquila y premium
class AppColors {
  // Brand
  static const primary = Color(0xFF2A6AF1); // azul elegante
  static const secondary = Color(0xFF0E1A2B); // azul muy oscuro (headers)
  static const accent = Color(0xFFFFC857); // dorado suave (llamadas/íconos)

  // Superficies
  static const background = Color(0xFFF7F8FA); // gris muy claro (fondo general)
  static const surface = Color(0xFFFFFFFF); // tarjetas/botones
  static const neutral = Color(0xFFE9ECF1); // separadores/chips suaves

  // Texto (contraste correcto)
  static const onPrimary = Colors.white;
  static const onSecondary = Colors.white;
  static const onSurface = Color(0xFF1C2430); // texto principal
  static const onBackground = Color(0xFF2B3442); // texto en fondo

  // Estados
  static const success = Color(0xFF2DBE7E);
  static const warning = Color(0xFFFFB020);
  static const error = Color(0xFFE44E4E);
}
