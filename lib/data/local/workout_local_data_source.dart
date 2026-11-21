import '../../models/saved_workout.dart';

abstract interface class WorkoutLocalDataSource {
  Future<void> savePlan(SavedWorkoutPlan plan, {required bool synced});
  Future<List<SavedWorkoutPlan>> getPlans(String ownerId);
  Future<List<SavedWorkoutPlan>> getPendingPlans(String ownerId);
  Future<bool> hasPendingPlan(String id, String ownerId);
  Future<void> markPlanSynced(String id, String ownerId);
  Future<void> saveSession(SavedWorkoutSession session, {required bool synced});
  Future<List<SavedWorkoutSession>> getSessions(String ownerId);
  Future<List<SavedWorkoutSession>> getPendingSessions(String ownerId);
  Future<bool> hasPendingSession(String id, String ownerId);
  Future<void> markSessionSynced(String id, String ownerId);
  Future<String?> getPreference(String ownerId, String key);
  Future<void> setPreference(String ownerId, String key, String value);
}
