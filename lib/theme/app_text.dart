import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipografica equivalente a las utilidades `.font-*` del CSS original.
/// Sora -> titulares, Plus Jakarta Sans -> cuerpo, Space Grotesk -> metricas.
class AppText {
  const AppText._();

  // ---------- Headline (Sora) ----------
  static TextStyle headlineLg({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w800,
  }) =>
      GoogleFonts.sora(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.64,
        fontWeight: weight,
        color: color,
      );

  static TextStyle headlineMd({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w700,
    double size = 24,
  }) =>
      GoogleFonts.sora(
        fontSize: size,
        height: 32 / 24,
        letterSpacing: -0.24,
        fontWeight: weight,
        color: color,
      );

  static TextStyle headlineSm({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w700,
    double size = 16,
  }) =>
      GoogleFonts.sora(
        fontSize: size,
        height: 1.35,
        fontWeight: weight,
        color: color,
      );

  // ---------- Body (Plus Jakarta Sans) ----------
  static TextStyle bodyLg({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: weight,
        color: color,
      );

  static TextStyle bodyMd({
    Color color = AppColors.onSurfaceVariant,
    FontWeight weight = FontWeight.w400,
    double size = 14,
    double height = 20 / 14,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        height: height,
        fontWeight: weight,
        color: color,
      );

  static TextStyle bodySm({
    Color color = AppColors.onSurfaceVariant,
    FontWeight weight = FontWeight.w400,
    double size = 12,
    double height = 16 / 12,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        height: height,
        fontWeight: weight,
        color: color,
      );

  // ---------- Label (Space Grotesk) ----------
  static TextStyle labelMd({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w600,
    double size = 13,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        height: 16 / 13,
        letterSpacing: 0.52,
        fontWeight: weight,
        color: color,
      );

  static TextStyle labelSm({
    Color color = AppColors.onSurfaceVariant,
    FontWeight weight = FontWeight.w600,
    double size = 11,
    double letterSpacing = 0.66,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        height: 14 / 11,
        letterSpacing: letterSpacing,
        fontWeight: weight,
        color: color,
      );

  // ---------- Metrica tabular (Space Grotesk, tnum) ----------
  static TextStyle metric({
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w700,
    double size = 14,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        letterSpacing: 0.28,
        fontWeight: weight,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}