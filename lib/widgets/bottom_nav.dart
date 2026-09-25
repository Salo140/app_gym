import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'common.dart';

class _NavItem {
  const _NavItem(this.tab, this.label, this.icon, {this.badge = false});

  final TabType tab;
  final String label;
  final IconData icon;
  final bool badge;
}

/// Barra inferior fija con 5 destinos. Equivale a `BottomNav.tsx`.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.isTrainingActive = true,
  });

  final TabType activeTab;
  final ValueChanged<TabType> onTabSelected;
  final bool isTrainingActive;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      const _NavItem(TabType.inicio, 'Inicio', Symbols.home),
      _NavItem(
        TabType.entrenar,
        'Entrenar',
        Symbols.fitness_center,
        badge: isTrainingActive,
      ),
      const _NavItem(TabType.nutriguia, 'NutriGuía', Symbols.eco),
      const _NavItem(TabType.progreso, 'Progreso', Symbols.monitoring),
      const _NavItem(TabType.perfil, 'Perfil', Symbols.person),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xE6101418),
            border: Border(top: BorderSide(color: AppColors.surface)),
            boxShadow: [
              BoxShadow(
                color: Color(0x73000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: ContentShell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.map((item) {
                    final isActive = item.tab == activeTab;
                    final color = isActive
                        ? AppColors.primary
                        : AppColors.fade(AppColors.onSurfaceVariant, 0.7);

                    return InkWell(
                      onTap: () => onTabSelected(item.tab),
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 52,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 24,
                                  color: color,
                                  fill: isActive ? 1 : 0,
                                  weight: isActive ? 700 : 400,
                                  shadows: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.fade(
                                                AppColors.primary, 0.45),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                if (item.badge)
                                  const Positioned(
                                    top: -2,
                                    right: -4,
                                    child: PulseDot(size: 8),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: AppText.labelSm(
                                color: color,
                                size: 11,
                                weight:
                                    isActive ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}