import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/location_provider.dart';
import '../../core/services/session_provider.dart';
import '../../core/theme/app_colors.dart';

class FieldCommandCard extends StatefulWidget {
  const FieldCommandCard({super.key});

  @override
  State<FieldCommandCard> createState() => _FieldCommandCardState();
}

class _FieldCommandCardState extends State<FieldCommandCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<LocationProvider>().refreshLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<SessionProvider>().userName;
    final locationProvider = context.watch<LocationProvider>();

    final locationText =
        locationProvider.locationLabel ??
        (locationProvider.isLoading
            ? 'Detecting your current location...'
            : (locationProvider.errorMessage ?? 'Location unavailable'));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
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
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.card.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.sync_problem,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '3 Pending',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back,\n${userName?.isNotEmpty == true ? userName : 'Field Officer'}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.card,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.card.withValues(alpha: 0.6),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.card.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh location',
                onPressed: locationProvider.isLoading
                    ? null
                    : () => context.read<LocationProvider>().refreshLocation(),
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: AppColors.card.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatusIndicator(
                color: AppColors.tertiary,
                text: 'Offline buffer active',
              ),
              const Spacer(),
              _StatusIndicator(
                color: AppColors.secondaryLight,
                text: 'GPS ±4m precision',
              ),
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
        color: AppColors.card.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.card, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
