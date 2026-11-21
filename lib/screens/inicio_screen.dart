import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

import '../data/mock_data.dart';
import '../data/repositories/local_notification_service.dart';
import '../data/repositories/workout_repository.dart';
import '../models/models.dart';
import '../models/saved_workout.dart';
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
    required this.email,
    required this.ownerId,
    required this.streakDays,
    required this.workoutRepository,
    required this.notificationService,
  });

  final ValueChanged<TabType> onTabSelected;
  final double waterLitres;
  final VoidCallback onAddWater;
  final String email;
  final String ownerId;
  final int streakDays;
  final WorkoutRepository workoutRepository;
  final LocalNotificationService notificationService;

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  List<SavedWorkoutSession> _sessions = const [];
  String _displayName = '';
  String _trainingLevel = 'Intermedio';
  String _goal = 'Sin objetivo definido';
  String? _loadError;
  bool _sendingTestNotification = false;
  bool _hasLikedMyth = false;

  void _toggleMythLike() => setState(() => _hasLikedMyth = !_hasLikedMyth);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final sessions = await widget.workoutRepository.getSessions(
        widget.ownerId,
      );
      final profileValues = await Future.wait([
        widget.workoutRepository.getPreference(widget.ownerId, 'profile_name'),
        widget.workoutRepository.getPreference(
          widget.ownerId,
          'training_level',
        ),
        widget.workoutRepository.getPreference(widget.ownerId, 'fitness_goal'),
      ]);
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _displayName = profileValues[0] ?? '';
        _trainingLevel = profileValues[1] ?? _trainingLevel;
        _goal = profileValues[2] ?? _goal;
      });
    } on DatabaseException {
      if (mounted) {
        setState(() => _loadError = 'No se pudieron cargar tus datos locales.');
      }
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() => _sendingTestNotification = true);
    try {
      await widget.notificationService.showTestNotification();
      if (mounted) showGymToast(context, 'Notificación de prueba enviada.');
    } on StateError catch (error) {
      if (mounted) showGymToast(context, error.message);
    } on UnsupportedError catch (error) {
      if (mounted) showGymToast(context, error.message ?? error.toString());
    } on PlatformException catch (error) {
      if (mounted) {
        showGymToast(
          context,
          'No se pudo enviar la notificación: ${error.message ?? error.code}',
        );
      }
    } finally {
      if (mounted) setState(() => _sendingTestNotification = false);
    }
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
            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _loadError!,
                  style: AppText.bodySm(color: AppColors.error),
                ),
              ),
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

  // -------------------------------------------------------------- saludo
  Widget _greeting() {
    final name = _displayName.isEmpty
        ? (widget.email.isEmpty
              ? 'Atleta GymMate'
              : widget.email.split('@').first)
        : _displayName;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¡Hola, $name!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.headlineMd(),
                    ),
                  ),
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
                    TextSpan(text: 'Nivel: $_trainingLevel • '),
                    TextSpan(
                      text: 'Objetivo: $_goal',
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
          onTap: _sendingTestNotification ? null : _sendTestNotification,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _sendingTestNotification
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Symbols.notifications,
                      size: 22,
                      color: AppColors.onSurface,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- racha semanal
  Widget _weeklyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final completedDays = _sessions.map((session) {
      final date = session.completedAt.toLocal();
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
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
                label: '${widget.streakDays} días seguidos',
                background: AppColors.fade(AppColors.primaryLight, 0.1),
                foreground: AppColors.primaryLight,
                fontSize: 12,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (index) {
              final date = monday.add(Duration(days: index));
              final state = date == today
                  ? _DayState.today
                  : completedDays.contains(date)
                  ? _DayState.done
                  : _DayState.pending;
              return _dayCell(labels[index], state);
            }),
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
                          'ENTRENAMIENTO DISPONIBLE',
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
                    label: 'Nivel $_trainingLevel',
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
                Text('Press de banca con barra', style: AppText.headlineMd()),
                const SizedBox(height: 2),
                Text(
                  'Sesión base de ejemplo. Ajusta la carga y las series al entrenar.',
                  style: AppText.bodySm(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip(Symbols.timer, AppColors.secondaryLight, '0 min'),
                    _dotSeparator(),
                    _statChip(
                      Symbols.fitness_center,
                      AppColors.primaryLight,
                      '1 ejercicio',
                    ),
                    _dotSeparator(),
                    _statChip(Symbols.bolt, AppColors.tertiary, '4 series'),
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todaySessions = _sessions
        .where((session) {
          final date = session.completedAt.toLocal();
          return DateTime(date.year, date.month, date.day) == today;
        })
        .toList(growable: false);
    final setsToday = todaySessions.fold<int>(
      0,
      (total, session) => total + session.totalSets,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _metricTile(
            icon: Symbols.local_fire_department,
            color: AppColors.secondaryLight,
            value: '${todaySessions.length}',
            label: 'sesiones hoy',
            filled: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricTile(
            icon: Symbols.exercise,
            color: AppColors.primaryLight,
            value: '$setsToday',
            label: 'series hoy',
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
                      'Consulta información nutricional de alimentos y crea '
                      'una idea de plato acorde a tus preferencias.',
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
                          _hasLikedMyth ? 'Te gusta' : 'Me gusta',
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
                  onTap: () async {
                    await Clipboard.setData(
                      const ClipboardData(
                        text:
                            '¿Sudar más significa quemar más grasa? '
                            'No: el sudor regula la temperatura y no mide '
                            'directamente la pérdida de grasa.',
                      ),
                    );
                    if (mounted) {
                      showGymToast(
                        context,
                        'Cápsula copiada al portapapeles.',
                        accent: AppColors.secondaryLight,
                        icon: Symbols.check_circle,
                        duration: const Duration(milliseconds: 2200),
                      );
                    }
                  },
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

enum _DayState { done, today, pending }
