import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/connectivity_provider.dart';
import '../../core/services/location_provider.dart';
import '../../core/services/session_provider.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final userName = context.watch<SessionProvider>().userName;
    final locationProvider = context.watch<LocationProvider>();
    final connectivityProvider = context.watch<ConnectivityProvider>();

    final statusText = connectivityProvider.isChecking
        ? 'Checking...'
        : (connectivityProvider.isOnline ? 'Online' : 'Offline');
    final statusColor = connectivityProvider.isChecking
        ? colorScheme.onSurfaceVariant
        : (connectivityProvider.isOnline
              ? colorScheme.tertiary
              : colorScheme.error);

    final locationText =
        locationProvider.locationLabel ??
        (locationProvider.isLoading
            ? 'Detecting your current location...'
            : (locationProvider.errorMessage ?? 'Location unavailable'));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                  color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sync_problem,
                      color: colorScheme.onSecondaryContainer,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '3 Pending',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _StatusIndicator(
                color: statusColor,
                text: statusText,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh internet status',
                onPressed: connectivityProvider.isChecking
                    ? null
                    : () =>
                          context.read<ConnectivityProvider>().refreshStatus(),
                icon: Icon(
                  Icons.wifi_tethering,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.color,
    required this.text,
    required this.colorScheme,
  });

  final Color color;
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
            style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
