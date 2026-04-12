import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../data/models.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';

/// Service to fetch product templates from Appwrite database
class ProductTemplateService {
  static final ProductTemplateService _instance =
      ProductTemplateService._internal();
  factory ProductTemplateService() => _instance;
  ProductTemplateService._internal();

  static ProductTemplateService get instance => _instance;
  final _svc = AppwriteService.instance;
  List<ProductTemplateModel>? _cache;

  /// Get all product templates from database (cached)
  Future<List<ProductTemplateModel>> getAllTemplates() async {
    if (_cache != null && _cache!.isNotEmpty) return _cache!;

    try {
      if (!_svc.isInitialized) await _svc.init();

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.productTemplatesCollectionId,
        queries: [
          Query.equal('active', true),
          Query.orderAsc('sortOrder'),
        ],
      );

      _cache = result.documents
          .map((doc) => ProductTemplateModel.fromDocument(doc.data, doc.$id))
          .toList();
      debugPrint('✅ Loaded ${_cache!.length} product templates from database');
      return _cache!;
    } catch (e) {
      debugPrint('❌ Failed to load product templates: $e');
      return [];
    }
  }

  /// Get templates by category
  Future<List<ProductTemplateModel>> getByCategory(String category) async {
    final all = await getAllTemplates();
    if (category == 'all') return all;
    return all.where((t) => t.category == category).toList();
  }

  /// Search templates by name (EN + Tamil)
  Future<List<ProductTemplateModel>> search(String query) async {
    final all = await getAllTemplates();
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all
        .where((t) =>
            t.nameEn.toLowerCase().contains(lowerQuery) ||
            t.nameTa.contains(query))
        .toList();
  }

  /// Get template by ID
  Future<ProductTemplateModel?> getById(String id) async {
    final all = await getAllTemplates();
    return all.where((t) => t.id == id).firstOrNull;
  }

  /// Clear cache (force reload)
  void clearCache() {
    _cache = null;
  }

  /// Get unique categories
  Future<List<String>> getCategories() async {
    final all = await getAllTemplates();
    return all.map((t) => t.category).toSet().toList();
  }
}
