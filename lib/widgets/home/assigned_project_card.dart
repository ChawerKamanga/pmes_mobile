import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AssignedProjectCard extends StatelessWidget {
  const AssignedProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'CONTRACT REF: RA/MW/2024/09',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusTag(
                    label: 'Published',
                    color: AppColors.secondaryLight.withValues(alpha: 0.18),
                    textColor: AppColors.secondaryDark,
                  ),
                  const SizedBox(width: 6),
                  _StatusTag(
                    label: 'In Progress',
                    color: AppColors.primaryLight.withValues(alpha: 0.14),
                    textColor: AppColors.primaryLight,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Rehabilitation & Expansion of Lilongwe–Mchinji Road Corridor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Section KM 14+200 • Heavy civil pavement resurfacing',
            style: TextStyle(fontSize: 12, color: AppColors.neutral),
          ),
          const SizedBox(height: 16),
          _buildMilestoneProgress(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.payments_outlined,
                  title: 'MWK 3.98B',
                  subtitle: 'Approved',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.verified_outlined,
                  title: '8 / 12',
                  subtitle: 'KPIs Met',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.access_time_rounded,
                  title: '08:30 AM',
                  subtitle: 'Last Synced',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMapBanner(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.near_me_outlined,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                  label: const Text(
                    'Update GPS',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: _buttonStyle(
                    AppColors.secondary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_a_photo_outlined,
                    size: 16,
                    color: AppColors.card,
                  ),
                  label: const Text(
                    'Log Progress',
                    style: TextStyle(
                      color: AppColors.card,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: _buttonStyle(AppColors.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneProgress() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Milestone Completion',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDark,
                ),
              ),
              Text(
                '64%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.64,
              minHeight: 6,
              backgroundColor: AppColors.neutralLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSpecCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: AppColors.inputBackground,
          image: DecorationImage(
            image: NetworkImage(
              'https://tile.openstreetmap.org/14/9691/8470.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.card,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '-13.9626, 33.7741 • Mchinji Road Km...',
                    style: TextStyle(
                      color: AppColors.card,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '±3m Fixed',
                    style: TextStyle(
                      color: AppColors.secondaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
