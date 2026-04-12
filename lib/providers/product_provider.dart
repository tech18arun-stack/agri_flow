import 'dart:math';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:latlong2/latlong.dart';
import '../data/models.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../services/map_service.dart';

class ProductProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  List<ProductModel> _products = [];
  bool _loading = false;
  String? _error;

  List<ProductModel> get all => _products;
  bool get loading => _loading;
  String? get error => _error;

  /// Load all products from database only
  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        queries: [Query.orderDesc('createdAt')],
      );

      _products = result.documents.map(_parseDoc).toList();
    } catch (e) {
      _error = 'Failed to load products: $e';
      debugPrint('❌ Failed to load products: $e');
      _products = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Load products by category
  Future<void> loadByCategory(String category) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        queries: [
          Query.equal('category', category),
          Query.orderDesc('createdAt'),
        ],
      );

      _products = result.documents.map(_parseDoc).toList();
    } catch (e) {
      _error = 'Failed to load products: $e';
      debugPrint('❌ Failed to load products by category: $e');
      _products = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Search products
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadAll();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        queries: [Query.search('name', query)],
      );

      _products = result.documents.map(_parseDoc).toList();
    } catch (e) {
      _error = 'Failed to search products: $e';
      debugPrint('❌ Failed to search products: $e');
      _products = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add a product to Appwrite with optional lat/lng location and address
  Future<String?> addProduct({
    required String name,
    required String nameTa,
    required String category,
    required double price,
    required double quantity,
    required String unit,
    required bool organic,
    required String location,
    String? address,
    String? imageUrl,
    required String farmerId,
    required String farmerName,
    required String harvestedDate,
    double? lat,
    double? lng,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final data = {
        'name': name,
        'nameTa': nameTa,
        'category': category,
        'price': price,
        'quantity': quantity,
        'unit': unit,
        'organic': organic,
        'location': location,
        'address': address ?? '',
        'imageUrl': imageUrl ?? '',
        'farmerId': farmerId,
        'farmerName': farmerName,
        'harvestedDate': harvestedDate,
        'rating': 0.0,
        'reviews': 0,
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add lat/lng if provided
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;

      final doc = await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        documentId: ID.unique(),
        data: data,
      );

      // Also log price to price_logs for price engine
      try {
        await _svc.db.createDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.priceLogsCollectionId,
          documentId: ID.unique(),
          data: {
            'productId': doc.$id,
            'productName': name,
            'farmerId': farmerId,
            'farmerName': farmerName,
            'price': price,
            'quantity': quantity,
            'unit': unit,
            'district': location,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
        debugPrint('💰 Price logged for $name at ₹$price in $location');
      } catch (e) {
        debugPrint('⚠️  Failed to log price: $e');
        // Non-fatal, product is still saved
      }

      _loading = false;
      await loadAll();
      return doc.$id;
    } catch (e) {
      _error = 'Failed to add product: $e';
      debugPrint('❌ Failed to add product: $e');
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update a product
  Future<bool> updateProduct({
    required String productId,
    String? name,
    String? nameTa,
    String? category,
    double? price,
    double? quantity,
    String? unit,
    bool? organic,
    String? location,
    String? address,
    String? imageUrl,
    String? status,
    double? lat,
    double? lng,
  }) async {
    try {
      if (!_svc.isInitialized) await _svc.init();

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (nameTa != null) data['nameTa'] = nameTa;
      if (category != null) data['category'] = category;
      if (price != null) data['price'] = price;
      if (quantity != null) data['quantity'] = quantity;
      if (unit != null) data['unit'] = unit;
      if (organic != null) data['organic'] = organic;
      if (location != null) data['location'] = location;
      if (address != null) data['address'] = address;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (status != null) data['status'] = status;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;

      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        documentId: productId,
        data: data,
      );

      await loadAll();
      debugPrint('✅ Product updated: $productId');
      return true;
    } catch (e) {
      _error = 'Failed to update product: $e';
      debugPrint('❌ Failed to update product: $e');
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      if (!_svc.isInitialized) await _svc.init();

      await _svc.db.deleteDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsTableId,
        documentId: productId,
      );

      await loadAll();
      debugPrint('✅ Product deleted: $productId');
      return true;
    } catch (e) {
      _error = 'Failed to delete product: $e';
      debugPrint('❌ Failed to delete product: $e');
      return false;
    }
  }

  /// Get farmer's own products
  List<ProductModel> getFarmerProducts(String farmerId) {
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  ProductModel _parseDoc(aw.Document doc) {
    return ProductModel(
      id: doc.$id,
      name: doc.data['name'] ?? '',
      nameTa: doc.data['nameTa'] ?? '',
      category: doc.data['category'] ?? '',
      price: (doc.data['price'] as num?)?.toDouble() ?? 0,
      quantity: (doc.data['quantity'] as num?)?.toDouble() ?? 0,
      unit: doc.data['unit'] ?? 'kg',
      organic: doc.data['organic'] ?? false,
      location: doc.data['location'] ?? '',
      address: doc.data['address']?.isNotEmpty == true ? doc.data['address'] : null,
      farmerName: doc.data['farmerName'] ?? '',
      farmerId: doc.data['farmerId'] ?? '',
      imageUrl: doc.data['imageUrl']?.isNotEmpty == true ? doc.data['imageUrl'] : null,
      rating: (doc.data['rating'] as num?)?.toDouble() ?? 0,
      reviews: doc.data['reviews'] ?? 0,
      lat: (doc.data['lat'] as num?)?.toDouble(),
      lng: (doc.data['lng'] as num?)?.toDouble(),
      harvestedDate: doc.data['harvestedDate'] != null
          ? DateTime.tryParse(doc.data['harvestedDate'])
          : null,
    );
  }

  /// Get products near a location (within radius in km)
  List<ProductModel> getNearby(double lat, double lng, double radiusKm) {
    return _products.where((p) {
      if (p.lat == null || p.lng == null) return false;
      final distance = _calculateDistance(lat, lng, p.lat!, p.lng!);
      return distance <= radiusKm;
    }).toList();
  }

  /// Convert products to map markers
  List<MapMarker> toMapMarkers({double? userLat, double? userLng}) {
    return _products.where((p) => p.lat != null && p.lng != null).map((p) {
      String distanceText = '';
      if (userLat != null && userLng != null) {
        final km = _calculateDistance(userLat, userLng, p.lat!, p.lng!);
        distanceText = '${km.toStringAsFixed(1)}km';
      }
      return MapMarker(
        id: p.id,
        position: LatLng(p.lat!, p.lng!),
        title: p.name,
        subtitle: distanceText.isNotEmpty ? '$distanceText • ${p.location}' : p.location,
        category: p.category,
        price: p.price,
        farmerName: p.farmerName,
        productId: p.id,
        metadata: {
          'organic': p.organic,
          'quantity': p.quantity,
          'unit': p.unit,
          'rating': p.rating,
          'reviews': p.reviews,
        },
      );
    }).toList();
  }

  /// Calculate distance between two coordinates in kilometers (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
}
