import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/models.dart';
import 'theme/app_colors.dart';
import 'theme/app_text.dart';
import 'screens/entrenar_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/nutriguia_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/progreso_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const GymMateApp());
}

class GymMateApp extends StatelessWidget {
  const GymMateApp({super.key});

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
      home: const AppShell(),
    );
  }
}

/// Contenedor principal: mantiene el estado compartido (pestaña activa,
/// racha e hidratación) igual que `App.tsx`.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  TabType _activeTab = TabType.inicio;
  final int _streakDays = 4;
  double _waterLitres = 1.8;

  void _setTab(TabType tab) => setState(() => _activeTab = tab);

  void _addWater() {
    setState(() {
      final next = double.parse((_waterLitres + 0.25).toStringAsFixed(2));
      _waterLitres = next > 4.0 ? 0.5 : next;
    });
  }

  Widget _buildView() {
    switch (_activeTab) {
      case TabType.inicio:
        return InicioView(
          onTabSelected: _setTab,
          waterLitres: _waterLitres,
          onAddWater: _addWater,
        );
      case TabType.entrenar:
        return EntrenarView(onTabSelected: _setTab);
      case TabType.nutriguia:
        return const NutriGuiaView();
      case TabType.progreso:
        return const ProgresoView();
      case TabType.perfil:
        return PerfilView(streakDays: _streakDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppHeader(
        streakDays: _streakDays,
        onTabSelected: _setTab,
      ),
      body: _buildView(),
      bottomNavigationBar: BottomNav(
        activeTab: _activeTab,
        onTabSelected: _setTab,
        isTrainingActive: true,
      ),
    );
  }
}
