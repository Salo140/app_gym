import 'dart:convert';

import 'workout_plan.dart';

class SavedWorkoutSet {
  const SavedWorkoutSet({
    required this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  final String exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;

  Map<String, Object?> toMap() => {
    'exercise_name': exerciseName,
    'set_number': setNumber,
    'weight_kg': weightKg,
    'reps': reps,
  };

  factory SavedWorkoutSet.fromMap(Map<String, dynamic> map) => SavedWorkoutSet(
    exerciseName: map['exercise_name']! as String,
    setNumber: map['set_number']! as int,
    weightKg: (map['weight_kg']! as num).toDouble(),
    reps: map['reps']! as int,
  );
}

class SavedWorkoutPlan {
  const SavedWorkoutPlan({
    required this.id,
    required this.ownerId,
    required this.plan,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final WorkoutPlan plan;
  final DateTime createdAt;

  Map<String, Object?> toMap({bool includeSyncState = false}) => {
    'id': id,
    'owner_id': ownerId,
    'name': plan.name,
    'goal': plan.goal,
    'days': plan.days,
    'created_at': createdAt.toIso8601String(),
    if (includeSyncState) 'synced': 0,
  };

  factory SavedWorkoutPlan.fromMap(Map<String, Object?> map) {
    return SavedWorkoutPlan(
      id: map['id']! as String,
      ownerId: map['owner_id']! as String,
      plan: WorkoutPlan(
        name: map['name']! as String,
        goal: map['goal']! as String,
        days: map['days']! as int,
      ),
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

class SavedWorkoutSession {
  const SavedWorkoutSession({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.durationSeconds,
    required this.totalSets,
    required this.volumeKg,
    required this.completedAt,
    this.sets = const [],
  });

  final String id;
  final String ownerId;
  final String title;
  final int durationSeconds;
  final int totalSets;
  final double volumeKg;
  final DateTime completedAt;
  final List<SavedWorkoutSet> sets;

  Map<String, Object?> toMap({bool includeSyncState = false}) => {
    'id': id,
    'owner_id': ownerId,
    'title': title,
    'duration_seconds': durationSeconds,
    'total_sets': totalSets,
    'volume_kg': volumeKg,
    'completed_at': completedAt.toIso8601String(),
    'details_json': jsonEncode(sets.map((set) => set.toMap()).toList()),
    if (includeSyncState) 'synced': 0,
  };

  factory SavedWorkoutSession.fromMap(Map<String, Object?> map) {
    final details = jsonDecode(map['details_json'] as String? ?? '[]');
    return SavedWorkoutSession(
      id: map['id']! as String,
      ownerId: map['owner_id']! as String,
      title: map['title']! as String,
      durationSeconds: map['duration_seconds']! as int,
      totalSets: map['total_sets']! as int,
      volumeKg: (map['volume_kg']! as num).toDouble(),
      completedAt: DateTime.parse(map['completed_at']! as String),
      sets: details is List
          ? details
                .whereType<Map<String, dynamic>>()
                .map(SavedWorkoutSet.fromMap)
                .toList(growable: false)
          : const [],
    );
  }
}
