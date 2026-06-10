import 'package:geolocator/geolocator.dart';

class LocationService {
  // Goa Boundary Coordinates
  static const double minLat = 14.80;
  static const double maxLat = 15.85;
  static const double minLon = 73.60;
  static const double maxLon = 74.45;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Fetches position and verifies if user is in Goa.
  Future<Map<String, dynamic>> verifyLocation({required bool isDemoMode}) async {
    
    // 1. SIMULATOR / DEMO MODE
    if (isDemoMode) {
      await Future.delayed(const Duration(seconds: 1)); // Mimic loading
      return {
        'isInside': true,
        'latitude': 15.2993,
        'longitude': 74.1240,
        'details': 'Simulator Active: GPS Bypassed'
      };
    }

    // 2. LIVE PRODUCTION CHECK
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return {
          'isInside': false,
          'latitude': 0.0,
          'longitude': 0.0,
          'details': 'Location permission denied. Please grant location access.'
        };
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final isInside = position.latitude >= minLat &&
          position.latitude <= maxLat &&
          position.longitude >= minLon &&
          position.longitude <= maxLon;

      return {
        'isInside': isInside,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'details': 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}'
      };
    } catch (e) {
      return {
        'isInside': false,
        'latitude': 0.0,
        'longitude': 0.0,
        'details': 'Error retrieving location: $e'
      };
    }
  }
}