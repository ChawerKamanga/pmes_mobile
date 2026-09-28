import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class KpiSummaryCard extends StatelessWidget {
  const KpiSummaryCard({
    required this.verified,
    required this.total,
    required this.completionPercentage,
    required this.nextReviewLabel,
    super.key,
  });

  final String verified;
  final String total;
  final num completionPercentage;
  final String nextReviewLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: AppColors.card,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$verified / $total',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${completionPercentage.round()}% Target',
                        style: const TextStyle(
                          color: AppColors.secondaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'KPIs Verified • $nextReviewLabel',
                  style: const TextStyle(fontSize: 12, color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.neutral, size: 20),
        ],
      ),
    );
  }
}
