import 'package:flutter/material.dart';

/// Tokens de color equivalentes a los definidos en `src/index.css` (@theme).
class AppColors {
  const AppColors._();

  // Superficies
  static const Color background = Color(0xFF101418);
  static const Color surfaceLowest = Color(0xFF0B0F12);
  static const Color surfaceLow = Color(0xFF181C20);
  static const Color surface = Color(0xFF1C2024);
  static const Color surfaceHigh = Color(0xFF262A2F);
  static const Color surfaceHighest = Color(0xFF31353A);
  static const Color surfaceBright = Color(0xFF363A3E);

  // Texto
  static const Color onSurface = Color(0xFFE0E3E8);
  static const Color onSurfaceVariant = Color(0xFFBACBB9);
  static const Color outline = Color(0xFF859585);

  // Primario (verde electrico)
  static const Color primary = Color(0xFF00E676);
  static const Color primaryLight = Color(0xFF75FF9E);
  static const Color onPrimary = Color(0xFF003918);
  static const Color onPrimaryContainer = Color(0xFF00612E);

  // Secundario (naranja)
  static const Color secondary = Color(0xFFFD9000);
  static const Color secondaryLight = Color(0xFFFFB778);
  static const Color secondaryFixed = Color(0xFFFFDCC1);
  static const Color onSecondary = Color(0xFF4C2700);
  static const Color onSecondaryContainer = Color(0xFF613400);
  static const Color onSecondaryFixed = Color(0xFF2E1500);

  // Terciario (turquesa)
  static const Color tertiary = Color(0xFF71FDBF);
  static const Color tertiaryDim = Color(0xFF4EDEA3);
  static const Color onTertiary = Color(0xFF003824);

  // Error
  static const Color error = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFDAD6);
  static const Color errorLight = Color(0xFFFFB4AB);

  /// Borde suave usado en casi todas las tarjetas (#31353a con opacidad).
  static const Color cardBorder = Color(0x9931353A);
  static const Color cardBorderSoft = Color(0x6631353A);

  /// Helper para opacidades puntuales: `AppColors.fade(AppColors.primary, .15)`.
  static Color fade(Color color, double opacity) =>
      Color.fromRGBO(color.red, color.green, color.blue, opacity);
}