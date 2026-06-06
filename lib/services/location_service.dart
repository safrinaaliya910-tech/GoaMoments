import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kDebugMode
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Goa Boundary Coordinates (Original Constants)
  static const double minLat = 14.80;
  static const double maxLat = 15.85;
  static const double minLon = 73.60;
  static const double maxLon = 74.45;

  bool _mockIsInsideGoa = true;

  void setMockLocationState(bool isInside) {
    _mockIsInsideGoa = isInside;
  }

  bool get mockIsInsideGoa => _mockIsInsideGoa;

  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Fetches position and verifies if user is in Goa.
  Future<Map<String, dynamic>> verifyLocation({required bool isDemoMode}) async {
    
    // 1. DEVELOPER BYPASS (Always active if you are in debug mode and mock toggle is on)
    if (kDebugMode && _mockIsInsideGoa) {
      return {
        'isInside': true,
        'latitude': 15.2993,
        'longitude': 74.1240,
        'details': 'Developer Bypass: Simulated Inside Goa'
      };
    }

    // 2. APP DEMO MODE (Triggered if isDemoMode is true in config.dart)
    if (isDemoMode) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'isInside': _mockIsInsideGoa,
        'latitude': 15.2993,
        'longitude': 74.1240,
        'details': _mockIsInsideGoa ? 'Demo Mode: Inside Goa' : 'Demo Mode: Outside Goa'
      };
    }

    // 3. LIVE PRODUCTION CHECK
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