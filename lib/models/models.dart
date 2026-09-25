import 'package:flutter/widgets.dart' show IconData;

/// Equivalente a `src/types.ts`.

enum TabType { inicio, entrenar, nutriguia, progreso, perfil }

class ExerciseSet {
  ExerciseSet({
    required this.id,
    required this.type,
    required this.prevWeight,
    required this.prevReps,
    required this.weight,
    required this.reps,
    this.completed = false,
  });

  final int id;
  final String type; // 'Calent.' | 'Efectiva' | 'Fuerza' | 'Drop Set'
  final double prevWeight;
  final int prevReps;
  double weight;
  int reps;
  bool completed;
}

class ExerciseAlternative {
  const ExerciseAlternative({
    required this.name,
    required this.matchPercentage,
    required this.description,
    required this.suggestedLoad,
    required this.image,
  });

  final String name;
  final int matchPercentage;
  final String description;
  final String suggestedLoad;
  final String image;
}

class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.equipment,
    required this.image,
    required this.tip,
    required this.objectiveRPE,
    required this.sets,
    required this.alternatives,
  });

  final String id;
  String name;
  String targetMuscle;
  String equipment;
  String image;
  String tip;
  String objectiveRPE;
  List<ExerciseSet> sets;
  final List<ExerciseAlternative> alternatives;
}

enum FoodCategory { protein, carb, veggie, fat }

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.category,
  });

  final String id;
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;
  final FoodCategory category;
}

class PersonalRecord {
  const PersonalRecord({
    required this.id,
    required this.exercise,
    required this.weight,
    required this.repsOrNote,
    required this.diff,
    required this.icon,
    this.isNew = false,
  });

  final String id;
  final String exercise;
  final double weight;
  final String repsOrNote;
  final String diff;
  final IconData icon;
  final bool isNew;
}

class BadgeItem {
  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
    this.progressText,
    this.progressPercent,
  });

  final String id;
  final String title;
  final String description;
  final String icon; // emoji
  final bool completed;
  final String? progressText;
  final int? progressPercent;
}

class HistoryExercise {
  const HistoryExercise({required this.name, required this.details});

  final String name;
  final String details;
}

class WorkoutHistoryItem {
  const WorkoutHistoryItem({
    required this.id,
    required this.dateStr,
    required this.timeStr,
    required this.title,
    required this.durationMin,
    required this.totalSets,
    required this.volumeKg,
    required this.icon,
    required this.exercises,
  });

  final String id;
  final String dateStr;
  final String timeStr;
  final String title;
  final int durationMin;
  final int totalSets;
  final int volumeKg;
  final IconData icon;
  final List<HistoryExercise> exercises;
}