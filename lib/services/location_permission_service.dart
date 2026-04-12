import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Handles location permission requests and status checking
class LocationPermissionService {
  static final LocationPermissionService _instance = LocationPermissionService._internal();
  factory LocationPermissionService() => _instance;
  LocationPermissionService._internal();

  static LocationPermissionService get instance => _instance;

  /// Check current location permission status
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Location service is DISABLED');
        return LocationPermissionStatus.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      switch (permission) {
        case LocationPermission.denied:
          debugPrint('📍 Location permission DENIED');
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          debugPrint('📍 Location permission DENIED FOREVER');
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
          debugPrint('📍 Location permission WHILE IN USE');
          return LocationPermissionStatus.whileInUse;
        case LocationPermission.always:
          debugPrint('📍 Location permission ALWAYS');
          return LocationPermissionStatus.always;
        case LocationPermission.unableToDetermine:
          debugPrint('📍 Location permission UNABLE TO DETERMINE');
          return LocationPermissionStatus.error;
      }
    } catch (e) {
      debugPrint('📍 Permission check error: $e');
      return LocationPermissionStatus.error;
    }
  }

  /// Request location permission
  Future<LocationPermissionResult> requestPermission() async {
    try {
      // Check if service is enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Location service disabled, prompting user');
        final opened = await openLocationSettings();
        if (!opened) {
          return LocationPermissionResult(
            status: LocationPermissionStatus.serviceDisabled,
            position: null,
          );
        }
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();

      // If denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If denied forever, show settings dialog
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.deniedForever,
          position: null,
        );
      }

      // If we have permission, get position
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        return LocationPermissionResult(
          status: permission == LocationPermission.whileInUse
              ? LocationPermissionStatus.whileInUse
              : LocationPermissionStatus.always,
          position: position,
        );
      }

      return LocationPermissionResult(
        status: LocationPermissionStatus.denied,
        position: null,
      );
    } catch (e) {
      debugPrint('📍 Permission request error: $e');
      return LocationPermissionResult(
        status: LocationPermissionStatus.error,
        position: null,
      );
    }
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for denied forever case)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get current position (if permission granted)
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkPermission();
      if (permission == LocationPermissionStatus.whileInUse ||
          permission == LocationPermissionStatus.always) {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('📍 Get position error: $e');
      return null;
    }
  }

  /// Show permission rationale dialog
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Text('Location Access'),
              ],
            ),
            content: const Text(
              'Agri Flow needs access to your location to:\n\n'
              '• Show nearby farms and products\n'
              '• Calculate delivery distances\n'
              '• Provide location-based recommendations\n\n'
              'Your location data is only used within the app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show settings dialog for denied forever case
  Future<void> showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Location permission was permanently denied. '
          'Please enable it in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// Location permission status enum
enum LocationPermissionStatus {
  serviceDisabled,
  denied,
  deniedForever,
  whileInUse,
  always,
  error,
}

/// Location permission result
class LocationPermissionResult {
  final LocationPermissionStatus status;
  final Position? position;

  const LocationPermissionResult({
    required this.status,
    required this.position,
  });

  bool get hasPermission =>
      status == LocationPermissionStatus.whileInUse ||
      status == LocationPermissionStatus.always;
}
