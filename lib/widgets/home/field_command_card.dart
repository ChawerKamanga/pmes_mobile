import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FieldCommandCard extends StatelessWidget {
  const FieldCommandCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2241),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FIELD COMMAND',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sync_problem, color: AppColors.secondary, size: 16),
                    SizedBox(width: 6),
                    Text('3 Pending', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome back, Field\nOfficer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.6), size: 18),
              const SizedBox(width: 6),
              Text(
                'Lilongwe Rural District • Southern Zone',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatusIndicator(color: Colors.green, text: 'Offline buffer active'),
              const Spacer(),
              _StatusIndicator(color: Colors.cyanAccent, text: 'GPS ±4m precision'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}