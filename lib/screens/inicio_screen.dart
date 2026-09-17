import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/image_placeholder.dart';

/// Pantalla "Inicio": panel principal con saludo, racha semanal,
/// rutina destacada del día, métricas rápidas, sugerencia de NutriGuía
/// y una cápsula educativa ("mito del día").
///
/// Pantalla ESTÁTICA: no hay navegación real, ni llamadas a servicios,
/// ni persistencia de datos. Todos los valores son de ejemplo.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(streakDays: 4),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreeting(),
              const SizedBox(height: 16),
              _buildWeeklyStreak(),
              const SizedBox(height: 16),
              _buildFeaturedRoutine(),
              const SizedBox(height: 16),
              _buildQuickMetrics(),
              const SizedBox(height: 16),
              _buildNutriGuiaBanner(),
              const SizedBox(height: 16),
              _buildMythOfTheDay(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Saludo + botón de notificaciones ---
  Widget _buildGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  '¡Hola, Carlos!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 2),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                children: [
                  TextSpan(text: 'Nivel: Intermedio • '),
                  TextSpan(
                    text: 'Hoy toca Torso / Empuje',
                    style: TextStyle(
                      color: AppColors.lightGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.cardBackgroundAlt,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications,
                  color: AppColors.textPrimary, size: 22),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Racha semanal (grid de 7 días) ---
  Widget _buildWeeklyStreak() {
    final days = [
      {'label': 'L', 'state': 'done'},
      {'label': 'M', 'state': 'done'},
      {'label': 'X', 'state': 'done'},
      {'label': 'J', 'state': 'today'},
      {'label': 'V', 'state': 'pending'},
      {'label': 'S', 'state': 'pending'},
      {'label': 'D', 'state': 'rest'},
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_fire_department,
                      color: AppColors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Racha Semanal',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '4 días seguidos',
                  style: TextStyle(
                    color: AppColors.lightGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) => _buildDayCircle(day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(Map<String, String> day) {
    final state = day['state'];
    Color bg;
    Color fg;
    Widget child;
    BoxBorder? border;

    switch (state) {
      case 'done':
        bg = AppColors.primaryGreen;
        fg = AppColors.darkGreenText;
        child = Icon(Icons.check, size: 16, color: fg);
        break;
      case 'today':
        bg = AppColors.border;
        fg = AppColors.lightGreen;
        border = Border.all(color: AppColors.primaryGreen);
        child = Text('Hoy',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: fg));
        break;
      case 'rest':
        bg = AppColors.cardBackgroundDark;
        fg = AppColors.orange.withOpacity(0.6);
        border = Border.all(color: AppColors.border.withOpacity(0.4));
        child = Icon(Icons.hotel, size: 14, color: fg);
        break;
      default: // pending
        bg = AppColors.cardBackgroundDark;
        fg = AppColors.textSecondary.withOpacity(0.4);
        border = Border.all(color: AppColors.border.withOpacity(0.4));
        child = Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        );
    }

    return Column(
      children: [
        Text(day['label']!,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }

  // --- Rutina destacada del día ---
  Widget _buildFeaturedRoutine() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada (placeholder) + insignias superpuestas
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ImagePlaceholder(
                    icon: Icons.fitness_center,
                    iconSize: 40,
                    borderRadius: 0,
                    gradientColors: [
                      AppColors.cardBackgroundAlt,
                      AppColors.background,
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _Pill(
                    color: AppColors.background.withOpacity(0.8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _Dot(color: AppColors.primaryGreen),
                        SizedBox(width: 6),
                        Text('ENTRENAMIENTO DE HOY',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Pill(
                    color: AppColors.cardBackgroundAlt.withOpacity(0.8),
                    child: const Text('Intermedio',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empuje & Pecho',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pectoral mayor, deltoides anterior & tríceps',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip(Icons.timer, '50 min', AppColors.orange),
                    const SizedBox(width: 14),
                    _statChip(Icons.fitness_center, '5 ejercicios',
                        AppColors.lightGreen),
                    const SizedBox(width: 14),
                    _statChip(Icons.bolt, '16 series', AppColors.mint),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Sin funcionalidad todavía (pantalla estática).
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.darkGreenText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Iniciar Entrenamiento',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- Métricas rápidas (3 columnas) ---
  Widget _buildQuickMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.local_fire_department,
            iconColor: AppColors.orange,
            value: '450',
            label: 'kcal quemadas',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            icon: Icons.fitness_center,
            iconColor: AppColors.lightGreen,
            value: '3 de 4',
            label: 'entrenos meta',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            icon: Icons.water_drop,
            iconColor: AppColors.mint,
            value: '1.8 L',
            label: 'de 2.5L agua',
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  // --- Banner de NutriGuía ---
  Widget _buildNutriGuiaBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: ImagePlaceholder(
                  icon: Icons.restaurant_menu,
                  gradientColors: [Color(0xFF1F3B32), Color(0xFF16261F)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.restaurant_menu,
                            size: 14, color: AppColors.mint),
                        SizedBox(width: 4),
                        Text('NUTRIGUÍA SUGERIDA',
                            style: TextStyle(
                                color: AppColors.mint,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Arma tu plato post-entreno',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Proporción ideal de 40g de proteína magra y '
                      'carbohidratos complejos para tu recuperación.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  _Pill(
                    color: AppColors.mint.withOpacity(0.15),
                    child: const Text('Proteína + Carbos',
                        style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  _Pill(
                    color: AppColors.border,
                    child: const Text('3 min lectura',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10)),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Explorar',
                      style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward,
                      color: AppColors.primaryGreen, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Mito del día ---
  Widget _buildMythOfTheDay() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.orangeStrong, size: 18),
                  SizedBox(width: 6),
                  Text('MITO FITNESS DEL DÍA',
                      style: TextStyle(
                          color: AppColors.orangeStrong,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text('1 min lectura',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '¿Sudar más significa quemar más grasa corporal?',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              children: [
                TextSpan(
                  text: 'Falso. ',
                  style: TextStyle(
                      color: Color(0xFFFFB4AB), fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'El sudor es un mecanismo de termorregulación para enfriar '
                      'el cuerpo, no un indicador directo de pérdida de grasa. '
                      'El gasto calórico real depende de la intensidad del esfuerzo.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('¿Te resultó útil esta cápsula?',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
                Row(
                  children: [
                    _Pill(
                      color: AppColors.cardBackgroundAlt,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.thumb_up,
                              size: 14, color: AppColors.textPrimary),
                          SizedBox(width: 4),
                          Text('142',
                              style:
                                  TextStyle(color: AppColors.textPrimary, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.cardBackgroundAlt,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share,
                          size: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta base reutilizada dentro de esta pantalla.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final Color color;

  const _Pill({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}