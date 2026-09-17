import 'package:flutter/material.dart';

/// Paleta de colores extraída del diseño original (tema oscuro "GymMate").
/// Centralizar los colores aquí evita repetir valores hexadecimales
/// en cada pantalla y facilita mantener consistencia visual.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF101418);
  static const Color cardBackground = Color(0xFF1C2024);
  static const Color cardBackgroundAlt = Color(0xFF262A2F);
  static const Color cardBackgroundDark = Color(0xFF181C20);
  static const Color border = Color(0xFF31353A);

  static const Color primaryGreen = Color(0xFF00E676);
  static const Color lightGreen = Color(0xFF75FF9E);
  static const Color mint = Color(0xFF71FDBF);
  static const Color darkGreenText = Color(0xFF003918);

  static const Color orange = Color(0xFFFFB778);
  static const Color orangeStrong = Color(0xFFFD9000);
  static const Color yellowAlert = Color(0xFFFDD835);

  static const Color textPrimary = Color(0xFFE0E3E8);
  static const Color textSecondary = Color(0xFFBACBB9);
}