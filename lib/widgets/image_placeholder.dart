import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Placeholder visual reutilizable que reemplaza las imágenes remotas
/// del proyecto original (hospedadas en un CDN externo de Google AI Studio).
///
/// Se decidió NO usar esas URLs porque son temporales y podrían dejar de
/// funcionar en cualquier momento, lo cual no es adecuado para una entrega
/// académica. En su lugar, se usa un [Container] con degradado + [Icon],
/// manteniendo la composición visual (tamaño, bordes, sombras) del diseño
/// original sin depender de internet.
class ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double? borderRadius;
  final double iconSize;

  const ImagePlaceholder({
    super.key,
    required this.icon,
    this.gradientColors = const [
      AppColors.cardBackgroundAlt,
      AppColors.cardBackgroundDark,
    ],
    this.borderRadius,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.textSecondary, size: iconSize),
    );
  }
}