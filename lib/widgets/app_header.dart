import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'common.dart';

/// Barra superior fija: logo, racha y avatar. Equivale a `Header.tsx`.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.streakDays,
    required this.onTabSelected,
  });

  final int streakDays;
  final ValueChanged<TabType> onTabSelected;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD9101418),
            border: Border(bottom: BorderSide(color: AppColors.surface)),
            boxShadow: [
              BoxShadow(color: Color(0x59000000), blurRadius: 8),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: ContentShell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Marca
                      InkWell(
                        onTap: () => onTabSelected(TabType.inicio),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const RemoteImage(
                                url: Assets.logo,
                                height: 32,
                                width: 32,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'GymMate',
                              style: AppText.headlineSm(size: 18),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Racha
                      GestureDetector(
                        onTap: () => onTabSelected(TabType.progreso),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.fade(AppColors.surfaceHigh, 0.8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.surfaceHighest),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.fade(AppColors.secondary, 0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text(
                            '🔥 $streakDays días',
                            style: AppText.labelMd(
                              color: AppColors.secondaryLight,
                              size: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Avatar
                      GestureDetector(
                        onTap: () => onTabSelected(TabType.perfil),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceHighest),
                          ),
                          child: const ClipOval(
                            child: RemoteImage(
                              url: Assets.userAvatar,
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}