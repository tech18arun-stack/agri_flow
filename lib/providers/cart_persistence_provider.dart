import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/models.dart';

class CartPersistenceProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  final List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get loading => _loading;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get shipping => _items.isNotEmpty ? 45 : 0;
  double get platformFee => _items.isNotEmpty ? 12 : 0;
  double get total => subtotal + shipping + platformFee;

  Future<void> loadCart(String customerId) async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.cartCollectionId,
        queries: [Query.equal('customerId', customerId), Query.limit(100)],
      );

      _items.clear();
      for (final doc in res.documents) {
        try {
          final productDoc = await _svc.db.getDocument(
            databaseId: _svc.databaseId,
            collectionId: AppwriteConfig.productsCollectionId,
            documentId: doc.data['productId'] ?? '',
          );
          final product = ProductModel(
            id: productDoc.$id,
            name: productDoc.data['name'] ?? '',
            nameTa: productDoc.data['nameTa'] ?? '',
            category: productDoc.data['category'] ?? '',
            price: (productDoc.data['price'] as num?)?.toDouble() ?? 0,
            quantity: (productDoc.data['quantity'] as num?)?.toDouble() ?? 0,
            unit: productDoc.data['unit'] ?? 'kg',
            organic: productDoc.data['organic'] ?? false,
            location: productDoc.data['location'] ?? '',
            farmerName: productDoc.data['farmerName'] ?? '',
            farmerId: productDoc.data['farmerId'] ?? '',
          );
          _items.add(CartItem(
            product: product,
            quantity: (doc.data['quantity'] as num?)?.toInt() ?? 1,
          ));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String customerId, String customerName, ProductModel product, {int qty = 1}) async {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity += qty;
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }

    try {
      if (!_svc.isInitialized) await _svc.init();

      // Check if already in cart
      final existing = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.cartCollectionId,
        queries: [Query.equal('customerId', customerId), Query.equal('productId', product.id), Query.limit(1)],
      );

      if (existing.documents.isNotEmpty) {
        final currentQty = _items.firstWhere((i) => i.product.id == product.id).quantity;
        await _svc.db.updateDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.cartCollectionId,
          documentId: existing.documents.first.$id,
          data: {'quantity': currentQty},
        );
      } else {
        await _svc.db.createDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.cartCollectionId,
          documentId: ID.unique(),
          data: {
            'customerId': customerId,
            'customerName': customerName,
            'productId': product.id,
            'quantity': qty,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String customerId, String productId) async {
    _items.removeWhere((i) => i.product.id == productId);

    try {
      final existing = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.cartCollectionId,
        queries: [Query.equal('customerId', customerId), Query.equal('productId', productId), Query.limit(1)],
      );
      if (existing.documents.isNotEmpty) {
        await _svc.db.deleteDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.cartCollectionId,
          documentId: existing.documents.first.$id,
        );
      }
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
    notifyListeners();
  }

  Future<void> clearCart(String customerId) async {
    _items.clear();
    try {
      final existing = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.cartCollectionId,
        queries: [Query.equal('customerId', customerId), Query.limit(100)],
      );
      for (final doc in existing.documents) {
        await _svc.db.deleteDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.cartCollectionId,
          documentId: doc.$id,
        );
      }
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
    notifyListeners();
  }
}
