import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_service.dart';
import '../core/constants/colors.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final String title;

  const MapLocationPicker({
    super.key,
    this.initialLocation,
    this.title = 'Select Location',
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? MapService.tamilNaduCenter;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    final location = await MapService.instance.getCurrentLocation();
    if (mounted && location != null) {
      setState(() {
        _selectedLocation = location;
        _loading = false;
      });
      _mapController.move(location, 15.0);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedLocation),
            child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.w900, color: C.primary)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? MapService.tamilNaduCenter,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapService.tileUrl,
                userAgentPackageName: 'com.farm.agri_flow',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Center Crosshair (Optional but helpful)
          const IgnorePointer(
            child: Center(
              child: Icon(Icons.add, color: Colors.black26, size: 24),
            ),
          ),

          // Instructions
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap on the map to set your precise location',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'gps',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child: _loading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, color: C.primary),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'confirm',
                  onPressed: () => Navigator.pop(context, _selectedLocation),
                  backgroundColor: C.primary,
                  label: const Text('SET LOCATION', style: TextStyle(fontWeight: FontWeight.w900)),
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
