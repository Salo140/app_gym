import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/plan_components.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Resumen del plan', style: AppText.headlineSm(size: 18)),
      ),
      body: ContentShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(plan.name, style: AppText.headlineLg()),
            const SizedBox(height: 6),
            Text('Tu plan esta listo para empezar.', style: AppText.bodySm()),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatChip(label: 'objetivo', value: plan.goal),
                StatChip(label: 'dias/semana', value: '${plan.days}'),
              ],
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Text(
                'Comenzaras con sesiones progresivas y descansos planificados. '
                'Podras ajustar este plan desde tu historial.',
                style: AppText.bodyMd(color: AppColors.onSurface),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Volver a entrenar',
              icon: Icons.fitness_center,
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
