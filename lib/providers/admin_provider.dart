import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/models.dart';

class AdminProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  bool _loading = false;

  int _totalFarmers = 0;
  int _totalMerchants = 0;
  final int _totalCustomers = 0;
  double _monthlySales = 0.0;
  int _moderationQueue = 0;

  List<UserModel> _users = [];
  List<ProductModel> _pendingProducts = [];
  List<ProductTemplateModel> _productTemplates = [];

  int get totalFarmers => _totalFarmers;
  int get totalMerchants => _totalMerchants;
  int get totalCustomers => _totalCustomers;
  double get monthlySales => _monthlySales;
  int get moderationQueue => _moderationQueue;
  bool get loading => _loading;
  List<UserModel> get users => _users;
  List<ProductModel> get pendingProducts => _pendingProducts;
  List<ProductTemplateModel> get productTemplates => _productTemplates;

  Future<void> loadStats() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      final farmers = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('role', 'farmer'), Query.limit(1)],
      );
      _totalFarmers = farmers.total;

      final merchants = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('role', 'merchant'), Query.limit(1)],
      );
      _totalMerchants = merchants.total;

      final moderation = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        queries: [Query.equal('status', 'pending'), Query.limit(1)],
      );
      _moderationQueue = moderation.total;

      try {
        final orders = await _svc.db.listDocuments(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          queries: [Query.limit(100)],
        );
        _monthlySales = orders.documents
            .fold(0.0, (sum, doc) => sum + (doc.data['totalAmount'] ?? 0.0));
      } catch (_) {}
    } catch (e) {
      debugPrint('Error loading admin stats: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.orderDesc('\$createdAt'), Query.limit(100)],
      );
      _users = res.documents.map((doc) => _parseUser(doc)).toList();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingProducts() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        // Assuming products have a status field
        queries: [
          Query.equal('status', 'pending'),
          Query.orderDesc('\$createdAt')
        ],
      );
      _pendingProducts =
          res.documents.map((doc) => _parseProduct(doc)).toList();
    } catch (e) {
      debugPrint('Error loading pending products: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProductStatus(String id, String status) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: id,
        data: {'status': status},
      );
      await loadPendingProducts();
      await loadStats();
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  Future<void> updateUserStatus(String id, String status) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: id,
        data: {'status': status},
      );
      await loadUsers();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  // --- Catalog Management ---

  Future<void> loadProductTemplates() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productTemplatesCollectionId,
        queries: [Query.orderAsc('sortOrder'), Query.limit(100)],
      );
      _productTemplates = res.documents
          .map((doc) => ProductTemplateModel.fromDocument(doc.data, doc.$id))
          .toList();
    } catch (e) {
      debugPrint('Error loading product templates: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProductTemplate(
      String id, Map<String, dynamic> data) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productTemplatesCollectionId,
        documentId: id,
        data: data,
      );
      await loadProductTemplates();
      return true;
    } catch (e) {
      debugPrint('Error updating template: $e');
      return false;
    }
  }

  Future<bool> createProductTemplate(
      String id, Map<String, dynamic> data) async {
    try {
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productTemplatesCollectionId,
        documentId: id,
        data: data,
      );
      await loadProductTemplates();
      return true;
    } catch (e) {
      debugPrint('Error creating template: $e');
      return false;
    }
  }

  Future<bool> deleteProductTemplate(String id) async {
    try {
      await _svc.db.deleteDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productTemplatesCollectionId,
        documentId: id,
      );
      await loadProductTemplates();
      return true;
    } catch (e) {
      debugPrint('Error deleting template: $e');
      return false;
    }
  }

  UserModel _parseUser(aw.Document doc) {
    UserRole role = UserRole.customer;
    final r = doc.data['role']?.toString().toLowerCase();
    if (r == 'farmer') role = UserRole.farmer;
    if (r == 'merchant') role = UserRole.merchant;
    if (r == 'admin') role = UserRole.admin;

    return UserModel(
      id: doc.$id,
      name: doc.data['name'] ?? '',
      email: doc.data['email'] ?? '',
      role: role,
      district: doc.data['district'] ?? '',
      status: doc.data['status'] ?? 'active',
    );
  }

  ProductModel _parseProduct(aw.Document doc) {
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
      farmerName: doc.data['farmerName'] ?? '',
      farmerId: doc.data['farmerId'] ?? '',
      imageUrl: doc.data['imageUrl']?.isNotEmpty == true
          ? doc.data['imageUrl']
          : null,
      rating: (doc.data['rating'] as num?)?.toDouble() ?? 0,
      reviews: doc.data['reviews'] ?? 0,
    );
  }
}
