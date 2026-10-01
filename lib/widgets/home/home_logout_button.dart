import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

class HomeLogoutButton extends StatelessWidget {
  const HomeLogoutButton({required this.isLoggingOut, required this.onPressed, super.key});

  final bool isLoggingOut;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoggingOut ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.card,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoggingOut
          ? const _LogoutButtonShimmerPlaceholder()
          : const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _LogoutButtonShimmerPlaceholder extends StatelessWidget {
  const _LogoutButtonShimmerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.35),
      highlightColor: Colors.white.withValues(alpha: 0.8),
      child: Container(
        height: 16,
        width: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}