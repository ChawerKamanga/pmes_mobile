import 'package:flutter/material.dart';

import '../../core/models/dashboard_overview.dart';
import '../../core/theme/app_colors.dart';

class AssignedProjectCard extends StatelessWidget {
  const AssignedProjectCard({required this.project, super.key});

  final AssignedProject project;

  static String _stripHtml(String value, {int maxLength = 220}) {
    final plainText = value.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (plainText.length <= maxLength) return plainText;
    return '${plainText.substring(0, maxLength).trim()}…';
  }

  @override
  Widget build(BuildContext context) {
    final section = project.section != null && project.section!.isNotEmpty
        ? _stripHtml(project.section!)
        : null;
    final activity = project.activity != null && project.activity!.isNotEmpty
        ? _stripHtml(project.activity!)
        : null;
    final subtitle = [
      if (section != null && section.isNotEmpty) section,
      if (activity != null && activity.isNotEmpty) activity,
    ].join(' • ');
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
              Expanded(
                child: Text(
                  'CONTRACT REF: ${project.contractRef}',
                  style: const TextStyle(
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
                    label: project.status.publication,
                    color: AppColors.secondaryLight.withValues(alpha: 0.18),
                    textColor: AppColors.secondaryDark,
                  ),
                  const SizedBox(width: 6),
                  _StatusTag(
                    label: project.status.progress,
                    color: AppColors.primaryLight.withValues(alpha: 0.14),
                    textColor: AppColors.primaryLight,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              height: 1.25,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral),
            ),
          ],
          const SizedBox(height: 16),
          _buildMilestoneProgress(project.milestoneCompletion),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.payments_outlined,
                  title: project.stats.approvedBudget,
                  subtitle: 'Approved',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.verified_outlined,
                  title: project.stats.kpisMet,
                  subtitle: 'KPIs Met',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallSpecCard(
                  icon: Icons.access_time_rounded,
                  title: project.stats.lastSynced,
                  subtitle: 'Last Synced',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMapBanner(project.location),
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

  Widget _buildMilestoneProgress(num milestoneCompletion) {
    final progress = (milestoneCompletion / 100).clamp(0, 1).toDouble();
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
            children: [
              const Text(
                'Milestone Completion',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDark,
                ),
              ),
              Text(
                '${milestoneCompletion.round()}%',
                style: const TextStyle(
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
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.neutralLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
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

  Widget _buildMapBanner(ProjectLocation location) {
    final label = [
      if (location.latitude.isNotEmpty && location.longitude.isNotEmpty)
        '${location.latitude}, ${location.longitude}',
      location.name,
    ].where((s) => s.isNotEmpty).join(' • ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(color: AppColors.inputBackground),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Center(
              child: Icon(
                Icons.map_outlined,
                size: 32,
                color: AppColors.neutral,
              ),
            ),
            Align(
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
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.card,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (location.accuracy != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '±${location.accuracy}m Fixed',
                          style: const TextStyle(
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
          ],
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
