import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationService extends GetxService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {
        'User-Agent': 'AavenzaOne/1.0 (Flutter Mobile Attendance App)',
      },
    ),
  );

  /// Acquires current location strictly for attendance punch in / punch out.
  /// Enforces runtime permissions. If permission is denied, it prompts for permission.
  /// If denied again, it blocks the punch and prompts the user.
  /// Returns [LocationResult] only when valid GPS coordinates are acquired; otherwise returns null.
  Future<LocationResult?> obtainLocationForPunch() async {
    // 1. Check if device location service (GPS) is turned on
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationServiceDisabledDialog();
      return null;
    }

    // 2. Check current location permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Permission has not been granted yet. Request it from the user.
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // User denied the permission request
        _showPermissionDeniedSnackbar();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied; user must enable in device settings
      await _showPermissionDeniedForeverDialog();
      return null;
    }

    // 3. Permission is granted (whileInUse or always) — acquire precise GPS coordinates
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      try {
        // Fallback to last known position or medium accuracy if high accuracy timed out
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {
        position = null;
      }
    }

    if (position == null) {
      Get.snackbar(
        'Location Unavailable',
        'Could not obtain your current GPS coordinates. Please ensure you have a clear GPS signal and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        icon: const Icon(Icons.location_off, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
      return null;
    }

    // 4. Resolve human-readable address via reverse geocoding
    String? address;
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': position.latitude,
          'lon': position.longitude,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        address = response.data['display_name']?.toString();
      }
    } catch (_) {
      // Graceful fallback to formatted coordinates if Nominatim is unreachable/times out
      address =
          'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}';
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address ??
          'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
    );
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Location Service Disabled',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Device GPS / Location is currently turned off. To record your attendance punch in/out, location services must be enabled.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Turn On Location'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showPermissionDeniedSnackbar() {
    Get.snackbar(
      'Location Permission Required',
      'Punch in / Punch out requires your location to verify attendance. Please grant location access when prompted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.location_disabled_rounded, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  Future<void> _showPermissionDeniedForeverDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Location Permission Denied',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Location access is permanently blocked for this application. Because attendance verification requires your location, you must enable Location permission in App Settings to proceed.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Open App Settings'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
