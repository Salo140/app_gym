import 'package:firebase_core/firebase_core.dart';

import '../../models/saved_workout.dart';
import '../../models/workout_plan.dart';
import '../local/workout_local_data_source.dart';

abstract interface class WorkoutCloudDataSource {
  Future<void> savePlan(SavedWorkoutPlan plan);
  Future<void> saveSession(SavedWorkoutSession session);
  Future<List<SavedWorkoutPlan>> fetchPlans(String ownerId);
  Future<List<SavedWorkoutSession>> fetchSessions(String ownerId);
}

enum CloudSyncStatus { synced, notConfigured, pending }

class SaveWorkoutResult {
  const SaveWorkoutResult({required this.syncStatus, this.syncError});

  final CloudSyncStatus syncStatus;
  final String? syncError;
}

class WorkoutRepository {
  WorkoutRepository({required this.localDataSource, this.cloudDataSource});

  final WorkoutLocalDataSource localDataSource;
  final WorkoutCloudDataSource? cloudDataSource;

  Future<SaveWorkoutResult> savePlan({
    required String ownerId,
    required WorkoutPlan plan,
  }) async {
    final savedPlan = SavedWorkoutPlan(
      id: '${ownerId}_${DateTime.now().microsecondsSinceEpoch}',
      ownerId: ownerId,
      plan: plan,
      createdAt: DateTime.now().toUtc(),
    );
    await localDataSource.savePlan(savedPlan, synced: false);
    return _syncPlan(savedPlan);
  }

  Future<List<SavedWorkoutPlan>> getPlans(String ownerId) =>
      localDataSource.getPlans(ownerId);

  Future<SaveWorkoutResult> saveSession(SavedWorkoutSession session) async {
    await localDataSource.saveSession(session, synced: false);
    final cloud = cloudDataSource;
    if (cloud == null) {
      return const SaveWorkoutResult(syncStatus: CloudSyncStatus.notConfigured);
    }
    try {
      await cloud.saveSession(session);
      await localDataSource.markSessionSynced(session.id, session.ownerId);
      return const SaveWorkoutResult(syncStatus: CloudSyncStatus.synced);
    } on FirebaseException catch (error) {
      return SaveWorkoutResult(
        syncStatus: CloudSyncStatus.pending,
        syncError: error.message ?? error.code,
      );
    }
  }

  Future<List<SavedWorkoutSession>> getSessions(String ownerId) =>
      localDataSource.getSessions(ownerId);

  Future<List<String>> refreshFromCloud(String ownerId) async {
    final cloud = cloudDataSource;
    if (cloud == null) return const [];
    try {
      final plans = await cloud.fetchPlans(ownerId);
      for (final plan in plans) {
        if (plan.ownerId != ownerId ||
            await localDataSource.hasPendingPlan(plan.id, ownerId)) {
          continue;
        }
        await localDataSource.savePlan(plan, synced: true);
      }
      final sessions = await cloud.fetchSessions(ownerId);
      for (final session in sessions) {
        if (session.ownerId != ownerId ||
            await localDataSource.hasPendingSession(session.id, ownerId)) {
          continue;
        }
        await localDataSource.saveSession(session, synced: true);
      }
      return const [];
    } on FirebaseException catch (error) {
      return [error.message ?? error.code];
    } on FormatException {
      return const [
        'Los datos guardados en la nube tienen un formato inválido.',
      ];
    }
  }

  Future<List<String>> syncPending(String ownerId) async {
    final cloud = cloudDataSource;
    if (cloud == null) return const [];
    final errors = <String>[];
    for (final plan in await localDataSource.getPendingPlans(ownerId)) {
      try {
        await cloud.savePlan(plan);
        await localDataSource.markPlanSynced(plan.id, ownerId);
      } on FirebaseException catch (error) {
        errors.add(error.message ?? error.code);
      }
    }
    for (final session in await localDataSource.getPendingSessions(ownerId)) {
      try {
        await cloud.saveSession(session);
        await localDataSource.markSessionSynced(session.id, ownerId);
      } on FirebaseException catch (error) {
        errors.add(error.message ?? error.code);
      }
    }
    return errors;
  }

  Future<String?> getPreference(String ownerId, String key) =>
      localDataSource.getPreference(ownerId, key);

  Future<void> setPreference(String ownerId, String key, String value) =>
      localDataSource.setPreference(ownerId, key, value);

  Future<SaveWorkoutResult> _syncPlan(SavedWorkoutPlan plan) async {
    final cloud = cloudDataSource;
    if (cloud == null) {
      return const SaveWorkoutResult(syncStatus: CloudSyncStatus.notConfigured);
    }
    try {
      await cloud.savePlan(plan);
      await localDataSource.markPlanSynced(plan.id, plan.ownerId);
      return const SaveWorkoutResult(syncStatus: CloudSyncStatus.synced);
    } on FirebaseException catch (error) {
      return SaveWorkoutResult(
        syncStatus: CloudSyncStatus.pending,
        syncError: error.message ?? error.code,
      );
    }
  }
}
