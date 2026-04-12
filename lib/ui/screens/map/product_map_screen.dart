import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../services/map_service.dart';
import '../../../core/constants/colors.dart';

class ProductMapScreen extends StatefulWidget {
  final LatLng? initialCenter;
  final String? category;

  const ProductMapScreen({super.key, this.initialCenter, this.category});

  @override
  State<ProductMapScreen> createState() => _ProductMapScreenState();
}

class _ProductMapScreenState extends State<ProductMapScreen> {
  LatLng? _currentLocation;
  bool _locationLoading = false;
  final MapController _mapController = MapController();
  List<MapMarker> _markers = [];
  MapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadProducts();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _locationLoading = true);

    try {
      final locationService = MapService.instance;
      final location = await locationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _currentLocation = location;
          _locationLoading = false;
        });

        // Move map to current location
        if (location != null) {
          _mapController.move(location, 12.0);
        }
      }
    } catch (e) {
      debugPrint('📍 Location error: $e');
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    final products = context.read<ProductProvider>().all;

    final markers = products.where((p) => p.lat != null && p.lng != null).map((product) {
      return MapMarker(
        id: product.id,
        position: LatLng(product.lat!, product.lng!),
        title: product.name,
        subtitle: '${product.farmerName} • ${product.location}',
        category: product.category,
        price: product.price,
        farmerName: product.farmerName,
        productId: product.id,
        metadata: {
          'organic': product.organic,
          'quantity': '${product.quantity} ${product.unit}',
          'rating': product.rating,
        },
      );
    }).toList();

    if (mounted) {
      setState(() => _markers = markers);
    }
  }

  void _onMarkerTap(MapMarker marker) {
    setState(() => _selectedMarker = marker);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      default:
        return Icons.eco;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return const Color(0xFF4CAF50);
      case 'fruits':
        return const Color(0xFFFF5722);
      case 'grains':
        return const Color(0xFFFFC107);
      default:
        return C.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.initialCenter ?? MapService.tamilNaduCenter;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: widget.initialCenter != null ? 12.0 : 7.0,
              onTap: (_, __) => setState(() => _selectedMarker = null),
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: MapService.tileUrl,
                userAgentPackageName: 'com.agriflow.app',
              ),
              // Markers
              MarkerLayer(
                markers: [
                  // Current location marker
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                      ),
                    ),
                  // Product markers
                  ..._markers.map((marker) {
                    final isSelected = _selectedMarker?.id == marker.id;
                    return Marker(
                      point: marker.position,
                      width: isSelected ? 50 : 40,
                      height: isSelected ? 50 : 40,
                      child: GestureDetector(
                        onTap: () => _onMarkerTap(marker),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(marker.category ?? ''),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryColor(marker.category ?? '').withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(marker.category ?? ''),
                              color: Colors.white,
                              size: isSelected ? 24 : 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top Controls
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Location info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (_locationLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.location_on, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentLocation != null
                                  ? 'Using GPS Location'
                                  : 'Tap to get your location',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (!_locationLoading)
                            IconButton(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.refresh, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom marker count
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place, color: C.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_markers.length} farms nearby',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: C.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected marker details
          if (_selectedMarker != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _MarkerDetails(
                marker: _selectedMarker!,
                onTap: () {
                  final product = context
                      .read<ProductProvider>()
                      .all
                      .firstWhere((p) => p.id == _selectedMarker!.productId);
                  Navigator.pushNamed(context, '/product_detail', arguments: product);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MarkerDetails extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback onTap;

  const _MarkerDetails({required this.marker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: C.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    marker.category == 'vegetables'
                        ? Icons.grass
                        : marker.category == 'fruits'
                            ? Icons.apple
                            : Icons.eco,
                    color: C.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        marker.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (marker.price != null)
                  Text(
                    '₹${marker.price!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: C.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (marker.metadata?['organic'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFc8f17a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🌿 Organic',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                if (marker.metadata?['quantity'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      marker.metadata!['quantity']!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (marker.metadata?['rating'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 10, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          marker.metadata!['rating'].toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
