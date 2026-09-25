import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

/// Equivale a `InicioView.tsx`.
class InicioView extends StatefulWidget {
  const InicioView({
    super.key,
    required this.onTabSelected,
    required this.waterLitres,
    required this.onAddWater,
  });

  final ValueChanged<TabType> onTabSelected;
  final double waterLitres;
  final VoidCallback onAddWater;

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  int _mythLikes = 142;
  bool _hasLikedMyth = false;
  bool _showNotificationToast = false;

  void _toggleMythLike() {
    setState(() {
      if (_hasLikedMyth) {
        _mythLikes -= 1;
        _hasLikedMyth = false;
      } else {
        _mythLikes += 1;
        _hasLikedMyth = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ContentShell(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            topInset(context) + 12,
            20,
            bottomInset(context),
          ),
          children: [
            if (_showNotificationToast) ...[
              _reminderBanner(),
              const SizedBox(height: 16),
            ],
            _greeting(),
            const SizedBox(height: 16),
            _weeklyStreak(),
            const SizedBox(height: 16),
            _featuredRoutine(),
            const SizedBox(height: 16),
            _dailyMetrics(),
            const SizedBox(height: 16),
            _nutriBanner(),
            const SizedBox(height: 16),
            _mythBuster(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- toast
  Widget _reminderBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fade(AppColors.primary, 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Symbols.notifications_active,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recordatorio: Hidrátate 30 min antes de tu sesión.',
              style: AppText.bodySm(color: AppColors.onSurface),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _showNotificationToast = false),
            child: const Icon(
              Symbols.close,
              color: AppColors.onSurfaceVariant,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- saludo
  Widget _greeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('¡Hola, Carlos!', style: AppText.headlineMd()),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppText.bodySm(),
                  children: [
                    const TextSpan(text: 'Nivel: Intermedio • '),
                    TextSpan(
                      text: 'Hoy toca Torso / Empuje',
                      style: AppText.bodySm(
                        color: AppColors.primaryLight,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () =>
              setState(() => _showNotificationToast = !_showNotificationToast),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(
                  Symbols.notifications,
                  size: 22,
                  color: AppColors.onSurface,
                ),
                Positioned(top: 10, right: 10, child: PulseDot(size: 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- racha semanal
  Widget _weeklyStreak() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.local_fire_department,
                color: AppColors.secondaryLight,
                size: 20,
                fill: 1,
              ),
              const SizedBox(width: 8),
              Text('Racha Semanal', style: AppText.headlineSm()),
              const Spacer(),
              Pill(
                label: '4 días seguidos',
                background: AppColors.fade(AppColors.primaryLight, 0.1),
                foreground: AppColors.primaryLight,
                fontSize: 12,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dayCell('L', _DayState.done),
              _dayCell('M', _DayState.done),
              _dayCell('X', _DayState.done),
              _dayCell('J', _DayState.today),
              _dayCell('V', _DayState.pending),
              _dayCell('S', _DayState.pending),
              _dayCell('D', _DayState.rest),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(String label, _DayState state) {
    final isToday = state == _DayState.today;

    Widget circle;
    switch (state) {
      case _DayState.done:
        circle = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.fade(AppColors.primary, 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Symbols.check,
            size: 16,
            color: AppColors.onPrimary,
            weight: 700,
          ),
        );
        break;
      case _DayState.today:
        circle = Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighest,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            'Hoy',
            style: AppText.metric(
              color: AppColors.primaryLight,
              size: 10,
              weight: FontWeight.w700,
            ),
          ),
        );
        break;
      case _DayState.pending:
        circle = Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorderSoft),
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.onSurfaceVariant, 0.3),
              shape: BoxShape.circle,
            ),
          ),
        );
        break;
      case _DayState.rest:
        circle = Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorderSoft),
          ),
          child: Icon(
            Symbols.hotel,
            size: 14,
            color: AppColors.fade(AppColors.secondaryLight, 0.6),
          ),
        );
        break;
    }

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppText.labelSm(
              color: isToday
                  ? AppColors.primaryLight
                  : AppColors.onSurfaceVariant,
              size: 12,
              weight: isToday ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          circle,
        ],
      ),
    );
  }

  // ------------------------------------------------------- rutina destacada
  Widget _featuredRoutine() {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 176,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const RemoteImage(url: Assets.todayWorkoutHero),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.surface,
                        AppColors.fade(AppColors.surface, 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fade(AppColors.surfaceLowest, 0.8),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.surfaceHighest),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PulseDot(size: 8),
                        const SizedBox(width: 6),
                        Text(
                          'ENTRENAMIENTO DE HOY',
                          style: AppText.labelSm(
                            color: AppColors.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Pill(
                    label: 'Intermedio',
                    background: AppColors.fade(AppColors.surfaceHigh, 0.8),
                    borderColor: AppColors.surfaceHighest,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Empuje & Pecho', style: AppText.headlineMd()),
                const SizedBox(height: 2),
                Text(
                  'Pectoral mayor, deltoides anterior & tríceps',
                  style: AppText.bodySm(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip(
                      Symbols.timer,
                      AppColors.secondaryLight,
                      '50 min',
                    ),
                    _dotSeparator(),
                    _statChip(
                      Symbols.fitness_center,
                      AppColors.primaryLight,
                      '5 ejercicios',
                    ),
                    _dotSeparator(),
                    _statChip(Symbols.bolt, AppColors.tertiary, '16 series'),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Iniciar Entrenamiento',
                  icon: Symbols.play_arrow,
                  onPressed: () => widget.onTabSelected(TabType.entrenar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppText.metric(size: 12, weight: FontWeight.w600)),
      ],
    );
  }

  Widget _dotSeparator() => Container(
    width: 4,
    height: 4,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: AppColors.surfaceHighest,
      shape: BoxShape.circle,
    ),
  );

  // -------------------------------------------------------- métricas del día
  Widget _dailyMetrics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _metricTile(
            icon: Symbols.local_fire_department,
            color: AppColors.secondaryLight,
            value: '450',
            label: 'kcal quemadas',
            filled: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricTile(
            icon: Symbols.exercise,
            color: AppColors.primaryLight,
            value: '3 de 4',
            label: 'entrenos meta',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricTile(
            icon: Symbols.water_drop,
            color: AppColors.tertiary,
            value: '${widget.waterLitres.toStringAsFixed(1)} L',
            label: 'de 2.5L agua',
            filled: true,
            onTap: widget.onAddWater,
          ),
        ),
      ],
    );
  }

  Widget _metricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return SurfaceCard(
      radius: 12,
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.cardBorderSoft,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.fade(color, 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color, fill: filled ? 1 : 0),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppText.metric(size: 18, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.labelSm(size: 11, letterSpacing: 0),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- NutriGuía
  Widget _nutriBanner() {
    return SurfaceCard(
      color: AppColors.surfaceHigh,
      borderColor: AppColors.surfaceHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const RemoteImage(
                  url: Assets.nutriSalmonThumb,
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Symbols.restaurant_menu,
                          size: 16,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NUTRIGUÍA SUGERIDA',
                          style: AppText.labelSm(
                            color: AppColors.tertiary,
                            size: 10,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arma tu plato post-entreno',
                      style: AppText.headlineSm(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Descubre la proporción ideal de 40g de proteína magra y '
                      'carbohidratos complejos para acelerar tu síntesis muscular.',
                      style: AppText.bodySm(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorderSoft),
          const SizedBox(height: 8),
          Row(
            children: [
              Pill(
                label: 'Proteína + Carbos',
                background: AppColors.fade(AppColors.tertiary, 0.15),
                foreground: AppColors.tertiary,
                bold: true,
              ),
              const SizedBox(width: 8),
              const Pill(label: '3 min lectura'),
              const Spacer(),
              InkWell(
                onTap: () => widget.onTabSelected(TabType.nutriguia),
                child: Row(
                  children: [
                    Text(
                      'Explorar',
                      style: AppText.labelMd(
                        color: AppColors.primary,
                        size: 12,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Symbols.arrow_forward,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- mito del día
  Widget _mythBuster() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.lightbulb,
                size: 20,
                color: AppColors.secondary,
                fill: 1,
              ),
              const SizedBox(width: 6),
              Text(
                'MITO FITNESS DEL DÍA',
                style: AppText.labelSm(
                  color: AppColors.secondary,
                  size: 11,
                  weight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text('1 min lectura', style: AppText.labelSm(size: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¿Sudar más significa quemar más grasa corporal?',
            style: AppText.headlineSm(),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: AppText.bodySm(height: 1.6),
              children: [
                TextSpan(
                  text: 'Falso. ',
                  style: AppText.bodySm(
                    color: AppColors.errorLight,
                    weight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text:
                      'El sudor es un mecanismo de termorregulación para enfriar el '
                      'cuerpo (pérdida de agua y sales), no un indicador directo de '
                      'lipólisis. El gasto calórico real depende de la intensidad '
                      'metabólica y esfuerzo cardiovascular.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderSoft),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Te resultó útil esta cápsula?',
                    style: AppText.labelSm(size: 12, letterSpacing: 0),
                  ),
                ),
                InkWell(
                  onTap: _toggleMythLike,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _hasLikedMyth
                          ? AppColors.fade(AppColors.primary, 0.2)
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.thumb_up,
                          size: 16,
                          fill: _hasLikedMyth ? 1 : 0,
                          color: _hasLikedMyth
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_mythLikes',
                          style: AppText.labelSm(
                            color: _hasLikedMyth
                                ? AppColors.primary
                                : AppColors.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => showGymToast(
                    context,
                    '¡Cápsula copiada al portapapeles para compartir!',
                    accent: AppColors.secondaryLight,
                    icon: Symbols.check_circle,
                    duration: const Duration(milliseconds: 2200),
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.share,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _DayState { done, today, pending, rest }
