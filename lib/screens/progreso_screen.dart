import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

enum _Period { semanal, mensual, historico }

class _DayBar {
  const _DayBar({
    required this.label,
    required this.heightFactor,
    required this.feedback,
    this.valueLabel,
    this.color,
    this.highlighted = false,
    this.rest = false,
  });

  final String label;
  final double heightFactor;
  final String feedback;
  final String? valueLabel;
  final Color? color;
  final bool highlighted;
  final bool rest;
}

/// Equivale a `ProgresoView.tsx`.
class ProgresoView extends StatefulWidget {
  const ProgresoView({super.key});

  @override
  State<ProgresoView> createState() => _ProgresoViewState();
}

class _ProgresoViewState extends State<ProgresoView> {
  _Period _period = _Period.semanal;
  String _feedback = 'Toca un día para ver distribución y foco muscular';
  final Map<String, bool> _openSessions = {'hist-1': true};

  static const List<_DayBar> _bars = [
    _DayBar(
      label: 'L',
      heightFactor: 0.82,
      valueLabel: '2.8k',
      color: AppColors.primaryLight,
      feedback: 'Lunes: 2,850 kg (Empuje: Press Banca & Deltoides)',
    ),
    _DayBar(
      label: 'M',
      heightFactor: 0.56,
      valueLabel: '1.9k',
      color: AppColors.tertiaryDim,
      feedback: 'Martes: 1,920 kg (Tirón: Dominadas & Remo Pendlay)',
    ),
    _DayBar(
      label: 'X',
      heightFactor: 0.10,
      rest: true,
      feedback: 'Miércoles: Descanso Activo / Movilidad y Cardio suave',
    ),
    _DayBar(
      label: 'J',
      heightFactor: 1.0,
      valueLabel: '3.5k',
      color: AppColors.primary,
      highlighted: true,
      feedback: 'Jueves: 3,450 kg (Pierna: Sentadilla 110kg & Prensa 180kg)',
    ),
    _DayBar(
      label: 'V',
      heightFactor: 0.68,
      valueLabel: '2.3k',
      color: AppColors.tertiary,
      feedback: 'Viernes: 2,300 kg (Torso Híbrido & Brazos)',
    ),
    _DayBar(
      label: 'S',
      heightFactor: 0.52,
      valueLabel: '1.8k',
      color: AppColors.tertiaryDim,
      feedback: 'Sábado: 1,800 kg (Glúteo & Isquiotibiales)',
    ),
    _DayBar(
      label: 'D',
      heightFactor: 0.06,
      rest: true,
      feedback: 'Domingo: Descanso Programado y Recarga Nutricional',
    ),
  ];

  void _selectPeriod(_Period p) {
    setState(() {
      _period = p;
      switch (p) {
        case _Period.semanal:
          _feedback =
              'Semana actual: 14,320 kg acumulados en 5 sesiones activas';
          break;
        case _Period.mensual:
          _feedback =
              'Mes en curso: 58,400 kg totales levantados (+20% vs mes anterior)';
          break;
        case _Period.historico:
          _feedback =
              'Histórico total: 248,150 kg registrados con 94% de constancia';
          break;
      }
    });
  }

  void _toggleAllSessions() {
    final anyClosed =
        kWorkoutHistory.any((item) => _openSessions[item.id] != true);
    setState(() {
      for (final item in kWorkoutHistory) {
        _openSessions[item.id] = anyClosed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentShell(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          topInset(context) + 8,
          20,
          bottomInset(context),
        ),
        children: [
          _header(),
          const SizedBox(height: 16),
          _keyMetrics(),
          const SizedBox(height: 16),
          _volumeChart(),
          const SizedBox(height: 16),
          _personalRecords(),
          const SizedBox(height: 16),
          _badges(),
          const SizedBox(height: 16),
          _history(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Compartir Resumen de Medallas',
            icon: Symbols.share,
            onPressed: _openShareDialog,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- header
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVOLUCIÓN ATLÉTICA',
                    style: AppText.labelSm(
                      color: AppColors.primaryLight,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Mi Progreso y Constancia',
                      style: AppText.headlineMd()),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceHighest),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fade(AppColors.primary, 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Symbols.trending_up,
                  size: 24, color: AppColors.primaryLight),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.cardBorderSoft),
          ),
          child: Row(
            children: [
              _periodButton(_Period.semanal, 'Semanal'),
              _periodButton(_Period.mensual, 'Mensual'),
              _periodButton(_Period.historico, 'Histórico'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodButton(_Period p, String label) {
    final selected = _period == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectPeriod(p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.fade(AppColors.primary, 0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppText.labelMd(
              color:
                  selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------- métricas clave
  Widget _keyMetrics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _metricCard(
            icon: Symbols.fitness_center,
            iconColor: AppColors.primaryLight,
            tag: '+20%',
            tagColor: AppColors.primaryLight,
            value: '18',
            label: 'Sesiones',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            icon: Symbols.calendar_month,
            iconColor: AppColors.tertiary,
            tag: 'Top',
            tagColor: AppColors.tertiary,
            value: '94%',
            label: 'Asistencia',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            icon: Symbols.military_tech,
            iconColor: AppColors.secondaryLight,
            tag: 'Nuevos',
            tagColor: AppColors.secondaryLight,
            value: '4 PRs',
            label: 'Superados',
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String tag,
    required Color tagColor,
    required String value,
    required String label,
  }) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: iconColor),
              Flexible(
                child: Pill(
                  label: tag,
                  background: AppColors.fade(tagColor, 0.15),
                  foreground: tagColor,
                  fontSize: 10,
                  bold: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppText.metric(size: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppText.labelSm(size: 11, letterSpacing: 0)),
        ],
      ),
    );
  }

  // --------------------------------------------------------- gráfico barras
  Widget _volumeChart() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Volumen de Carga',
                        style: AppText.headlineSm(size: 14)),
                    RichText(
                      text: TextSpan(
                        style: AppText.bodySm(),
                        children: [
                          const TextSpan(text: 'Total acumulado: '),
                          TextSpan(
                            text: '14,320 kg',
                            style: AppText.bodySm(
                              color: AppColors.primary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.surfaceHighest),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulseDot(size: 8),
                    const SizedBox(width: 6),
                    Text('Semana en Curso', style: AppText.labelSm(size: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 176,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (_) => Container(
                      height: 1,
                      color: AppColors.fade(AppColors.onSurfaceVariant, 0.15),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _bars.map(_buildBar).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.surfaceHigh, 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Symbols.analytics,
                    size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _feedback,
                    style: AppText.bodySm(color: AppColors.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('Detalle', style: AppText.labelSm(size: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(_DayBar bar) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _feedback = bar.feedback),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (bar.valueLabel != null)
                Text(
                  bar.valueLabel!,
                  style: AppText.labelSm(
                    color: bar.color ?? AppColors.onSurfaceVariant,
                    size: 10,
                    weight: bar.highlighted ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                height: 132,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 132 * bar.heightFactor,
                    child: Container(
                          decoration: BoxDecoration(
                            color: bar.rest
                                ? AppColors.fade(AppColors.surfaceHigh, 0.4)
                                : bar.color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            border: bar.highlighted
                                ? Border.all(color: AppColors.primary)
                                : bar.rest
                                    ? const Border(
                                        top: BorderSide(
                                            color: AppColors.surfaceHighest),
                                      )
                                    : null,
                            boxShadow: bar.rest || bar.color == null
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.fade(bar.color!, 0.45),
                                      blurRadius: bar.highlighted ? 16 : 10,
                                    ),
                                  ],
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: bar.rest ? 0.5 : 1,
                child: Text(
                  bar.label,
                  style: AppText.labelSm(
                    color: bar.highlighted
                        ? AppColors.primary
                        : (bar.valueLabel != null && bar.label == 'L'
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant),
                    size: 12,
                    weight: bar.highlighted ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ PRs
  Widget _personalRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.emoji_events,
                size: 22, color: AppColors.secondaryLight),
            const SizedBox(width: 8),
            Text('Marcas Personales (PRs)',
                style: AppText.headlineSm(size: 14)),
            const Spacer(),
            Text(
              'Últimos 30 días',
              style: AppText.labelSm(
                  color: AppColors.primaryLight, size: 12, letterSpacing: 0),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...kPersonalRecords.map(_prCard),
      ],
    );
  }

  Widget _prCard(PersonalRecord pr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorderSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (pr.isNew) Container(width: 6, color: AppColors.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                        child: Icon(pr.icon,
                            size: 24, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    pr.exercise,
                                    style: AppText.bodyMd(
                                      color: AppColors.onSurface,
                                      weight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (pr.isNew) ...[
                                  const SizedBox(width: 6),
                                  Pill(
                                    label: 'NUEVO PR',
                                    icon: Symbols.verified,
                                    background: AppColors.fade(
                                        AppColors.secondary, 0.2),
                                    foreground: AppColors.secondaryLight,
                                    borderColor: AppColors.fade(
                                        AppColors.secondary, 0.3),
                                    fontSize: 10,
                                    bold: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pr.repsOrNote,
                              style: AppText.bodySm(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppText.metric(size: 18),
                              children: [
                                TextSpan(
                                    text: pr.weight.toStringAsFixed(0)),
                                TextSpan(
                                  text: ' kg',
                                  style: AppText.bodySm(),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            pr.diff,
                            style: AppText.labelSm(
                              color: AppColors.primaryLight,
                              size: 12,
                              weight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- badges
  Widget _badges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.workspace_premium,
                size: 22, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            Text('Insignias y Retos', style: AppText.headlineSm(size: 14)),
            const Spacer(),
            Pill(
              label: '3 / 4 Desbloqueadas',
              background: AppColors.fade(AppColors.primary, 0.15),
              foreground: AppColors.primaryLight,
              fontSize: 12,
              bold: true,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...kBadges.map(_badgeCard),
      ],
    );
  }

  Widget _badgeCard(BadgeItem badge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.cardBorderSoft,
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceHighest),
                      ),
                      child: Text(badge.icon,
                          style: const TextStyle(fontSize: 22)),
                    ),
                    if (badge.completed)
                      const Positioned(
                        bottom: -4,
                        right: -4,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: AppColors.background,
                          child: Icon(Symbols.check_circle,
                              size: 16, color: AppColors.primary, fill: 1),
                        ),
                      ),
                  ],
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
                              badge.title,
                              style: AppText.bodyMd(
                                color: AppColors.onSurface,
                                weight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            badge.completed
                                ? 'Completado ✓'
                                : (badge.progressText ?? ''),
                            style: AppText.labelSm(
                              color: badge.completed
                                  ? AppColors.primaryLight
                                  : AppColors.secondaryLight,
                              size: 11,
                              weight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badge.description,
                        style: AppText.bodySm(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!badge.completed && badge.progressPercent != null) ...[
              const SizedBox(height: 8),
              ProgressBar(
                value: badge.progressPercent! / 100,
                glow: false,
                background: AppColors.surfaceHigh,
                gradient: const LinearGradient(
                  colors: [AppColors.secondaryLight, AppColors.primary],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- historial
  Widget _history() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.history, size: 22, color: AppColors.tertiary),
            const SizedBox(width: 8),
            Text('Historial de Sesiones',
                style: AppText.headlineSm(size: 14)),
            const Spacer(),
            InkWell(
              onTap: _toggleAllSessions,
              child: Text(
                'Alternar Todo',
                style: AppText.labelSm(
                  color: AppColors.primary,
                  size: 12,
                  weight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...kWorkoutHistory.map(_historyCard),
      ],
    );
  }

  Widget _historyCard(WorkoutHistoryItem item) {
    final isOpen = _openSessions[item.id] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        borderColor: AppColors.cardBorderSoft,
        clip: true,
        child: Column(
          children: [
            InkWell(
              onTap: () =>
                  setState(() => _openSessions[item.id] = !isOpen),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceHighest),
                      ),
                      child: Icon(item.icon,
                          size: 20, color: AppColors.primaryLight),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.dateStr} • ${item.timeStr}',
                            style: AppText.labelSm(
                              color: AppColors.primaryLight,
                              size: 11,
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            item.title,
                            style: AppText.bodyMd(
                              color: AppColors.onSurface,
                              weight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.durationMin} min',
                            style: AppText.metric(
                                size: 12, weight: FontWeight.w600)),
                        Text('${item.totalSets} series',
                            style: AppText.labelSm(size: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Symbols.expand_more,
                        size: 20,
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLow,
                  border:
                      Border(top: BorderSide(color: AppColors.cardBorderSoft)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorderSoft),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _miniStat('Tiempo', '${item.durationMin} min'),
                          ),
                          Expanded(
                            child: _miniStat('Series', '${item.totalSets} tot.'),
                          ),
                          Expanded(
                            child: _miniStat(
                              'Volumen',
                              '${_thousands(item.volumeKg)} kg',
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...item.exercises.map(
                      (ex) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ex.name,
                                style: AppText.bodySm(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ex.details,
                              style: AppText.metric(
                                  size: 12, weight: FontWeight.w600),
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
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: AppText.labelSm(size: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppText.metric(
            color: color ?? AppColors.onSurface,
            size: 12,
          ),
        ),
      ],
    );
  }

  String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ---------------------------------------------------------- compartir
  void _openShareDialog() {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.fade(AppColors.primary, 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Symbols.military_tech,
                    size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('Tarjeta Atlética GymMate',
                  style: AppText.headlineMd(size: 18)),
              const SizedBox(height: 6),
              Text(
                '¡Carlos lleva 4 días de racha, 14,320 kg acumulados esta '
                'semana y 3 insignias completadas!',
                textAlign: TextAlign.center,
                style: AppText.bodySm(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceHighest),
                ),
                child: Column(
                  children: [
                    _shareRow('Atleta:', 'Carlos (Intermedio)',
                        AppColors.onSurface),
                    const SizedBox(height: 8),
                    _shareRow('Récord reciente:', 'Press de Banca 85 kg',
                        AppColors.primary),
                    const SizedBox(height: 8),
                    _shareRow('Constancia:', '94% Asistencia',
                        AppColors.secondaryLight),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _dialogButton(
                      label: 'Cerrar',
                      background: AppColors.surfaceHigh,
                      foreground: AppColors.onSurfaceVariant,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dialogButton(
                      label: 'Copiar Enlace',
                      background: AppColors.primary,
                      foreground: AppColors.onPrimary,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        showGymToast(
                          context,
                          '¡Tarjeta de medallas copiada al portapapeles!',
                          icon: Symbols.check_circle,
                          duration: const Duration(milliseconds: 2500),
                        );
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

  Widget _shareRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.bodySm()),
        Text(
          value,
          style: AppText.bodySm(color: valueColor, weight: FontWeight.w700),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
}