import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Ancho maximo del contenido (equivale a `max-w-lg` de Tailwind).
const double kMaxContentWidth = 512;

/// Alto de la barra superior y de la barra inferior (sin safe areas).
const double kHeaderHeight = 64;
const double kBottomNavHeight = 64;

/// Espacio libre bajo la barra superior traslucida (equivale a `pt-16`).
double topInset(BuildContext context) =>
    MediaQuery.of(context).padding.top + kHeaderHeight;

/// Espacio libre sobre la barra inferior traslucida (equivale a `pb-28`).
double bottomInset(BuildContext context) =>
    MediaQuery.of(context).padding.bottom + kBottomNavHeight + 24;

/// Contenedor centrado con ancho maximo, usado por todas las vistas.
class ContentShell extends StatelessWidget {
  const ContentShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: child,
      ),
    );
  }
}

/// Tarjeta base: fondo de superficie, borde sutil y esquinas redondeadas.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.borderColor = AppColors.cardBorder,
    this.radius = 16,
    this.padding = const EdgeInsets.all(16),
    this.clip = false,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: child,
    );

    if (onTap == null) return decorated;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: decorated,
    );
  }
}

/// Chip/pastilla de texto (los `rounded-full` del diseno original).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.background = AppColors.surfaceHighest,
    this.foreground = AppColors.onSurfaceVariant,
    this.icon,
    this.borderColor,
    this.fontSize = 11,
    this.bold = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? borderColor;
  final double fontSize;
  final bool bold;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 4, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppText.labelSm(
              color: foreground,
              size: fontSize,
              weight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Imagen remota con placeholder y fallback (las URLs de demo pueden caducar).
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.surfaceHigh,
        );
      },
      errorBuilder: (context, error, stack) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceHigh,
        alignment: Alignment.center,
        child: const Icon(
          Symbols.image,
          color: AppColors.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
}

/// Barra de progreso simple con color y glow opcional.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.primary,
    this.background = AppColors.surfaceHighest,
    this.glow = true,
    this.gradient,
  });

  final double value; // 0..1
  final double height;
  final Color color;
  final Color background;
  final bool glow;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: background,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value < 0 ? 0.0 : (value > 1 ? 1.0 : value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: glow
                  ? [
                      BoxShadow(
                        color: AppColors.fade(color, 0.6),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Punto luminoso "en vivo" con parpadeo continuo.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.size = 8, this.color = AppColors.primary});

  final double size;
  final Color color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.fade(widget.color, 0.7), blurRadius: 6),
          ],
        ),
      ),
    );
  }
}

/// Toast superior con el estilo de la app (reemplaza los toasts de React).
void showGymToast(
  BuildContext context,
  String message, {
  Color accent = AppColors.primary,
  IconData icon = Symbols.task_alt,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.of(ctx).padding.top + 76,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xB3000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: AppText.bodySm(
                          color: AppColors.onSurface,
                          weight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}

/// Botón principal verde con glow (repetido en varias vistas).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.radius = 999,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.fade(AppColors.primary, 0.4),
            blurRadius: 24,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, fill: 1),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppText.headlineSm(color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}