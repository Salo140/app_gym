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
