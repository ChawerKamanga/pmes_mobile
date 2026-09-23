import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
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
          // 1. Projects Tab
          _buildNavItem(
            index: 0,
            label: 'Projects',
            iconWidget: Icon(
              Icons.grid_view_rounded,
              size: 26,
              color: _selectedIndex == 0
                  ? AppColors.secondary
                  : AppColors.neutral,
            ),
          ),

          // 2. New Update FAB-style Tab
          _buildCenterNavItem(
            index: 1,
            label: 'New Update',
            icon: Icons.add_a_photo_outlined,
          ),

          // 3. Sync Queue Tab with Notification Badge
          _buildNavItem(
            index: 2,
            label: 'Sync Queue',
            iconWidget: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.sync,
                  size: 28,
                  color: _selectedIndex == 2
                      ? AppColors.secondary
                      : AppColors.neutral,
                ),
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Profile Tab
          _buildNavItem(
            index: 3,
            label: 'Profile',
            iconWidget: Icon(
              Icons.account_circle_outlined,
              size: 28,
              color: _selectedIndex == 3
                  ? AppColors.secondary
                  : AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for regular navigation items
  Widget _buildNavItem({
    required int index,
    required String label,
    required Widget iconWidget,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          iconWidget,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.secondary : AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for elevated central item ("New Update")
  Widget _buildCenterNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
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
              child: Icon(
                icon,
                color: AppColors.card,
                size: 26,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
