import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';

class InventoryItem {
  final String id;
  final String merchantId;
  final String merchantName;
  final String productId;
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double purchasePrice;
  final double? sellingPrice;
  final String? farmerId;
  final String? farmerName;
  final DateTime purchasedAt;
  final String? location;
  final String status;
  final DateTime? expiryDate;
  final String? imageUrl;

  const InventoryItem({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    this.sellingPrice,
    this.farmerId,
    this.farmerName,
    required this.purchasedAt,
    this.location,
    this.status = 'in_stock',
    this.expiryDate,
    this.imageUrl,
  });

  double get totalValue => purchasePrice * quantity;
  bool get isInStock => status == 'in_stock';
  bool get isLowStock => quantity < 50 && status == 'in_stock';

  factory InventoryItem.fromDocument(aw.Document doc) {
    return InventoryItem(
      id: doc.$id,
      merchantId: doc.data['merchantId'] ?? '',
      merchantName: doc.data['merchantName'] ?? '',
      productId: doc.data['productId'] ?? '',
      productName: doc.data['productName'] ?? '',
      category: doc.data['category'] ?? '',
      quantity: (doc.data['quantity'] as num?)?.toDouble() ?? 0,
      unit: doc.data['unit'] ?? 'kg',
      purchasePrice: (doc.data['purchasePrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (doc.data['sellingPrice'] as num?)?.toDouble(),
      farmerId: doc.data['farmerId'],
      farmerName: doc.data['farmerName'],
      purchasedAt: DateTime.parse(doc.data['purchasedAt']),
      location: doc.data['location'],
      status: doc.data['status'] ?? 'in_stock',
      expiryDate: doc.data['expiryDate'] != null
          ? DateTime.parse(doc.data['expiryDate'])
          : null,
      imageUrl: doc.data['imageUrl'],
    );
  }
}

class InventoryProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  final List<InventoryItem> _items = [];
  bool _loading = false;

  List<InventoryItem> get items => _items;
  bool get loading => _loading;

  int get totalItems => _items.length;
  double get totalStockValue => _items.fold(0, (sum, item) => sum + item.totalValue);
  int get inStockCount => _items.where((i) => i.isInStock).length;
  int get lowStockCount => _items.where((i) => i.isLowStock).length;

  List<InventoryItem> get inStock => _items.where((i) => i.isInStock).toList();
  List<InventoryItem> get lowStock => _items.where((i) => i.isLowStock).toList();

  List<InventoryItem> getByCategory(String category) {
    if (category == 'all') return _items;
    return _items.where((i) => i.category == category).toList();
  }

  List<InventoryItem> search(String query) {
    if (query.isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) =>
        i.productName.toLowerCase().contains(q) ||
        i.category.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> loadInventory(String merchantId) async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        queries: [
          Query.equal('merchantId', merchantId),
          Query.orderDesc('purchasedAt'),
          Query.limit(100),
        ],
      );

      _items.clear();
      _items.addAll(res.documents.map((doc) => InventoryItem.fromDocument(doc)));
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addToInventory({
    required String merchantId,
    required String merchantName,
    required String productId,
    required String productName,
    required String category,
    required double quantity,
    required String unit,
    required double purchasePrice,
    double? sellingPrice,
    String? farmerId,
    String? farmerName,
    String? location,
    DateTime? expiryDate,
    String? imageUrl,
  }) async {
    try {
      if (!_svc.isInitialized) await _svc.init();

      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: ID.unique(),
        data: {
          'merchantId': merchantId,
          'merchantName': merchantName,
          'productId': productId,
          'productName': productName,
          'category': category,
          'quantity': quantity,
          'unit': unit,
          'purchasePrice': purchasePrice,
          if (sellingPrice != null) 'sellingPrice': sellingPrice,
          if (farmerId != null) 'farmerId': farmerId,
          if (farmerName != null) 'farmerName': farmerName,
          'purchasedAt': DateTime.now().toIso8601String(),
          if (location != null) 'location': location,
          'status': 'in_stock',
          if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      await loadInventory(merchantId);
    } catch (e) {
      debugPrint('Error adding to inventory: $e');
    }
  }

  Future<void> updateQuantity(String itemId, double newQuantity) async {
    try {
      final status = newQuantity <= 0 ? 'sold_out' : 'in_stock';
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: {
          'quantity': newQuantity,
          'status': status,
        },
      );

      final idx = _items.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        // Reload to get fresh data
        await loadInventory(_items[idx].merchantId);
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> updateSellingPrice(String itemId, double price) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: {'sellingPrice': price},
      );

      final idx = _items.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        await loadInventory(_items[idx].merchantId);
      }
    } catch (e) {
      debugPrint('Error updating selling price: $e');
    }
  }

  Future<void> markAsSold(String itemId) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: {'status': 'sold_out'},
      );

      final idx = _items.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        await loadInventory(_items[idx].merchantId);
      }
    } catch (e) {
      debugPrint('Error marking as sold: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final idx = _items.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        await _svc.db.deleteDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.inventoryCollectionId,
          documentId: itemId,
        );

        _items.removeAt(idx);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
    }
  }
}



