import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._(this.database);

  factory AppDatabase.forTesting(Database database) => AppDatabase._(database);

  final Database database;

  static Future<AppDatabase> open() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'gymmate.db'),
      version: 2,
      onCreate: (db, version) => createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE workout_sessions ADD COLUMN details_json TEXT NOT NULL DEFAULT '[]'",
          );
        }
      },
    );
    return AppDatabase._(database);
  }

  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
          CREATE TABLE workout_plans (
            id TEXT PRIMARY KEY,
            owner_id TEXT NOT NULL,
            name TEXT NOT NULL,
            goal TEXT NOT NULL,
            days INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
    await db.execute('''
          CREATE TABLE workout_sessions (
            id TEXT PRIMARY KEY,
            owner_id TEXT NOT NULL,
            title TEXT NOT NULL,
            duration_seconds INTEGER NOT NULL,
            total_sets INTEGER NOT NULL,
            volume_kg REAL NOT NULL,
            completed_at TEXT NOT NULL,
            details_json TEXT NOT NULL DEFAULT '[]',
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
    await db.execute('''
          CREATE TABLE api_cache (
            cache_key TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            saved_at TEXT NOT NULL
          )
        ''');
    await db.execute('''
          CREATE TABLE preferences (
            owner_id TEXT NOT NULL,
            preference_key TEXT NOT NULL,
            value TEXT NOT NULL,
            PRIMARY KEY (owner_id, preference_key)
          )
        ''');
    await db.execute(
      'CREATE INDEX workout_plans_owner ON workout_plans(owner_id)',
    );
    await db.execute(
      'CREATE INDEX workout_sessions_owner ON workout_sessions(owner_id)',
    );
  }
}
