import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subLabel,
    this.rightWidget,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String subLabel;
  final Widget? rightWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              ?rightWidget,
            ],
          ),
          const SizedBox(height: 24),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(subLabel, style: TextStyle(fontSize: 12, color: AppColors.neutral.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}