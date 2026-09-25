import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

enum _SubTab { plato, aprende, mitos }

/// Equivale a `NutriGuiaView.tsx`.
class NutriGuiaView extends StatefulWidget {
  const NutriGuiaView({super.key});

  @override
  State<NutriGuiaView> createState() => _NutriGuiaViewState();
}

class _NutriGuiaViewState extends State<NutriGuiaView> {
  _SubTab _tab = _SubTab.plato;

  FoodItem _protein = kFoodOptions.firstWhere((f) => f.id == 'p1');
  FoodItem _carb = kFoodOptions.firstWhere((f) => f.id == 'c1');
  FoodItem _veggie = kFoodOptions.firstWhere((f) => f.id == 'v1');
  FoodItem _fat = kFoodOptions.firstWhere((f) => f.id == 'f1');

  int? _openAccordion;

  int get _totalProtein =>
      _protein.protein + _carb.protein + _veggie.protein + _fat.protein;
  int get _totalCarbs => _protein.carbs + _carb.carbs + _veggie.carbs + _fat.carbs;
  int get _totalFat => _protein.fat + _carb.fat + _veggie.fat + _fat.fat;
  int get _totalCalories =>
      _protein.calories + _carb.calories + _veggie.calories + _fat.calories;

  List<FoodItem> _optionsFor(FoodCategory category) =>
      kFoodOptions.where((f) => f.category == category).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ContentShell(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            topInset(context) + 8,
            20,
            bottomInset(context),
          ),
          children: [
            _headerBanner(),
            const SizedBox(height: 16),
            _segmentedTabs(),
            const SizedBox(height: 16),
            if (_tab == _SubTab.plato) ..._plateTab(),
            if (_tab == _SubTab.aprende) ..._learnTab(),
            if (_tab == _SubTab.mitos) ..._mythsTab(),
            const SizedBox(height: 16),
            _disclaimer(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- header
  Widget _headerBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.surfaceHighest),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.eco,
                  size: 18, color: AppColors.primaryLight, fill: 1),
              const SizedBox(width: 6),
              Text(
                'Nutrición Sin Culpa · Enfoque Flexible',
                style: AppText.labelSm(
                  color: AppColors.primaryLight,
                  size: 12,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('NutriGuía Educativa 🥑', style: AppText.headlineMd()),
        const SizedBox(height: 4),
        Text(
          'Aprende a nutrir tu cuerpo según tus metas sin dietas restrictivas '
          'ni reglas imposibles.',
          style: AppText.bodyMd(size: 12, height: 1.6),
        ),
      ],
    );
  }

  Widget _segmentedTabs() {
    Widget item(_SubTab tab, String emoji, String label) {
      final selected = _tab == tab;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.fade(AppColors.primary, 0.3),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppText.labelMd(
                    color: selected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                    size: 12,
                    weight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorderSoft),
      ),
      child: Row(
        children: [
          item(_SubTab.plato, '🍽️', 'Arma tu Plato'),
          item(_SubTab.aprende, '📚', 'Aprende'),
          item(_SubTab.mitos, '⚖️', 'Mitos'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- tab 1: plato
  List<Widget> _plateTab() {
    return [
      SurfaceCard(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Symbols.pie_chart, size: 20, color: AppColors.tertiary),
                const SizedBox(width: 8),
                Text('Método del Plato', style: AppText.headlineSm(size: 14)),
                const Spacer(),
                Pill(
                  label: 'Balance 50 / 25 / 25',
                  background: AppColors.fade(AppColors.primary, 0.1),
                  foreground: AppColors.primaryLight,
                  fontSize: 11,
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 224,
              height: 224,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(224, 224),
                    painter: _PlatePainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GRASA',
                        style: AppText.labelSm(
                          color: AppColors.onSecondaryFixed,
                          size: 10,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const Icon(Symbols.water_drop,
                          size: 13, color: AppColors.onSecondaryFixed, fill: 1),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _legendTile(
                      AppColors.tertiary, '1/2 Fibra', _veggie.name),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _legendTile(
                      AppColors.primary, '1/4 Proteína', _protein.name,
                      labelColor: AppColors.primaryLight),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _legendTile(
                      AppColors.secondaryLight, '1/4 Carbos', _carb.name),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _summaryCard(),
      const SizedBox(height: 16),
      _foodGroup(
        dotColor: AppColors.primary,
        title: '1/4 Proteínas Magras',
        hint: 'Músculo & Saciedad',
        hintColor: AppColors.primaryLight,
        options: _optionsFor(FoodCategory.protein),
        selected: _protein,
        selectedBg: AppColors.primary,
        selectedFg: AppColors.onPrimary,
        onSelected: (f) => setState(() => _protein = f),
      ),
      const SizedBox(height: 12),
      _foodGroup(
        dotColor: AppColors.secondaryLight,
        title: '1/4 Carbohidratos Complejos',
        hint: 'Energía Sostenida',
        hintColor: AppColors.secondaryLight,
        options: _optionsFor(FoodCategory.carb),
        selected: _carb,
        selectedBg: AppColors.secondary,
        selectedFg: AppColors.onSecondaryContainer,
        onSelected: (f) => setState(() => _carb = f),
      ),
      const SizedBox(height: 12),
      _foodGroup(
        dotColor: AppColors.tertiary,
        title: '1/2 Vegetales & Fibra',
        hint: 'Micros & Digestión',
        hintColor: AppColors.tertiary,
        options: _optionsFor(FoodCategory.veggie),
        selected: _veggie,
        selectedBg: AppColors.tertiary,
        selectedFg: AppColors.onTertiary,
        onSelected: (f) => setState(() => _veggie = f),
      ),
      const SizedBox(height: 12),
      _foodGroup(
        dotColor: AppColors.secondaryFixed,
        title: 'Toque de Grasas Saludables',
        hint: 'Hormonas & Absorción',
        hintColor: AppColors.secondaryLight,
        options: _optionsFor(FoodCategory.fat),
        selected: _fat,
        selectedBg: AppColors.secondaryFixed,
        selectedFg: AppColors.onSecondaryFixed,
        onSelected: (f) => setState(() => _fat = f),
      ),
    ];
  }

  Widget _legendTile(Color dot, String label, String value,
      {Color? labelColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceHigh, 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceHighest),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppText.labelSm(
                    color: labelColor ?? dot,
                    size: 10,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.bodySm(),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return SurfaceCard(
      color: AppColors.surfaceHigh,
      borderColor: AppColors.surfaceHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.fade(AppColors.primary, 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Symbols.insights,
                    size: 20, color: AppColors.primaryLight),
              ),
              const SizedBox(width: 8),
              Text('Resumen Educativo', style: AppText.headlineSm()),
              const Spacer(),
              Pill(
                label: '$_totalCalories kcal',
                icon: Symbols.bolt,
                background: AppColors.surfaceHighest,
                foreground: AppColors.primaryLight,
                fontSize: 12,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: AppColors.onSurface, size: 12, height: 1.6),
              children: [
                const TextSpan(text: 'Tu plato contiene aprox. '),
                TextSpan(
                  text: '${_totalProtein}g proteína',
                  style: AppText.bodyMd(
                      color: AppColors.primary,
                      size: 12,
                      weight: FontWeight.w700),
                ),
                const TextSpan(text: ', '),
                TextSpan(
                  text: '${_totalCarbs}g carbohidratos',
                  style: AppText.bodyMd(
                      color: AppColors.secondaryLight,
                      size: 12,
                      weight: FontWeight.w700),
                ),
                const TextSpan(text: ' y '),
                TextSpan(
                  text: '${_totalFat}g grasas saludables',
                  style: AppText.bodyMd(
                      color: AppColors.secondary,
                      size: 12,
                      weight: FontWeight.w700),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderSoft),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Symbols.verified, size: 20, color: AppColors.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppText.bodySm(height: 1.6),
                      children: [
                        TextSpan(
                          text: 'Veredicto GymMate: ',
                          style: AppText.bodySm(
                            color: AppColors.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: _totalProtein >= 30
                              ? 'Distribución óptima para síntesis proteica y '
                                  'reposición glucogénica tras una sesión exigente '
                                  'de fuerza o hipertrofia.'
                              : 'Plato liviano y equilibrado, excelente para días '
                                  'de descanso activo o entrenamiento '
                                  'cardiovascular moderado.',
                        ),
                      ],
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

  Widget _foodGroup({
    required Color dotColor,
    required String title,
    required String hint,
    required Color hintColor,
    required List<FoodItem> options,
    required FoodItem selected,
    required Color selectedBg,
    required Color selectedFg,
    required ValueChanged<FoodItem> onSelected,
  }) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fade(dotColor, 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppText.headlineSm(size: 12)),
              ),
              Text(
                hint,
                style: AppText.labelSm(
                  color: hintColor,
                  size: 11,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((f) {
              final isSelected = selected.id == f.id;
              return GestureDetector(
                onTap: () => onSelected(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? selectedBg
                          : AppColors.surfaceHighest,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.fade(selectedBg, 0.3),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Symbols.check, size: 16, color: selectedFg),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        f.name,
                        style: AppText.labelMd(
                          color: isSelected ? selectedFg : AppColors.onSurface,
                          size: 12,
                          weight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- tab 2: aprende
  List<Widget> _learnTab() {
    return [
      Row(
        children: [
          const Icon(Symbols.bolt, size: 20, color: AppColors.secondaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Timing Estratégico: Antes y Después',
              style: AppText.headlineSm(size: 14),
            ),
          ),
          Text('Guía Rápida', style: AppText.labelSm(size: 12)),
        ],
      ),
      const SizedBox(height: 12),
      _timingCard(
        image: Assets.preWorkoutMeal,
        badgeLabel: '1 a 2 horas antes',
        badgeIcon: Symbols.schedule,
        badgeBg: AppColors.secondary,
        badgeFg: AppColors.onSecondaryContainer,
        title: 'Pre-Entreno',
        leadPlain: 'Tu prioridad es ',
        leadBold: 'energía disponible',
        leadRest: ' sin digestión pesada. Evita excesos de grasas o fibra '
            'densa justo antes de levantar peso.',
        bullets: const [
          _Bullet(
            icon: Symbols.check_circle,
            color: AppColors.secondaryLight,
            title: 'Opción Ligera (30-45 min antes)',
            body: 'Plátano maduro o dátil con un café solo o infusión.',
          ),
          _Bullet(
            icon: Symbols.check_circle,
            color: AppColors.secondaryLight,
            title: 'Comida Completa (90-120 min antes)',
            body: 'Avena cocida con scoop de proteína o tostadas integrales '
                'con pavo magro.',
          ),
        ],
      ),
      const SizedBox(height: 16),
      _timingCard(
        image: Assets.postWorkoutMeal,
        badgeLabel: 'Ventana de 1 a 3 horas',
        badgeIcon: Symbols.autorenew,
        badgeBg: AppColors.primary,
        badgeFg: AppColors.onPrimary,
        title: 'Post-Entreno',
        leadPlain: 'Tu objetivo principal es ',
        leadBold: 'reparación fibrilar y reponer glucógeno',
        leadRest: '. No necesitas correr en 15 minutos: la consistencia diaria '
            'del total de proteína importa más.',
        bullets: const [
          _Bullet(
            icon: Symbols.verified,
            color: AppColors.primaryLight,
            title: 'Proporción Dorada',
            body: 'Combina 25-40g de proteína de alto valor biológico + '
                'carbohidrato de asimilación media/rápida.',
          ),
          _Bullet(
            icon: Symbols.local_drink,
            color: AppColors.primaryLight,
            title: 'Hidratación y Electrolitos',
            body: 'Repón 500-750ml de agua por cada hora sudada; añade una '
                'pizca de sal marina si el entrenamiento fue intenso.',
          ),
        ],
      ),
    ];
  }

  Widget _timingCard({
    required String image,
    required String badgeLabel,
    required IconData badgeIcon,
    required Color badgeBg,
    required Color badgeFg,
    required String title,
    required String leadPlain,
    required String leadBold,
    required String leadRest,
    required List<_Bullet> bullets,
  }) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 144,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RemoteImage(url: image),
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
                  left: 16,
                  bottom: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 16, color: badgeFg),
                            const SizedBox(width: 4),
                            Text(
                              badgeLabel,
                              style: AppText.labelMd(
                                color: badgeFg,
                                size: 12,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(title, style: AppText.headlineSm()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppText.bodyMd(size: 12, height: 1.6),
                    children: [
                      TextSpan(text: leadPlain),
                      TextSpan(
                        text: leadBold,
                        style: AppText.bodyMd(
                          color: AppColors.onSurface,
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: leadRest),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...bullets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorderSoft),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(b.icon, size: 20, color: b.color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.title,
                                  style: AppText.labelMd(
                                    size: 12,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(b.body,
                                    style: AppText.bodySm(size: 11, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // ---------------------------------------------------------- tab 3: mitos
  List<Widget> _mythsTab() {
    return [
      Row(
        children: [
          const Icon(Symbols.balance, size: 20, color: AppColors.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mitos y Realidades Nutricionales',
              style: AppText.headlineSm(size: 14),
            ),
          ),
          const Pill(label: 'Basado en Ciencia', fontSize: 10),
        ],
      ),
      const SizedBox(height: 12),
      _mythAccordion(
        index: 1,
        icon: Symbols.nightlight,
        iconColor: AppColors.secondaryLight,
        question: '¿Los carbohidratos de noche engordan?',
        verdict: 'El reloj biológico no apaga las calorías',
        body: 'Tu cuerpo no almacena grasa automáticamente por ser de noche. '
            'Lo que determina el cambio de composición corporal es el balance '
            'energético total de las 24 horas y semanas completas. De hecho, '
            'cenar carbohidratos complejos puede mejorar la calidad del sueño '
            'profundo y la recuperación hormonal.',
      ),
      const SizedBox(height: 12),
      _mythAccordion(
        index: 2,
        icon: Symbols.fitness_center,
        iconColor: AppColors.primaryLight,
        question: '¿La proteína daña los riñones?',
        verdict: 'Completamente seguro en personas saludables',
        body: 'Décadas de investigación confirman que ingestas proteicas de '
            '1.6g a 2.2g por kg de peso en personas sanas que entrenan fuerza '
            'NO deterioran la función renal ni hepática. El riñón simplemente '
            'se adapta filtrando de forma eficiente. Solo personas con '
            'patologías preexistentes requieren supervisión médica.',
      ),
      const SizedBox(height: 12),
      _mythAccordion(
        index: 3,
        icon: Symbols.local_fire_department,
        iconColor: AppColors.tertiary,
        question: '¿Sudar más significa quemar más grasa?',
        verdict: 'Sudar es termorregulación, no lipólisis',
        body: 'El sudor es agua y minerales excretados para enfriar la '
            'temperatura corporal. Forzar la sudoración con fajas plásticas o '
            'exceso de ropa solo genera deshidratación celular, calambres y '
            'disminuye tu rendimiento de fuerza, sin acelerar la pérdida de '
            'tejido graso.',
      ),
    ];
  }

  Widget _mythAccordion({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String question,
    required String verdict,
    required String body,
  }) {
    final isOpen = _openAccordion == index;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _openAccordion = isOpen ? null : index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.fade(iconColor, 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: AppText.headlineSm(size: 14),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Symbols.expand_more,
                      color: isOpen
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.cardBorderSoft)),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Pill(
                          label: 'MITO',
                          background: AppColors.error,
                          foreground: AppColors.onError,
                          fontSize: 10,
                          bold: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            verdict,
                            style: AppText.labelMd(
                              size: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body, style: AppText.bodySm(height: 1.6)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceLowest, 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.info, size: 20, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppText.bodySm(
                    color: AppColors.outline, size: 11, height: 1.6),
                children: [
                  TextSpan(
                    text: 'Aviso educativo: ',
                    style: AppText.bodySm(
                      color: AppColors.onSurfaceVariant,
                      size: 11,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: 'GymMate promueve la educación alimentaria y hábitos '
                        'saludables sostenibles. La información y proporciones '
                        'ilustradas no constituyen una prescripción médica ni '
                        'reemplazan la consulta personalizada con un profesional '
                        'de la salud.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet {
  const _Bullet({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

/// Dibuja el plato circular: 50% vegetales, 25% carbos, 25% proteína
/// y un núcleo central de grasas (equivale al SVG del proyecto original).
class _PlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    // Base del plato
    canvas.drawCircle(center, 92 * scale, Paint()..color = AppColors.surfaceHigh);
    canvas.drawCircle(
        center, 86 * scale, Paint()..color = AppColors.surfaceLowest);

    final ringRect = Rect.fromCircle(center: center, radius: 68 * scale);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32 * scale;

    const start = -math.pi / 2; // arranca arriba, como el `-rotate-90` del SVG
    const full = math.pi * 2;

    // 50% vegetales
    canvas.drawArc(
      ringRect,
      start,
      full * 0.5,
      false,
      ringPaint..color = AppColors.tertiary,
    );
    // 25% carbohidratos
    canvas.drawArc(
      ringRect,
      start + full * 0.5,
      full * 0.25,
      false,
      ringPaint..color = AppColors.secondaryLight,
    );
    // 25% proteína
    canvas.drawArc(
      ringRect,
      start + full * 0.75,
      full * 0.25,
      false,
      ringPaint..color = AppColors.primary,
    );

    // Núcleo de grasas
    canvas.drawCircle(center, 18 * scale, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}