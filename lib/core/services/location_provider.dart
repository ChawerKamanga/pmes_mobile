import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  String? _locationLabel;
  String? _errorMessage;
  bool _isLoading = false;

  String? get locationLabel => _locationLabel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> refreshLocation() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _errorMessage = 'Enable location services to detect your area.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permission denied.';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _locationLabel = await _resolveLocationLabel(position);
    } catch (_) {
      _errorMessage = 'Unable to detect your current location.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _resolveLocationLabel(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final area = _pickFirstNonEmpty([
          place.subAdministrativeArea,
          place.locality,
          place.administrativeArea,
        ]);
        final zone = _pickFirstNonEmpty([
          place.subLocality,
          place.subThoroughfare,
          place.country,
        ]);

        if (area != null && zone != null) {
          return '$area • $zone';
        }
        if (area != null) {
          return area;
        }
      }
    } catch (_) {
      // Fall back to coordinates when reverse geocoding is unavailable.
    }

    return 'Lat ${position.latitude.toStringAsFixed(4)}, Lon ${position.longitude.toStringAsFixed(4)}';
  }

  String? _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
