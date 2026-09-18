import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'common.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.primary, 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.headlineSm(size: 14)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.bodySm(size: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: '$value $label',
      background: AppColors.fade(AppColors.primary, 0.12),
      foreground: AppColors.primaryLight,
      borderColor: AppColors.cardBorderSoft,
      fontSize: 10,
      bold: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}
