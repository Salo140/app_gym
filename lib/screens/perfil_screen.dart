import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla "Perfil": datos del usuario, rutina activa y preferencias
/// de sesión/descanso.
///
/// Pantalla ESTÁTICA: los "switches" y el selector kg/lbs se muestran
/// con su estado de ejemplo (tal como en el diseño original) pero no
/// tienen lógica real todavía — solo representación visual.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(streakDays: 4),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildActiveRoutineCard(),
              const SizedBox(height: 16),
              _buildPreferencesCard(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Tarjeta de perfil (avatar, nombre, insignias, biométricos) ---
  Widget _buildProfileHeader() {
    return _Card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: const CircleAvatar(
                  backgroundColor: AppColors.cardBackgroundAlt,
                  child: Icon(Icons.person,
                      color: AppColors.textSecondary, size: 40),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.check,
                    size: 14, color: AppColors.darkGreenText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Carlos Martínez',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            'Atleta Intermedio • Hipertrofia & Rendimiento',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pill(
                color: AppColors.primaryGreen.withOpacity(0.15),
                borderColor: AppColors.primaryGreen.withOpacity(0.3),
                child: const Text('🔥 Racha activa: 4 días',
                    style: TextStyle(
                        color: AppColors.lightGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              _Pill(
                color: AppColors.orange.withOpacity(0.15),
                borderColor: AppColors.orange.withOpacity(0.3),
                child: const Text('GymMate Pro',
                    style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _biometricStat('Peso', '78.5 kg',
                      AppColors.textPrimary)),
              Expanded(
                  child: _biometricStat('Altura', '178 cm',
                      AppColors.textPrimary)),
              Expanded(
                  child:
                      _biometricStat('Grasa Est.', '14.2%', AppColors.mint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _biometricStat(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundAlt.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Rutina activa ---
  Widget _buildActiveRoutineCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.fitness_center,
                      color: AppColors.lightGreen, size: 18),
                  SizedBox(width: 8),
                  Text('Rutina Activa',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('Semana 4 de 8',
                  style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundAlt.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('División Torso / Pierna / Empuje',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    _Pill(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      child: const Text('4 días / sem',
                          style: TextStyle(
                              color: AppColors.lightGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enfoque en sobrecarga progresiva y rango de hipertrofia '
                  'mecánica (RPE 8-9).',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Preferencias de sesión y descanso ---
  Widget _buildPreferencesCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: AppColors.orange, size: 18),
              SizedBox(width: 8),
              Text('Ajustes de Sesión y Descanso',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // Descanso predeterminado (stepper visual, sin lógica)
          _preferenceRow(
            title: 'Descanso predeterminado',
            subtitle: 'Segundos automáticos entre series',
            trailing: Row(
              children: [
                _stepperButton('-'),
                Container(
                  width: 46,
                  alignment: Alignment.center,
                  child: const Text('90s',
                      style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
                _stepperButton('+'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Alerta sonora (toggle visual, estado: activado)
          _preferenceRow(
            title: 'Alerta sonora de descanso',
            subtitle: 'Sonido sutil al finalizar la cuenta atrás',
            trailing: const _StaticToggle(isOn: true),
          ),
          const SizedBox(height: 10),

          // Vibración (toggle visual, estado: activado)
          _preferenceRow(
            title: 'Respuesta háptica / Vibración',
            subtitle: 'Pulsos al confirmar registro de series',
            trailing: const _StaticToggle(isOn: true),
          ),
          const SizedBox(height: 10),

          // Unidad de carga (segmented control visual)
          _preferenceRow(
            title: 'Unidad de carga',
            subtitle: 'Kilogramos (kg) o Libras (lbs)',
            trailing: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _unitOption('kg', selected: true),
                  _unitOption('lbs', selected: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Sin funcionalidad todavía (pantalla estática).
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.darkGreenText,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Guardar Preferencias',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preferenceRow({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundAlt.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _stepperButton(String symbol) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Text(symbol,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _unitOption(String label, {required bool selected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.darkGreenText : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Toggle estático que imita un switch encendido/apagado, sin lógica real.
class _StaticToggle extends StatelessWidget {
  final bool isOn;
  const _StaticToggle({required this.isOn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 26,
      padding: const EdgeInsets.all(3),
      alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: isOn ? AppColors.primaryGreen : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
  final Color? borderColor;

  const _Pill({required this.child, required this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: child,
    );
  }
}