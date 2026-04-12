import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  static MapService get instance => _instance;

  // MapTiler API Key - Replace with your own key from maptiler.com
  // Your API key was exposed in screenshot. Please regenerate it at maptiler.com/dashboard
  static const String maptilerApiKey = 'eBVGyj1xRKZtAPdAnvmv';
  
  // HiDPI tile URL for better quality on mobile
  static String get tileUrl => 
      'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}@2x.png?key=$maptilerApiKey';

  // Tamil Nadu center coordinates
  static const LatLng tamilNaduCenter = LatLng(11.1271, 78.6569);
  static const double initialZoom = 7.0;

  /// Get current device location
  Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('📍 Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permission permanently denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('📍 Location error: $e');
      return null;
    }
  }

  /// Get distance between two points in kilometers
  double getDistanceKm(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude, from.longitude,
      to.latitude, to.longitude,
    ) / 1000;
  }

  /// Sort markers by distance from a given location
  List<MapMarker> sortByDistance(List<MapMarker> markers, LatLng from) {
    final sorted = List<MapMarker>.from(markers);
    sorted.sort((a, b) {
      final distA = getDistanceKm(from, a.position);
      final distB = getDistanceKm(from, b.position);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  /// Find markers within a radius (in km)
  List<MapMarker> findNearby(
    List<MapMarker> markers, 
    LatLng center, 
    double radiusKm,
  ) {
    return markers.where((m) {
      return getDistanceKm(center, m.position) <= radiusKm;
    }).toList();
  }
}

/// Marker data model for farms/products
class MapMarker {
  final String id;
  final LatLng position;
  final String title;
  final String subtitle;
  final String? category;
  final double? price;
  final String? farmerName;
  final String? productId;
  final Map<String, dynamic>? metadata;

  const MapMarker({
    required this.id,
    required this.position,
    required this.title,
    required this.subtitle,
    this.category,
    this.price,
    this.farmerName,
    this.productId,
    this.metadata,
  });
}
