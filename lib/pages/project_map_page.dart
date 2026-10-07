import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/models/dashboard_overview.dart';
import '../core/services/connectivity_provider.dart';
import '../core/theme/app_colors.dart';

class ProjectMapPage extends StatelessWidget {
  const ProjectMapPage({required this.location, super.key});

  final ProjectLocation location;

  LatLng? get _coordinates {
    final latitude = double.tryParse(location.latitude);
    final longitude = double.tryParse(location.longitude);
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select(
      (ConnectivityProvider connectivity) => connectivity.isOnline,
    );
    final coordinates = _coordinates;
    final title = location.name.isNotEmpty ? location.name : 'Project Location';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          if (coordinates != null && isOnline)
            FlutterMap(
              options: MapOptions(initialCenter: coordinates, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pmes_mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: coordinates,
                      width: 46,
                      height: 46,
                      child: const Icon(
                        Icons.location_on,
                        size: 42,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              color: AppColors.inputBackground,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 56,
                      color: AppColors.neutral,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      coordinates == null
                          ? 'Location coordinates are unavailable.'
                          : 'Map preview requires internet connection.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.neutralDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${location.latitude}, ${location.longitude}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  if (location.accuracy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Accuracy ±${location.accuracy}m',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
