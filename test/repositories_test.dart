import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proyecto_pm/data/local/app_database.dart';
import 'package:proyecto_pm/data/local/sqlite_workout_data_source.dart';
import 'package:proyecto_pm/data/repositories/nutrition_repository.dart';
import 'package:proyecto_pm/data/repositories/workout_repository.dart';
import 'package:proyecto_pm/models/saved_workout.dart';
import 'package:proyecto_pm/models/workout_plan.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database rawDatabase;
  late AppDatabase appDatabase;
  late WorkoutRepository workoutRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    rawDatabase = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) => AppDatabase.createSchema(database),
      ),
    );
    appDatabase = AppDatabase.forTesting(rawDatabase);
    workoutRepository = WorkoutRepository(
      localDataSource: SqliteWorkoutLocalDataSource(appDatabase),
    );
  });

  tearDown(() => rawDatabase.close());

  test(
    'plans and preferences are isolated by account and persist locally',
    () async {
      final result = await workoutRepository.savePlan(
        ownerId: 'user-a',
        plan: const WorkoutPlan(name: 'Fuerza', goal: 'Fuerza', days: 3),
      );
      await workoutRepository.savePlan(
        ownerId: 'user-b',
        plan: const WorkoutPlan(
          name: 'Resistencia',
          goal: 'Resistencia',
          days: 4,
        ),
      );
      await workoutRepository.setPreference('user-a', 'water_litres', '2.25');

      expect(result.syncStatus, CloudSyncStatus.notConfigured);
      expect(await workoutRepository.getPlans('user-a'), hasLength(1));
      expect(
        (await workoutRepository.getPlans('user-a')).single.plan.name,
        'Fuerza',
      );
      expect(await workoutRepository.getPlans('user-b'), hasLength(1));
      expect(
        await workoutRepository.getPreference('user-a', 'water_litres'),
        '2.25',
      );
      expect(
        await workoutRepository.getPreference('user-b', 'water_litres'),
        isNull,
      );
    },
  );

  test('stores completed workout and its set details', () async {
    final session = SavedWorkoutSession(
      id: 'user-a_session-1',
      ownerId: 'user-a',
      title: 'Press de banca',
      durationSeconds: 1200,
      totalSets: 1,
      volumeKg: 640,
      completedAt: DateTime.utc(2026, 11, 20),
      sets: const [
        SavedWorkoutSet(
          exerciseName: 'Press de banca',
          setNumber: 1,
          weightKg: 80,
          reps: 8,
        ),
      ],
    );

    final result = await workoutRepository.saveSession(session);
    final saved = (await workoutRepository.getSessions('user-a')).single;

    expect(result.syncStatus, CloudSyncStatus.notConfigured);
    expect(saved.title, 'Press de banca');
    expect(saved.sets.single.weightKg, 80);
    expect(saved.sets.single.reps, 8);
    expect(await workoutRepository.getSessions('user-b'), isEmpty);
  });

  test('keeps offline saves pending and syncs them on a later retry', () async {
    final cloud = _MemoryWorkoutCloudDataSource()..failWrites = true;
    final repository = WorkoutRepository(
      localDataSource: SqliteWorkoutLocalDataSource(appDatabase),
      cloudDataSource: cloud,
    );
    final result = await repository.savePlan(
      ownerId: 'user-a',
      plan: const WorkoutPlan(name: 'Plan offline', goal: 'Fuerza', days: 3),
    );
    expect(result.syncStatus, CloudSyncStatus.pending);
    expect(await repository.getPlans('user-a'), hasLength(1));

    cloud.failWrites = false;
    expect(await repository.syncPending('user-a'), isEmpty);
    expect(cloud.plans, hasLength(1));

    final secondDatabase = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) => AppDatabase.createSchema(database),
      ),
    );
    addTearDown(secondDatabase.close);
    final secondRepository = WorkoutRepository(
      localDataSource: SqliteWorkoutLocalDataSource(
        AppDatabase.forTesting(secondDatabase),
      ),
      cloudDataSource: cloud,
    );
    expect(await secondRepository.refreshFromCloud('user-a'), isEmpty);
    expect(
      (await secondRepository.getPlans('user-a')).single.plan.name,
      'Plan offline',
    );
  });

  test(
    'uses Open Food Facts and falls back to the cached response offline',
    () async {
      final onlineClient = MockClient(
        (_) async => http.Response('''
        {"products":[{"product_name":"Avena","brands":"Marca","nutriments":{
          "proteins_100g":12,"carbohydrates_100g":60,"fat_100g":7,
          "energy-kcal_100g":370
        }}]}
        ''', 200),
      );
      final onlineRepository = NutritionRepository(
        database: appDatabase,
        client: onlineClient,
      );
      final onlineResult = await onlineRepository.searchFoods('avena');
      onlineRepository.close();

      final offlineRepository = NutritionRepository(
        database: appDatabase,
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      final offlineResult = await offlineRepository.searchFoods('AVENA');
      offlineRepository.close();

      expect(onlineResult.isCached, isFalse);
      expect(offlineResult.isCached, isTrue);
      expect(offlineResult.foods.single.name, 'Avena');
      expect(offlineResult.foods.single.calories, 370);
    },
  );

  test(
    'uses the cached food result when the API returns an error status',
    () async {
      var requestCount = 0;
      final repository = NutritionRepository(
        database: appDatabase,
        client: MockClient((_) async {
          requestCount += 1;
          if (requestCount > 1) return http.Response('unavailable', 503);
          return http.Response('''
        {"products":[{"product_name":"Lentejas","nutriments":{
          "proteins_100g":9,"carbohydrates_100g":20,"fat_100g":1,
          "energy-kcal_100g":116
        }}]}
        ''', 200);
        }),
      );

      await repository.searchFoods('lentejas');
      final result = await repository.searchFoods('lentejas');
      repository.close();

      expect(result.isCached, isTrue);
      expect(result.foods.single.name, 'Lentejas');
    },
  );
}

class _MemoryWorkoutCloudDataSource implements WorkoutCloudDataSource {
  final Map<String, SavedWorkoutPlan> plans = {};
  final Map<String, SavedWorkoutSession> sessions = {};
  bool failWrites = false;

  void _ensureOnline() {
    if (failWrites) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'offline',
      );
    }
  }

  @override
  Future<void> savePlan(SavedWorkoutPlan plan) async {
    _ensureOnline();
    plans[plan.id] = plan;
  }

  @override
  Future<void> saveSession(SavedWorkoutSession session) async {
    _ensureOnline();
    sessions[session.id] = session;
  }

  @override
  Future<List<SavedWorkoutPlan>> fetchPlans(String ownerId) async =>
      plans.values.where((plan) => plan.ownerId == ownerId).toList();

  @override
  Future<List<SavedWorkoutSession>> fetchSessions(String ownerId) async =>
      sessions.values.where((session) => session.ownerId == ownerId).toList();
}
