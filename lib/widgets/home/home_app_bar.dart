import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart_rounded, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PMES FIELD OPS',
                style: TextStyle(fontSize: 12, color: AppColors.card.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
              ),
              const Text(
                'Projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.card),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: AppColors.card),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tertiary.withValues(alpha: 0.2),
            child: const Icon(Icons.person_outline, color: AppColors.card),
          ),
        ),
      ],
    );
  }
}