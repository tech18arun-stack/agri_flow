import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/map_service.dart';
import '../../core/constants/colors.dart';

/// Reusable map widget for displaying farms, products, and location
class AgriMap extends StatefulWidget {
  final List<MapMarker> markers;
  final LatLng? initialCenter;
  final double initialZoom;
  final bool showCurrentLocation;
  final void Function(MapMarker)? onMarkerTap;
  final void Function(LatLng)? onMapTap;
  final bool interactive;

  const AgriMap({
    super.key,
    this.markers = const [],
    this.initialCenter,
    this.initialZoom = 12,
    this.showCurrentLocation = true,
    this.onMarkerTap,
    this.onMapTap,
    this.interactive = true,
  });

  @override
  State<AgriMap> createState() => _AgriMapState();
}

class _AgriMapState extends State<AgriMap> {
  LatLng? _currentLocation;
  final MapService _mapService = MapService();

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    final location = await _mapService.getCurrentLocation();
    if (mounted && location != null) {
      setState(() => _currentLocation = location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentLocation ?? widget.initialCenter ?? MapService.tamilNaduCenter;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.initialZoom,
        maxZoom: 19,
        interactionOptions: widget.interactive
            ? const InteractionOptions()
            : const InteractionOptions(flags: InteractiveFlag.none),
        onTap: widget.onMapTap != null
            ? (_, latLng) => widget.onMapTap!(latLng)
            : null,
      ),
      children: [
        // Map tiles
        TileLayer(
          urlTemplate: MapService.tileUrl,
          userAgentPackageName: 'com.farm.agri_flow',
          tileProvider: NetworkTileProvider(),
          maxZoom: 19,
        ),
        
        // Current location marker
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: C.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),

        // Farm/Product markers
        if (widget.markers.isNotEmpty)
          MarkerLayer(
            markers: widget.markers.map((marker) {
              return Marker(
                point: marker.position,
                width: 80,
                height: 100,
                child: GestureDetector(
                  onTap: () => widget.onMarkerTap?.call(marker),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              marker.title,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF002b02),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (marker.price != null)
                              Text(
                                '₹${marker.price}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF735a3a),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.location_on, color: Color(0xFF002b02), size: 28),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Simple location picker widget for farmers to select farm location
class LocationPicker extends StatefulWidget {
  final void Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              AgriMap(
                initialCenter: _selectedLocation ?? MapService.tamilNaduCenter,
                initialZoom: _selectedLocation != null ? 15 : 7,
                showCurrentLocation: true,
                onMapTap: (latLng) {
                  setState(() => _selectedLocation = latLng);
                  widget.onLocationSelected(latLng);
                },
              ),
              // Center pin overlay
              if (_selectedLocation != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final location = await MapService.instance.getCurrentLocation();
                    if (location != null) {
                      setState(() => _selectedLocation = location);
                      widget.onLocationSelected(location);
                    }
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
