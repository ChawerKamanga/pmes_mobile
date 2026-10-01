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
          Image.asset(
            'images/pmes_logo_removebg_preview_cuua1g.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: AppColors.card),
          onPressed: () {},
        )
      ],
    );
  }
}