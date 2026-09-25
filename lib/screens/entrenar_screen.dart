import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/workout_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/plan_components.dart';
import 'category_detail_screen.dart';
import 'plan_form_screen.dart';

/// Equivale a `EntrenarView.tsx`.
class EntrenarView extends StatefulWidget {
  const EntrenarView({super.key, required this.onTabSelected});

  final ValueChanged<TabType> onTabSelected;

  @override
  State<EntrenarView> createState() => _EntrenarViewState();
}

class _EntrenarViewState extends State<EntrenarView> {
  late Exercise _exercise = buildInitialExercise();

  // Cronómetro de sesión
  int _sessionSeconds = 24 * 60 + 22;
  bool _isSessionRunning = true;
  Timer? _sessionTimer;

  // Serie activa
  int _activeSetId = 3;
  double _activeWeight = 80;
  int _activeReps = 8;

  // Descanso
  bool _showRestWidget = true;
  int _restSeconds = 71;
  int _totalRestSeconds = 90;
  bool _isRestPaused = false;
  Timer? _restTimer;

  bool _workoutFinished = false;

  @override
  void initState() {
    super.initState();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_isSessionRunning && !_workoutFinished) {
        setState(() => _sessionSeconds += 1);
      }
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isRestPaused && _showRestWidget && _restSeconds > 0) {
        setState(() => _restSeconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String _formatSeconds(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatWeight(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  // ------------------------------------------------------------- acciones
  void _adjustWeight(double delta) {
    setState(() {
      _activeWeight = (_activeWeight + delta).clamp(0, 999).toDouble();
      _activeWeight = double.parse(_activeWeight.toStringAsFixed(1));
    });
  }

  void _adjustReps(int delta) {
    setState(() {
      final next = _activeReps + delta;
      _activeReps = next < 1 ? 1 : (next > 999 ? 999 : next);
    });
  }

  void _logActiveSet() {
    final current = _exercise.sets.firstWhere((s) => s.id == _activeSetId);
    setState(() {
      current.weight = _activeWeight;
      current.reps = _activeReps;
      current.completed = true;

      final nextIndex = _exercise.sets.indexWhere(
        (s) => s.id == _activeSetId + 1,
      );
      if (nextIndex != -1) {
        final next = _exercise.sets[nextIndex];
        _activeSetId = next.id;
        _activeWeight = next.weight;
        _activeReps = next.reps;
      }

      _restSeconds = 90;
      _totalRestSeconds = 90;
      _isRestPaused = false;
      _showRestWidget = true;
    });

    showGymToast(
      context,
      '¡Serie ${current.id} registrada! Carga: ${_formatWeight(current.weight)} kg × ${current.reps} reps.',
    );
  }

  void _toggleSetCompleted(ExerciseSet set) {
    setState(() {
      set.completed = !set.completed;
      if (set.completed) {
        _restSeconds = 90;
        _totalRestSeconds = 90;
        _showRestWidget = true;
      }
    });
  }

  void _addSet() {
    final last = _exercise.sets.last;
    final newId = _exercise.sets.length + 1;
    setState(() {
      _exercise.sets.add(
        ExerciseSet(
          id: newId,
          type: 'Fuerza',
          prevWeight: last.weight,
          prevReps: last.reps,
          weight: last.weight,
          reps: last.reps,
        ),
      );
    });
    showGymToast(
      context,
      'Serie adicional #$newId agregada a la lista.',
      duration: const Duration(milliseconds: 2500),
    );
  }

  void _selectAlternative(ExerciseAlternative alt) {
    setState(() {
      _exercise.name = alt.name;
      _exercise.equipment = alt.description.split('·').first.trim();
      _exercise.image = alt.image;
      _exercise.tip = 'Variante inteligente: ${alt.description}';
    });
    Navigator.of(context).pop();
    showGymToast(
      context,
      '¡Ejercicio sustituido por: ${alt.name}! Cargas recalculadas.',
      duration: const Duration(milliseconds: 3500),
    );
  }

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    if (_workoutFinished) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _celebrationScreen(),
      );
    }

    final restProgress = _totalRestSeconds == 0
        ? 0.0
        : (_restSeconds / _totalRestSeconds)
              .toDouble()
              .clamp(0.0, 1.0)
              .toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topInset(context)),
              _liveHud(),
              Expanded(
                child: ContentShell(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      bottomInset(context) + (_showRestWidget ? 80 : 0),
                    ),
                    children: [
                      _plansSection(),
                      const SizedBox(height: 16),
                      _exerciseHero(),
                      const SizedBox(height: 16),
                      _setsSection(),
                      const SizedBox(height: 16),
                      _nextExerciseCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showRestWidget)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: _restWidget(restProgress),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _plansSection() {
    const categories = [
      RoutineCategory(
        name: 'Fuerza',
        description: 'Aumenta tu fuerza base',
        icon: Symbols.fitness_center,
      ),
      RoutineCategory(
        name: 'Hipertrofia',
        description: 'Construye masa muscular',
        icon: Symbols.trending_up,
      ),
    ];

    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planes personalizados',
                      style: AppText.headlineSm(size: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Elige una rutina o crea la tuya.',
                      style: AppText.bodySm(size: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Symbols.auto_awesome, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const StatChip(label: 'sesiones', value: '12'),
              const SizedBox(width: 8),
              const StatChip(label: 'racha', value: '4 dias'),
            ],
          ),
          const SizedBox(height: 10),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FeatureCard(
                title: category.name,
                subtitle: category.description,
                icon: category.icon,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CategoryDetailScreen(category: category),
                  ),
                ),
              ),
            ),
          ),
          FeatureCard(
            title: 'Crear mi plan',
            subtitle: 'Personaliza objetivo y frecuencia',
            icon: Symbols.add_task,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlanFormScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- HUD en vivo
  Widget _liveHud() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border(bottom: BorderSide(color: AppColors.cardBorderSoft)),
      ),
      child: ContentShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const PulseDot(size: 8),
                            const SizedBox(width: 6),
                            Text(
                              'EN DIRECTO',
                              style: AppText.labelSm(
                                color: AppColors.primaryLight,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Empuje & Pecho',
                          style: AppText.headlineSm(size: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isSessionRunning = !_isSessionRunning),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.surfaceHighest),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSessionRunning
                                ? Symbols.timer
                                : Symbols.play_arrow,
                            size: 16,
                            color: AppColors.secondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatSeconds(_sessionSeconds),
                            style: AppText.metric(
                              color: AppColors.secondaryLight,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFinishDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Finalizar',
                        style: AppText.labelMd(
                          color: AppColors.onError,
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: ProgressBar(value: 0.42)),
                  const SizedBox(width: 8),
                  Text('Ejercicio 2 de 5', style: AppText.labelSm(size: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------- ejercicio activo
  Widget _exerciseHero() {
    return SurfaceCard(
      color: AppColors.surfaceHigh,
      borderColor: AppColors.surfaceHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(
                          label: _exercise.targetMuscle.toUpperCase(),
                          background: AppColors.fade(AppColors.primary, 0.15),
                          foreground: AppColors.primaryLight,
                          bold: true,
                        ),
                        Pill(label: _exercise.equipment),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_exercise.name, style: AppText.headlineMd(size: 20)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RemoteImage(url: _exercise.image, width: 64, height: 64),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botón "¿Equipo ocupado?"
          InkWell(
            onTap: _openAlternativesSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.fade(AppColors.secondary, 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.fade(AppColors.secondary, 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.sync,
                      size: 18,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Equipo ocupado?',
                          style: AppText.labelMd(
                            color: AppColors.secondaryLight,
                            size: 12,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Sustituir ejercicio sin perder volumen',
                          style: AppText.bodySm(size: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Ver opciones',
                    style: AppText.labelMd(
                      color: AppColors.secondaryLight,
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Symbols.chevron_right,
                    size: 18,
                    color: AppColors.secondaryLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tip
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.surfaceLowest, 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderSoft),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.lightbulb,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _exercise.tip,
                    style: AppText.bodySm(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- tabla de series
  Widget _setsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Series & Cargas', style: AppText.headlineSm()),
            const Spacer(),
            Text(
              'Objetivo: ${_exercise.objectiveRPE}',
              style: AppText.labelSm(size: 12, letterSpacing: 0),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text('SERIE', style: _headerStyle)),
              Expanded(
                flex: 3,
                child: Text(
                  'ANTERIOR',
                  textAlign: TextAlign.center,
                  style: _headerStyle,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'PESO × REPS',
                  textAlign: TextAlign.center,
                  style: _headerStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'ESTADO',
                  textAlign: TextAlign.right,
                  style: _headerStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._exercise.sets.map((set) {
          final isActive = set.id == _activeSetId && !set.completed;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: isActive ? _activeSetCard(set) : _setRow(set),
          );
        }),
        const SizedBox(height: 4),
        InkWell(
          onTap: _addSet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Symbols.add,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Añadir Serie Adicional',
                  style: AppText.labelMd(
                    color: AppColors.onSurfaceVariant,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _headerStyle =>
      AppText.labelSm(size: 11, weight: FontWeight.w700);

  Widget _setRow(ExerciseSet set) {
    return InkWell(
      onTap: set.completed
          ? null
          : () => setState(() {
              _activeSetId = set.id;
              _activeWeight = set.weight;
              _activeReps = set.reps;
            }),
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: set.completed ? 1 : 0.7,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorderSoft),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${set.id}',
                      style: AppText.labelMd(size: 14, weight: FontWeight.w700),
                    ),
                    Text(set.type, style: AppText.labelSm(size: 10)),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${_formatWeight(set.prevWeight)} kg × ${set.prevReps}',
                  textAlign: TextAlign.center,
                  style: AppText.metric(
                    color: AppColors.onSurfaceVariant,
                    size: 12,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  '${_formatWeight(set.weight)} kg × ${set.reps}',
                  textAlign: TextAlign.center,
                  style: AppText.metric(size: 14, weight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _toggleSetCompleted(set),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: set.completed
                            ? AppColors.primary
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        set.completed ? Symbols.check : Symbols.hourglass_empty,
                        size: 20,
                        weight: 700,
                        color: set.completed
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeSetCard(ExerciseSet set) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fade(AppColors.primary, 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Pill(
                          label: 'SERIE ${set.id}',
                          background: AppColors.fade(AppColors.primary, 0.2),
                          foreground: AppColors.primaryLight,
                          fontSize: 12,
                          bold: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'En curso',
                          style: AppText.labelSm(
                            color: AppColors.secondaryLight,
                            size: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ant: ${_formatWeight(set.prevWeight)} kg × ${set.prevReps}',
                          style: AppText.metric(
                            color: AppColors.onSurfaceVariant,
                            size: 11,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _stepper(
                            title: 'CARGA (KG)',
                            value: _formatWeight(_activeWeight),
                            unit: 'kg',
                            onMinus: () => _adjustWeight(-2.5),
                            onPlus: () => _adjustWeight(2.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _stepper(
                            title: 'REPETICIONES',
                            value: '$_activeReps',
                            unit: 'reps',
                            onMinus: () => _adjustReps(-1),
                            onPlus: () => _adjustReps(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Registrar Serie ${set.id}',
                      icon: Symbols.check_circle,
                      height: 48,
                      radius: 12,
                      onPressed: _logActiveSet,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepper({
    required String title,
    required String value,
    required String unit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceHighest),
      ),
      child: Column(
        children: [
          Text(title, style: AppText.labelSm(size: 10)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepperButton('-', onMinus),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      value,
                      style: AppText.metric(size: 20, weight: FontWeight.w700),
                    ),
                    Text(unit, style: AppText.labelSm(size: 10)),
                  ],
                ),
              ),
              _stepperButton('+', onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: AppText.headlineSm(size: 18, color: AppColors.onSurface),
        ),
      ),
    );
  }

  // ------------------------------------------------------ siguiente en cola
  Widget _nextExerciseCard() {
    return SurfaceCard(
      color: AppColors.surfaceLow,
      borderColor: AppColors.cardBorderSoft,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceHighest),
            ),
            child: const Icon(
              Symbols.arrow_forward,
              size: 24,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIGUIENTE EJERCICIO', style: AppText.labelSm(size: 10)),
                Text(
                  'Aperturas con Mancuernas',
                  style: AppText.headlineSm(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '3 series × 12 reps · Banco inclinado',
                  style: AppText.bodySm(),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                showGymToast(context, 'Orden de ejercicios reorganizado.'),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.swap_vert,
                size: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ widget descanso
  Widget _restWidget(double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighest),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.fade(AppColors.secondary, 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.hourglass_bottom,
                  size: 18,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descanso entre series',
                      style: AppText.labelSm(size: 10),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatSeconds(_restSeconds),
                          style: AppText.metric(
                            color: AppColors.secondaryLight,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'restantes',
                            overflow: TextOverflow.ellipsis,
                            style: AppText.labelSm(
                              color: AppColors.fade(
                                AppColors.secondaryLight,
                                0.8,
                              ),
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _restAction(
                child: Text(
                  '+30s',
                  style: AppText.labelMd(
                    color: AppColors.secondaryLight,
                    size: 12,
                    weight: FontWeight.w700,
                  ),
                ),
                onTap: () => setState(() {
                  _restSeconds += 30;
                  _totalRestSeconds = _totalRestSeconds > _restSeconds
                      ? _totalRestSeconds
                      : _restSeconds;
                }),
              ),
              const SizedBox(width: 6),
              _restAction(
                child: Icon(
                  _isRestPaused ? Symbols.play_arrow : Symbols.pause,
                  size: 18,
                  color: AppColors.onSurface,
                ),
                onTap: () => setState(() => _isRestPaused = !_isRestPaused),
              ),
              const SizedBox(width: 6),
              _restAction(
                child: Text(
                  'Omitir',
                  style: AppText.labelMd(
                    color: AppColors.onSurfaceVariant,
                    size: 12,
                  ),
                ),
                onTap: () => setState(() => _showRestWidget = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            value: progress,
            color: AppColors.secondary,
            background: AppColors.surface,
          ),
        ],
      ),
    );
  }

  Widget _restAction({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------- alternativas
  void _openAlternativesSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: const Color(0xCC000000),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          maxWidth: kMaxContentWidth,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.surfaceHighest)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Pill(
                                label: 'EQUIPO OCUPADO',
                                background: AppColors.fade(
                                  AppColors.secondary,
                                  0.2,
                                ),
                                foreground: AppColors.secondaryLight,
                                fontSize: 10,
                                bold: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Alternativas Inteligentes',
                                style: AppText.labelSm(size: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sustituciones para Press de Banca',
                            style: AppText.headlineMd(size: 18),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.close,
                          size: 18,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Selecciona una variante bio-mecánica equivalente con el mismo '
                  'estímulo sobre el pectoral mayor y tríceps:',
                  style: AppText.bodyMd(size: 12, height: 1.6),
                ),
                const SizedBox(height: 12),
                ..._exercise.alternatives.map(_alternativeTile),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mantener Barra y Esperar',
                      style: AppText.labelMd(
                        color: AppColors.onSurfaceVariant,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _alternativeTile(ExerciseAlternative alt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _selectAlternative(alt),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RemoteImage(url: alt.image, width: 56, height: 56),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alt.name,
                            style: AppText.headlineSm(size: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          label: '${alt.matchPercentage}% Match',
                          background: AppColors.fade(AppColors.primary, 0.15),
                          foreground: AppColors.primaryLight,
                          fontSize: 10,
                          bold: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(alt.description, style: AppText.bodySm(size: 11)),
                    const SizedBox(height: 4),
                    Text(
                      alt.suggestedLoad,
                      style: AppText.metric(
                        color: AppColors.secondaryLight,
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Cambiar',
                  style: AppText.labelMd(
                    color: AppColors.onPrimary,
                    size: 12,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- finalizar
  void _openFinishDialog() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xCC000000),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 384),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceHighest),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.fade(AppColors.primary, 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.emoji_events,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Finalizar Entrenamiento?',
                style: AppText.headlineMd(size: 20),
              ),
              const SizedBox(height: 6),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppText.bodySm(),
                  children: [
                    const TextSpan(text: 'Has completado '),
                    TextSpan(
                      text: _formatSeconds(_sessionSeconds),
                      style: AppText.bodySm(
                        color: AppColors.primary,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text: ' de sesión con 16 series y un nuevo récord en press.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _dialogButton(
                      label: 'Continuar',
                      background: AppColors.surfaceHigh,
                      foreground: AppColors.onSurfaceVariant,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dialogButton(
                      label: 'Guardar y Cerrar',
                      background: AppColors.primary,
                      foreground: AppColors.onPrimary,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        setState(() => _workoutFinished = true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppText.labelMd(
            color: foreground,
            size: 12,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------- celebración
  Widget _celebrationScreen() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        24,
        topInset(context),
        24,
        bottomInset(context),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.fade(AppColors.primary, 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fade(AppColors.primary, 0.4),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: const Icon(
                  Symbols.verified,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Pill(
                label: '¡ENTRENAMIENTO REGISTRADO!',
                background: AppColors.fade(AppColors.primary, 0.15),
                foreground: AppColors.primaryLight,
                fontSize: 12,
                bold: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¡Gran trabajo, Carlos!',
                textAlign: TextAlign.center,
                style: AppText.headlineLg(),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  'Consistencia intachable. Tu volumen hoy aportó 3,850 kg a tu '
                  'progreso semanal y desbloqueó la insignia de Racha.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyMd(height: 1.6),
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryTile(
                        'TIEMPO',
                        _formatSeconds(_sessionSeconds),
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryTile(
                        'SERIES',
                        '16',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryTile(
                        'CARGA',
                        '3.8k kg',
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Ver Mi Progreso',
                      onPressed: () {
                        setState(() => _workoutFinished = false);
                        widget.onTabSelected(TabType.progreso);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _workoutFinished = false);
                          widget.onTabSelected(TabType.inicio);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(
                            color: AppColors.surfaceHighest,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Volver al Inicio',
                          style: AppText.labelMd(
                            color: AppColors.onSurfaceVariant,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceHighest),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppText.labelSm(size: 10, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppText.metric(color: color, size: 18)),
        ],
      ),
    );
  }
}
