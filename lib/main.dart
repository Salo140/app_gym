import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/models.dart';
import 'models/workout_plan.dart';
import 'theme/app_colors.dart';
import 'theme/app_text.dart';
import 'screens/entrenar_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nutriguia_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/progreso_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/plan_form_screen.dart';
import 'screens/plan_summary_screen.dart';
import 'widgets/app_header.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
              onLogin: (_) => Navigator.of(context).pushNamed('/app'),
            ),
        '/app': (context) => const AppShell(),
        '/plan-form': (context) => const PlanFormScreen(),
        '/category-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as CategoryDetailArguments;
          return CategoryDetailScreen(category: args.category);
        },
        '/plan-summary': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as PlanSummaryArguments;
          return PlanSummaryScreen(plan: args.plan);
        },
      },
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

  List<Widget> _buildViews() => [
        InicioView(
          onTabSelected: _setTab,
          waterLitres: _waterLitres,
          onAddWater: _addWater,
        ),
        EntrenarView(onTabSelected: _setTab),
        const NutriGuiaView(),
        const ProgresoView(),
        PerfilView(streakDays: _streakDays),
      ];

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
      body: IndexedStack(
        index: _activeTab.index,
        children: _buildViews(),
      ),
      bottomNavigationBar: Container(
        color: AppColors.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: SizedBox(
              height: 68,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                iconSize: 20,
                selectedFontSize: 10,
                unselectedFontSize: 9,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.onSurfaceVariant,
                backgroundColor: AppColors.surfaceLow,
                currentIndex: _activeTab.index,
                onTap: (index) => _setTab(TabType.values[index]),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center_outlined),
                    activeIcon: Icon(Icons.fitness_center),
                    label: 'Entrenar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.eco_outlined),
                    activeIcon: Icon(Icons.eco),
                    label: 'NutriGuía',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart),
                    activeIcon: Icon(Icons.show_chart),
                    label: 'Progreso',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
