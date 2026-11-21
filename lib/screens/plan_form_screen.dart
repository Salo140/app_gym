import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/repositories/workout_repository.dart';
import '../models/workout_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import 'plan_summary_screen.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key, this.ownerId, this.workoutRepository});

  final String? ownerId;
  final WorkoutRepository? workoutRepository;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _goal;
  int? _days;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final plan = WorkoutPlan(
      name: _nameController.text.trim(),
      goal: _goal!,
      days: _days!,
    );
    SaveWorkoutResult? saveResult;
    try {
      final repository = widget.workoutRepository;
      final ownerId = widget.ownerId;
      if (repository != null && ownerId != null) {
        saveResult = await repository.savePlan(ownerId: ownerId, plan: plan);
      }
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar el plan en este dispositivo.'),
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanSummaryScreen(plan: plan, saveResult: saveResult),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Crear plan', style: AppText.headlineSm(size: 18)),
      ),
      body: ContentShell(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text('Diseña tu siguiente etapa', style: AppText.headlineMd()),
              const SizedBox(height: 6),
              Text(
                'Completa los datos para recibir un resumen personalizado.',
                style: AppText.bodySm(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del plan'),
                validator: (value) => value == null || value.trim().length < 3
                    ? 'Escribe al menos 3 caracteres'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                items: const [
                  DropdownMenuItem(value: 'Fuerza', child: Text('Fuerza')),
                  DropdownMenuItem(
                    value: 'Masa muscular',
                    child: Text('Masa muscular'),
                  ),
                  DropdownMenuItem(
                    value: 'Resistencia',
                    child: Text('Resistencia'),
                  ),
                ],
                onChanged: (value) => setState(() => _goal = value),
                validator: (value) =>
                    value == null ? 'Selecciona un objetivo' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _days,
                decoration: const InputDecoration(labelText: 'Dias por semana'),
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2 dias')),
                  DropdownMenuItem(value: 3, child: Text('3 dias')),
                  DropdownMenuItem(value: 4, child: Text('4 dias')),
                  DropdownMenuItem(value: 5, child: Text('5 dias')),
                ],
                onChanged: (value) => setState(() => _days = value),
                validator: (value) =>
                    value == null ? 'Selecciona una frecuencia' : null,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Ver resumen',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (!_isSaving) _submit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
