import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

/// Equivale a `PerfilView.tsx`.
class PerfilView extends StatefulWidget {
  const PerfilView({super.key, required this.streakDays});

  final int streakDays;

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  int _defaultRestTime = 90;
  bool _soundAlerts = true;
  bool _vibrationAlerts = true;
  String _weightUnit = 'kg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ContentShell(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            topInset(context) + 8,
            20,
            bottomInset(context),
          ),
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            _routineCard(),
            const SizedBox(height: 16),
            _preferencesCard(),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fade(AppColors.primary, 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: RemoteImage(url: Assets.userAvatar),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Symbols.check,
                      size: 14, color: AppColors.onPrimary, weight: 700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Carlos Martínez', style: AppText.headlineMd(size: 20)),
          const SizedBox(height: 2),
          Text(
            'Atleta Intermedio • Hipertrofia & Rendimiento',
            style: AppText.bodySm(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pill(
                label: '🔥 Racha activa: ${widget.streakDays} días',
                background: AppColors.fade(AppColors.primary, 0.15),
                foreground: AppColors.primaryLight,
                borderColor: AppColors.fade(AppColors.primary, 0.3),
                fontSize: 12,
                bold: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
              const SizedBox(width: 8),
              Pill(
                label: 'GymMate Pro',
                background: AppColors.fade(AppColors.secondaryLight, 0.15),
                foreground: AppColors.secondaryLight,
                borderColor: AppColors.fade(AppColors.secondaryLight, 0.3),
                fontSize: 12,
                bold: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.cardBorderSoft),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _bioTile('Peso', '78.5 kg')),
              const SizedBox(width: 8),
              Expanded(child: _bioTile('Altura', '178 cm')),
              const SizedBox(width: 8),
              Expanded(
                child: _bioTile('Grasa Est.', '14.2%',
                    color: AppColors.tertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bioTile(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceHigh, 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: AppText.labelSm(size: 10, letterSpacing: 0)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppText.metric(color: color ?? AppColors.onSurface, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _routineCard() {
    return SurfaceCard(
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.fitness_center,
                  size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text('Rutina Activa', style: AppText.headlineSm(size: 14)),
              const Spacer(),
              Text(
                'Semana 4 de 8',
                style: AppText.labelSm(
                    color: AppColors.primary, size: 11, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.surfaceHigh, 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'División Torso / Pierna / Empuje',
                        style: AppText.bodyMd(
                          color: AppColors.onSurface,
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Pill(
                      label: '4 días / sem',
                      background: AppColors.fade(AppColors.primary, 0.15),
                      foreground: AppColors.primaryLight,
                      fontSize: 10,
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Enfoque en sobrecarga progresiva y rango de hipertrofia '
                  'mecánica (RPE 8-9).',
                  style: AppText.bodySm(size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _preferencesCard() {
    return SurfaceCard(
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.tune,
                  size: 20, color: AppColors.secondaryLight),
              const SizedBox(width: 8),
              Text('Ajustes de Sesión y Descanso',
                  style: AppText.headlineSm(size: 14)),
            ],
          ),
          const SizedBox(height: 12),

          // Descanso predeterminado
          _settingRow(
            title: 'Descanso predeterminado',
            subtitle: 'Segundos automáticos entre series',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roundButton('-',
                    () => setState(() {
                      final next = _defaultRestTime - 15;
                      _defaultRestTime = next < 30 ? 30 : next;
                    })),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${_defaultRestTime}s',
                    textAlign: TextAlign.center,
                    style: AppText.metric(
                        color: AppColors.secondaryLight, size: 14),
                  ),
                ),
                _roundButton('+',
                    () => setState(() => _defaultRestTime += 15)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Alerta sonora
          _settingRow(
            title: 'Alerta sonora de descanso',
            subtitle: 'Sonido sutil al finalizar la cuenta atrás',
            trailing: _switch(
              value: _soundAlerts,
              onChanged: (v) => setState(() => _soundAlerts = v),
            ),
          ),
          const SizedBox(height: 12),

          // Vibración
          _settingRow(
            title: 'Respuesta háptica / Vibración',
            subtitle: 'Pulsos al confirmar registro de series',
            trailing: _switch(
              value: _vibrationAlerts,
              onChanged: (v) => setState(() => _vibrationAlerts = v),
            ),
          ),
          const SizedBox(height: 12),

          // Unidad
          _settingRow(
            title: 'Unidad de carga',
            subtitle: 'Kilogramos (kg) o Libras (lbs)',
            trailing: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _unitButton('kg'),
                  _unitButton('lbs'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Guardar Preferencias',
            height: 46,
            radius: 12,
            onPressed: () => showGymToast(
              context,
              '¡Preferencias guardadas exitosamente!',
              icon: Symbols.check_circle,
              duration: const Duration(milliseconds: 2500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceHigh, 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bodyMd(
                    color: AppColors.onSurface,
                    size: 12,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.bodySm(size: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _roundButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHighest,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: AppText.headlineSm(size: 16, color: AppColors.onSurface),
        ),
      ),
    );
  }

  Widget _switch({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x40000000), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitButton(String unit) {
    final selected = _weightUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _weightUnit = unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: AppText.labelMd(
            color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            size: 12,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}