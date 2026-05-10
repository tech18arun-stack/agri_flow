import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../services/location_permission_service.dart';
import '../services/map_service.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  String _locality = 'Madurai'; // Default fallback
  bool _loading = false;
  String? _error;

  LatLng? get currentPosition => _currentPosition;
  String get locality => _locality;
  bool get loading => _loading;
  String? get error => _error;

  LocationProvider() {
    init();
  }

  Future<void> init() async {
    await fetchLocation();
  }

  Future<void> fetchLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await LocationPermissionService.instance.getCurrentPosition();
      if (position != null) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        await _reverseGeocode(position.latitude, position.longitude);
      } else {
        _error = 'Location access denied or unavailable.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    try {
      final apiKey = MapService.maptilerApiKey;
      final url = 'https://api.maptiler.com/geocoding/$lon,$lat.json?key=$apiKey&limit=1';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          // Try to get town/city/district
          final context = feature['context'] as List?;
          String? discoveredLocality;
          
          if (context != null) {
            for (var item in context) {
              if (item['id'].toString().startsWith('place') || 
                  item['id'].toString().startsWith('district')) {
                discoveredLocality = item['text'];
                break;
              }
            }
          }
          
          _locality = discoveredLocality ?? feature['text'] ?? 'Madurai';
        }
      }
    } catch (e) {
      debugPrint('📍 Reverse geocoding error: $e');
      // Keep fallback
    }
  }

  void setManualLocality(String name) {
    _locality = name;
    notifyListeners();
  }

  Future<void> setManualPosition(LatLng position) async {
    _currentPosition = position;
    _loading = true;
    notifyListeners();
    await _reverseGeocode(position.latitude, position.longitude);
    _loading = false;
    notifyListeners();
  }
}
