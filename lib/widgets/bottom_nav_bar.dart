import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class _NavItemData {
  final IconData icon;
  final String label;
  final bool showBadge;

  const _NavItemData(this.icon, this.label, {this.showBadge = false});
}

/// Barra de navegación inferior reutilizada en todas las pantallas.
///
/// IMPORTANTE: por ahora es solo visual. Los botones se muestran
/// (tal como pide el profesor) pero NO cambian de pantalla todavía,
/// ya que la navegación real (Navigator/rutas) se implementará en
/// la Semana 6. [activeIndex] solo controla qué ícono se resalta.
class AppBottomNavBar extends StatelessWidget {
  final int activeIndex;

  const AppBottomNavBar({super.key, this.activeIndex = 0});

  static const List<_NavItemData> _items = [
    _NavItemData(Icons.home, 'Inicio'),
    _NavItemData(Icons.fitness_center, 'Entrenar', showBadge: true),
    _NavItemData(Icons.eco, 'NutriGuía'),
    _NavItemData(Icons.monitor_heart, 'Progreso'),
    _NavItemData(Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBackground)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = index == activeIndex;
          final color =
              isActive ? AppColors.primaryGreen : AppColors.textSecondary;

          return InkWell(
            onTap: () {
              // Navegación deshabilitada intencionalmente (Semana 5).
              // Se habilitará con Navigator en la Semana 6.
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(item.icon, color: color, size: 24),
                    if (item.showBadge)
                      Positioned(
                        top: -2,
                        right: -3,
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
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}