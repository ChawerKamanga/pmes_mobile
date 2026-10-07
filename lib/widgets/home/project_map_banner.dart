import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/models/dashboard_overview.dart';
import '../../core/services/connectivity_provider.dart';
import '../../core/theme/app_colors.dart';

class ProjectMapBanner extends StatelessWidget {
  const ProjectMapBanner({required this.location, super.key});

  final ProjectLocation location;

  LatLng? get _coordinates {
    final latitude = double.tryParse(location.latitude);
    final longitude = double.tryParse(location.longitude);
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _coordinates;
    final isOnline = context.select(
      (ConnectivityProvider connectivity) => connectivity.isOnline,
    );
    final label = [
      if (location.latitude.isNotEmpty && location.longitude.isNotEmpty)
        '${location.latitude}, ${location.longitude}',
      location.name,
    ].where((value) => value.isNotEmpty).join(' • ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: AppColors.inputBackground,
        child: InkWell(
          onTap: coordinates == null
              ? null
              : () {
                  context.push('/home/project-map', extra: location);
                },
          child: SizedBox(
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coordinates != null && isOnline)
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: coordinates,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pmes_mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: coordinates,
                              width: 34,
                              height: 34,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.secondary,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  const Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 32,
                      color: AppColors.neutral,
                    ),
                  ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: AppColors.card,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                              color: AppColors.secondaryLight.withValues(
                                alpha: 0.2,
                              ),
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
        ),
      ),
    );
  }
}
