import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/saved_workout.dart';
import '../repositories/workout_repository.dart';

class FirestoreWorkoutDataSource implements WorkoutCloudDataSource {
  FirestoreWorkoutDataSource(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<void> savePlan(SavedWorkoutPlan plan) => firestore
      .collection('users')
      .doc(plan.ownerId)
      .collection('plans')
      .doc(plan.id)
      .set(plan.toMap());

  @override
  Future<void> saveSession(SavedWorkoutSession session) => firestore
      .collection('users')
      .doc(session.ownerId)
      .collection('sessions')
      .doc(session.id)
      .set(session.toMap());

  @override
  Future<List<SavedWorkoutPlan>> fetchPlans(String ownerId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(ownerId)
        .collection('plans')
        .get();
    return snapshot.docs
        .map((document) => SavedWorkoutPlan.fromMap(document.data()))
        .where((plan) => plan.ownerId == ownerId)
        .toList(growable: false);
  }

  @override
  Future<List<SavedWorkoutSession>> fetchSessions(String ownerId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(ownerId)
        .collection('sessions')
        .get();
    return snapshot.docs
        .map((document) => SavedWorkoutSession.fromMap(document.data()))
        .where((session) => session.ownerId == ownerId)
        .toList(growable: false);
  }
}
