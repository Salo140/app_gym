import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/local/app_database.dart';
import 'data/local/sqlite_workout_data_source.dart';
import 'data/remote/firebase_configuration.dart';
import 'data/remote/firestore_workout_data_source.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/local_notification_service.dart';
import 'data/repositories/nutrition_repository.dart';
import 'data/repositories/profile_image_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'models/models.dart';
import 'theme/app_colors.dart';
import 'theme/app_text.dart';
import 'screens/entrenar_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nutriguia_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/progreso_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  final database = await AppDatabase.open();
  final firebaseOptions = FirebaseConfiguration.options;
  final firebaseApp = firebaseOptions == null
      ? null
      : await Firebase.initializeApp(options: firebaseOptions);
  final authRepository = firebaseApp == null
      ? DemoAuthRepository()
      : FirebaseAuthRepository(FirebaseAuth.instanceFor(app: firebaseApp));
  final workoutRepository = WorkoutRepository(
    localDataSource: SqliteWorkoutLocalDataSource(database),
    cloudDataSource: firebaseApp == null
        ? null
        : FirestoreWorkoutDataSource(
            FirebaseFirestore.instanceFor(app: firebaseApp),
          ),
  );
  final profileImageRepository =
      firebaseApp == null || firebaseOptions?.storageBucket == null
      ? const ProfileImageRepository()
      : ProfileImageRepository(
          storage: FirebaseStorage.instanceFor(app: firebaseApp),
        );
  runApp(
    GymMateApp(
      authRepository: authRepository,
      workoutRepository: workoutRepository,
      nutritionRepository: NutritionRepository(database: database),
      profileImageRepository: profileImageRepository,
      notificationService: LocalNotificationService(),
    ),
  );
}

class GymMateApp extends StatelessWidget {
  const GymMateApp({
    super.key,
    required this.authRepository,
    required this.workoutRepository,
    required this.nutritionRepository,
    required this.profileImageRepository,
    required this.notificationService,
  });

  final AuthRepository authRepository;
  final WorkoutRepository workoutRepository;
  final NutritionRepository nutritionRepository;
  final ProfileImageRepository profileImageRepository;
  final LocalNotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'GymMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          surface: AppColors.background,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
          onError: AppColors.onError,
        ),
        splashFactory: InkRipple.splashFactory,
        textTheme: TextTheme(
          bodyMedium: AppText.bodyMd(color: AppColors.onSurface),
        ),
      ),
      home: authRepository.hasSession
          ? AppShell(
              authRepository: authRepository,
              workoutRepository: workoutRepository,
              nutritionRepository: nutritionRepository,
              profileImageRepository: profileImageRepository,
              notificationService: notificationService,
            )
          : LoginScreen(
              onLogin: (_) {},
              authRepository: authRepository,
              onAuthenticated: (context) =>
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => AppShell(
                        authRepository: authRepository,
                        workoutRepository: workoutRepository,
                        nutritionRepository: nutritionRepository,
                        profileImageRepository: profileImageRepository,
                        notificationService: notificationService,
                      ),
                    ),
                  ),
            ),
    );
  }
}

/// Contenedor principal: mantiene el estado compartido (pestaña activa,
/// racha e hidratación) igual que `App.tsx`.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authRepository,
    required this.workoutRepository,
    required this.nutritionRepository,
    required this.profileImageRepository,
    required this.notificationService,
  });

  final AuthRepository authRepository;
  final WorkoutRepository workoutRepository;
  final NutritionRepository nutritionRepository;
  final ProfileImageRepository profileImageRepository;
  final LocalNotificationService notificationService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  TabType _activeTab = TabType.inicio;
  int _streakDays = 0;
  double _waterLitres = 0;

  @override
  void initState() {
    super.initState();
    _loadWater();
    _loadStreak();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPending());
  }

  Future<void> _syncPending() async {
    try {
      final ownerId = widget.authRepository.userId;
      final errors = await widget.workoutRepository.syncPending(ownerId);
      errors.addAll(await widget.workoutRepository.refreshFromCloud(ownerId));
      if (errors.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Algunos datos siguen pendientes de sincronización: ${errors.first}',
            ),
          ),
        );
      }
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo leer la cola local de sincronización.'),
          ),
        );
      }
    }
  }

  Future<void> _loadWater() async {
    try {
      final value = await widget.workoutRepository.getPreference(
        widget.authRepository.userId,
        'water_litres',
      );
      if (value == null || !mounted) return;
      final litres = double.tryParse(value);
      if (litres == null || litres < 0 || litres > 4) return;
      setState(() => _waterLitres = litres);
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo leer el almacenamiento local.'),
          ),
        );
      }
    }
  }

  Future<void> _loadStreak() async {
    try {
      final sessions = await widget.workoutRepository.getSessions(
        widget.authRepository.userId,
      );
      final sessionDays = sessions
          .map((session) {
            final date = session.completedAt.toLocal();
            return DateTime(date.year, date.month, date.day);
          })
          .toSet();
      final now = DateTime.now();
      var day = DateTime(now.year, now.month, now.day);
      if (!sessionDays.contains(day)) {
        day = day.subtract(const Duration(days: 1));
      }
      var streak = 0;
      while (sessionDays.contains(day)) {
        streak += 1;
        day = day.subtract(const Duration(days: 1));
      }
      if (mounted) setState(() => _streakDays = streak);
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo calcular la racha de entrenamiento.'),
          ),
        );
      }
    }
  }

  void _setTab(TabType tab) {
    setState(() => _activeTab = tab);
    _loadStreak();
  }

  Future<void> _addWater() async {
    final next = double.parse((_waterLitres + 0.25).toStringAsFixed(2));
    final updated = next > 4.0 ? 4.0 : next;
    try {
      await widget.workoutRepository.setPreference(
        widget.authRepository.userId,
        'water_litres',
        updated.toStringAsFixed(2),
      );
      if (mounted) setState(() => _waterLitres = updated);
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar la hidratación en este dispositivo.',
            ),
          ),
        );
      }
    }
  }

  Widget _buildView() {
    switch (_activeTab) {
      case TabType.inicio:
        return InicioView(
          onTabSelected: _setTab,
          waterLitres: _waterLitres,
          onAddWater: _addWater,
          email: widget.authRepository.email,
          ownerId: widget.authRepository.userId,
          streakDays: _streakDays,
          workoutRepository: widget.workoutRepository,
          notificationService: widget.notificationService,
        );
      case TabType.entrenar:
        return EntrenarView(
          onTabSelected: _setTab,
          ownerId: widget.authRepository.userId,
          workoutRepository: widget.workoutRepository,
        );
      case TabType.nutriguia:
        return NutriGuiaView(
          nutritionRepository: widget.nutritionRepository,
          workoutRepository: widget.workoutRepository,
          ownerId: widget.authRepository.userId,
        );
      case TabType.progreso:
        return ProgresoView(
          ownerId: widget.authRepository.userId,
          workoutRepository: widget.workoutRepository,
        );
      case TabType.perfil:
        return PerfilView(
          streakDays: _streakDays,
          email: widget.authRepository.email,
          ownerId: widget.authRepository.userId,
          workoutRepository: widget.workoutRepository,
          profileImageRepository: widget.profileImageRepository,
          notificationService: widget.notificationService,
          onSignOut: () async {
            await widget.authRepository.signOut();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => LoginScreen(
                  onLogin: (_) {},
                  authRepository: widget.authRepository,
                  onAuthenticated: (loginContext) =>
                      Navigator.of(loginContext).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => AppShell(
                            authRepository: widget.authRepository,
                            workoutRepository: widget.workoutRepository,
                            nutritionRepository: widget.nutritionRepository,
                            profileImageRepository:
                                widget.profileImageRepository,
                            notificationService: widget.notificationService,
                          ),
                        ),
                      ),
                ),
              ),
              (_) => false,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppHeader(streakDays: _streakDays, onTabSelected: _setTab),
      body: _buildView(),
      bottomNavigationBar: BottomNav(
        activeTab: _activeTab,
        onTabSelected: _setTab,
        isTrainingActive: _activeTab == TabType.entrenar,
      ),
    );
  }
}
