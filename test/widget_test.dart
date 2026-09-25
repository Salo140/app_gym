import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_pm/models/workout_plan.dart';
import 'package:proyecto_pm/screens/entrenar_screen.dart';
import 'package:proyecto_pm/screens/category_detail_screen.dart';
import 'package:proyecto_pm/screens/plan_form_screen.dart';
import 'package:proyecto_pm/screens/plan_summary_screen.dart';

void main() {
  testWidgets('integra planes dentro de Entrenar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EntrenarView(onTabSelected: _noop)),
      ),
    );
    await tester.pump();

    expect(find.text('Planes personalizados'), findsOneWidget);
    expect(find.text('Fuerza'), findsNWidgets(2));
    expect(find.text('Hipertrofia'), findsOneWidget);
  });

  testWidgets('muestra el detalle de una categoria', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CategoryDetailScreen(
          category: RoutineCategory(
            name: 'Fuerza',
            description: 'Aumenta tu fuerza base',
            icon: Icons.fitness_center,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Rutina recomendada'), findsOneWidget);
    expect(find.text('Sesion equilibrada'), findsOneWidget);
  });

  testWidgets('bloquea el formulario de planes si es invalido', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlanFormScreen()));
    await tester.pump();
    await tester.tap(find.text('Ver resumen'));
    await tester.pump();

    expect(find.text('Escribe al menos 3 caracteres'), findsOneWidget);
    expect(find.text('Selecciona un objetivo'), findsOneWidget);
    expect(find.text('Selecciona una frecuencia'), findsOneWidget);
    expect(find.text('Resumen del plan'), findsNothing);
  });

  testWidgets('el resumen recibe los datos del plan', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlanSummaryScreen(
          plan: WorkoutPlan(name: 'Plan fuerza', goal: 'Fuerza', days: 3),
        ),
      ),
    );

    expect(find.text('Plan fuerza'), findsOneWidget);
    expect(find.text('3 dias/semana'), findsOneWidget);
  });
}

void _noop(_) {}
