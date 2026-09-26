import 'package:flutter/material.dart';

class RoutineCategory {
  const RoutineCategory({
    required this.name,
    required this.description,
    required this.icon,
  });

  final String name;
  final String description;
  final IconData icon;
}

class CategoryDetailArguments {
  const CategoryDetailArguments({required this.category});

  final RoutineCategory category;
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.name,
    required this.goal,
    required this.days,
  });

  final String name;
  final String goal;
  final int days;
}

class PlanSummaryArguments {
  const PlanSummaryArguments({required this.plan});

  final WorkoutPlan plan;
}
