import 'package:sqflite/sqflite.dart';

import '../../models/saved_workout.dart';
import 'app_database.dart';
import 'workout_local_data_source.dart';

class SqliteWorkoutLocalDataSource implements WorkoutLocalDataSource {
  SqliteWorkoutLocalDataSource(this.database);

  final AppDatabase database;

  @override
  Future<void> savePlan(SavedWorkoutPlan plan, {required bool synced}) async {
    await database.database.insert('workout_plans', {
      ...plan.toMap(),
      'synced': synced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<SavedWorkoutPlan>> getPlans(String ownerId) async {
    final rows = await database.database.query(
      'workout_plans',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(SavedWorkoutPlan.fromMap).toList(growable: false);
  }

  @override
  Future<List<SavedWorkoutPlan>> getPendingPlans(String ownerId) async {
    final rows = await database.database.query(
      'workout_plans',
      where: 'owner_id = ? AND synced = 0',
      whereArgs: [ownerId],
      orderBy: 'created_at',
    );
    return rows.map(SavedWorkoutPlan.fromMap).toList(growable: false);
  }

  @override
  Future<bool> hasPendingPlan(String id, String ownerId) async =>
      _hasPending('workout_plans', id, ownerId);

  @override
  Future<void> markPlanSynced(String id, String ownerId) async {
    await database.database.update(
      'workout_plans',
      {'synced': 1},
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
    );
  }

  @override
  Future<void> saveSession(
    SavedWorkoutSession session, {
    required bool synced,
  }) async {
    await database.database.insert('workout_sessions', {
      ...session.toMap(),
      'synced': synced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<SavedWorkoutSession>> getSessions(String ownerId) async {
    final rows = await database.database.query(
      'workout_sessions',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(SavedWorkoutSession.fromMap).toList(growable: false);
  }

  @override
  Future<List<SavedWorkoutSession>> getPendingSessions(String ownerId) async {
    final rows = await database.database.query(
      'workout_sessions',
      where: 'owner_id = ? AND synced = 0',
      whereArgs: [ownerId],
      orderBy: 'completed_at',
    );
    return rows.map(SavedWorkoutSession.fromMap).toList(growable: false);
  }

  @override
  Future<bool> hasPendingSession(String id, String ownerId) async =>
      _hasPending('workout_sessions', id, ownerId);

  @override
  Future<void> markSessionSynced(String id, String ownerId) async {
    await database.database.update(
      'workout_sessions',
      {'synced': 1},
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
    );
  }

  @override
  Future<String?> getPreference(String ownerId, String key) async {
    final rows = await database.database.query(
      'preferences',
      columns: ['value'],
      where: 'owner_id = ? AND preference_key = ?',
      whereArgs: [ownerId, key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single['value']! as String;
  }

  @override
  Future<void> setPreference(String ownerId, String key, String value) async {
    await database.database.insert('preferences', {
      'owner_id': ownerId,
      'preference_key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> _hasPending(String table, String id, String ownerId) async {
    final rows = await database.database.query(
      table,
      columns: ['id'],
      where: 'id = ? AND owner_id = ? AND synced = 0',
      whereArgs: [id, ownerId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
