import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/plan_components.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.category});

  final RoutineCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category.name, style: AppText.headlineSm(size: 18)),
      ),
      body: ContentShell(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FeatureCard(
              title: category.name,
              subtitle: category.description,
              icon: category.icon,
              onTap: () {},
            ),
            const SizedBox(height: 18),
            Text('Rutina recomendada', style: AppText.headlineSm(size: 17)),
            const SizedBox(height: 8),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sesion equilibrada',
                    style: AppText.bodyMd(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '45 minutos · 6 ejercicios · nivel intermedio',
                    style: AppText.bodySm(),
                  ),
                ],
              ),
            ),
            SurfaceCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Frecuencia sugerida: 3 dias por semana',
                      style: AppText.bodySm(color: AppColors.onSurface),
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
}
