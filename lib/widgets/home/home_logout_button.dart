import 'package:flutter/material.dart';

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
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoggingOut
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            )
          : const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}