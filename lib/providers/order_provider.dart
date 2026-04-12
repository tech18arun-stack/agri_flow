import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../data/models.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';

class OrderProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  List<OrderModel> _orders = [];
  List<OrderModel> _customerOrders = [];
  bool _loading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get customerOrders => _customerOrders;
  bool get loading => _loading;
  String? get error => _error;

  /// Load all orders for a farmer
  Future<void> loadFarmerOrders(String farmerId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('farmerId', farmerId),
          Query.orderDesc('createdAt'),
          Query.limit(50),
        ],
      );

      _orders = result.documents.map(_parseOrder).toList();
    } catch (e) {
      // Collection may not exist yet — silently return empty
      if (e.toString().contains('collection_not_found')) {
        debugPrint('📦 Orders collection not yet created in Appwrite');
      } else {
        debugPrint('❌ Failed to load farmer orders: $e');
      }
      _orders = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Load all orders for a customer
  Future<void> loadCustomerOrders(String customerId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('customerId', customerId),
          Query.orderDesc('createdAt'),
          Query.limit(50),
        ],
      );

      _customerOrders = result.documents.map(_parseOrder).toList();
    } catch (e) {
      if (e.toString().contains('collection_not_found')) {
        debugPrint('📦 Orders collection not yet created in Appwrite');
      } else {
        debugPrint('❌ Failed to load customer orders: $e');
      }
      _customerOrders = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Create a new order from cart
  Future<String?> createOrder({
    required String customerId,
    required String customerName,
    required String farmerId,
    required String farmerName,
    required List<CartItem> items,
    required double total,
    required String shippingAddress,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      if (!_svc.isInitialized) await _svc.init();

      final orderItems = items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
      }).toList();

      final doc = await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: ID.unique(),
        data: {
          'customerId': customerId,
          'customerName': customerName,
          'farmerId': farmerId,
          'farmerName': farmerName,
          'items': orderItems,
          'total': total,
          'status': 'pending',
          'shippingAddress': shippingAddress,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await loadFarmerOrders(farmerId);
      return doc.$id;
    } catch (e) {
      _error = 'Failed to create order: $e';
      debugPrint('❌ Failed to create order: $e');
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: orderId,
        data: {'status': status},
      );
      // Reload orders
      if (_orders.isNotEmpty) {
        await loadFarmerOrders(_orders.first.farmerId);
      }
    } catch (e) {
      _error = 'Failed to update order: $e';
      debugPrint('❌ Failed to update order: $e');
    }
  }

  OrderModel _parseOrder(aw.Document doc) {
    final itemsData = doc.data['items'] as List? ?? [];
    final items = itemsData.map((item) => OrderItem(
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      price: (item['price'] as num?)?.toDouble() ?? 0,
      quantity: item['quantity'] ?? 1,
    )).toList();

    return OrderModel(
      id: doc.$id,
      customerId: doc.data['customerId'] ?? '',
      customerName: doc.data['customerName'] ?? '',
      farmerId: doc.data['farmerId'] ?? '',
      farmerName: doc.data['farmerName'] ?? '',
      items: items,
      total: (doc.data['total'] as num?)?.toDouble() ?? 0,
      status: doc.data['status'] ?? 'pending',
      shippingAddress: doc.data['shippingAddress'] ?? '',
      createdAt: doc.data['createdAt'] != null 
          ? DateTime.tryParse(doc.data['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}
