import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.onNewUpdate,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.pendingSyncCount,
    super.key,
  });

  final VoidCallback onNewUpdate;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int? pendingSyncCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildNavItem(
              index: 0,
              label: 'Projects',
              icon: Icons.grid_view_rounded,
            ),
            _buildCenterNavItem(),
            _buildNavItem(
              index: 2,
              label: 'Sync Queue',
              icon: Icons.sync,
              badgeCount: pendingSyncCount,
            ),
            _buildNavItem(
              index: 3,
              label: 'Profile',
              icon: Icons.account_circle_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    int? badgeCount,
  }) {
    final isSelected = selectedIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: index == 0 ? 26 : 28,
                    color: isSelected ? AppColors.secondary : AppColors.neutral,
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: AppColors.card,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.neutralDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return Semantics(
      button: true,
      label: 'New Update',
      child: InkWell(
        onTap: onNewUpdate,
        borderRadius: BorderRadius.circular(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.card,
                  size: 26,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -12),
              child: const Text(
                'New Update',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
