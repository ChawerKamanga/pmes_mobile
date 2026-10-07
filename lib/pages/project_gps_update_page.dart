import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/models/dashboard_overview.dart';
import '../core/services/api_exception.dart';
import '../core/services/connectivity_provider.dart';
import '../core/services/dashboard_service.dart';
import '../core/services/session_provider.dart';
import '../core/theme/app_colors.dart';

class ProjectGpsUpdateArgs {
  const ProjectGpsUpdateArgs({
    required this.projectId,
    required this.projectTitle,
    required this.location,
  });

  final String projectId;
  final String projectTitle;
  final ProjectLocation location;

  LatLng? get initialCoordinates {
    final latitude = double.tryParse(location.latitude);
    final longitude = double.tryParse(location.longitude);
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }
}

class ProjectGpsUpdatePage extends StatefulWidget {
  const ProjectGpsUpdatePage({required this.args, super.key});

  final ProjectGpsUpdateArgs args;

  @override
  State<ProjectGpsUpdatePage> createState() => _ProjectGpsUpdatePageState();
}

class _ProjectGpsUpdatePageState extends State<ProjectGpsUpdatePage> {
  static const _dashboardService = DashboardService();

  LatLng? _selectedCoordinates;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCoordinates = widget.args.initialCoordinates;
  }

  Future<void> _submit() async {
    final selectedCoordinates = _selectedCoordinates;
    if (selectedCoordinates == null) {
      setState(() {
        _errorMessage = 'Tap on the map to select a GPS point before submitting.';
      });
      return;
    }

    final token = context.read<SessionProvider>().token;
    if (token == null) {
      setState(() {
        _errorMessage = 'You are not signed in. Please log in again.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _dashboardService.updateProjectGps(
        token: token,
        projectId: widget.args.projectId,
        latitude: selectedCoordinates.latitude,
        longitude: selectedCoordinates.longitude,
        accuracy: widget.args.location.accuracy?.toDouble(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Project GPS updated successfully.')),
        );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Unable to update project GPS right now. Please try again.';
      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select(
      (ConnectivityProvider connectivity) => connectivity.isOnline,
    );
    final selectedCoordinates = _selectedCoordinates;

    return Scaffold(
      appBar: AppBar(title: const Text('Update GPS')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isOnline)
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedCoordinates ?? const LatLng(0, 0),
                      initialZoom: selectedCoordinates == null ? 2.3 : 16,
                      onTap: (_, point) {
                        setState(() {
                          _selectedCoordinates = point;
                          _errorMessage = null;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.pmes_mobile',
                      ),
                      if (selectedCoordinates != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedCoordinates,
                              width: 48,
                              height: 48,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      'Map selection requires internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neutralDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(color: AppColors.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.args.projectTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap any point on the map to choose the new GPS location.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedCoordinates == null
                        ? 'Selected coordinates: Not selected'
                        : 'Selected coordinates: ${selectedCoordinates.latitude.toStringAsFixed(6)}, ${selectedCoordinates.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting || !isOnline ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_alt_outlined, size: 18),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit GPS Update',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.card,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}