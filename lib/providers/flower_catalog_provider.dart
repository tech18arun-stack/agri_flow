import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/flower_models.dart';

class FlowerCatalogProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  List<FlowerCatalogItem> _flowers = [];
  bool _loading = false;

  List<FlowerCatalogItem> get flowers => _flowers;
  List<FlowerCatalogItem> get activeFlowers =>
      _flowers.where((f) => f.active).toList();
  bool get loading => _loading;

  /// Default flowers used when flower_catalog collection is empty
  static const List<FlowerCatalogItem> _defaultFlowers = [
    FlowerCatalogItem(
        id: 'rose', nameEn: 'Rose', nameTa: 'ரோஜா',
        icon: '🌹', color: '#dc2626', unit: 'kg', sortOrder: 1),
    FlowerCatalogItem(
        id: 'jasmine', nameEn: 'Jasmine', nameTa: 'மல்லிகை',
        icon: '🌼', color: '#fbbf24', unit: 'kg', sortOrder: 2),
    FlowerCatalogItem(
        id: 'marigold', nameEn: 'Marigold', nameTa: 'துளசி மஞ்சள்',
        icon: '🌻', color: '#f59e0b', unit: 'kg', sortOrder: 3),
    FlowerCatalogItem(
        id: 'crossandra', nameEn: 'Crossandra', nameTa: 'கனகாம்பரம்',
        icon: '🧡', color: '#f97316', unit: 'kg', sortOrder: 4),
    FlowerCatalogItem(
        id: 'chrysanthemum', nameEn: 'Chrysanthemum', nameTa: 'சாமந்தி',
        icon: '🌸', color: '#ec4899', unit: 'kg', sortOrder: 5),
    FlowerCatalogItem(
        id: 'tuberose', nameEn: 'Tuberose', nameTa: 'சம்பங்கி',
        icon: '⚪', color: '#d1d5db', unit: 'kg', sortOrder: 6),
    FlowerCatalogItem(
        id: 'lotus', nameEn: 'Lotus', nameTa: 'தாமரை',
        icon: '🪷', color: '#db2777', unit: 'dozen', sortOrder: 7),
    FlowerCatalogItem(
        id: 'orchid', nameEn: 'Orchid', nameTa: 'ஆர்கிட்',
        icon: '🌺', color: '#7c3aed', unit: 'bunch', sortOrder: 8),
    FlowerCatalogItem(
        id: 'gerbera', nameEn: 'Gerbera', nameTa: 'ஜெர்பேரா',
        icon: '🌸', color: '#ef4444', unit: 'dozen', sortOrder: 9),
    FlowerCatalogItem(
        id: 'carnation', nameEn: 'Carnation', nameTa: 'கார்னேஷன்',
        icon: '🌺', color: '#f43f5e', unit: 'bunch', sortOrder: 10),
    FlowerCatalogItem(
        id: 'anthurium', nameEn: 'Anthurium', nameTa: 'அந்துரியம்',
        icon: '🌺', color: '#b91c1c', unit: 'piece', sortOrder: 11),
    FlowerCatalogItem(
        id: 'banana_flower', nameEn: 'Banana Flower', nameTa: 'வாழைப்பூ',
        icon: '🌸', color: '#92400e', unit: 'piece', sortOrder: 12),
  ];

  Future<void> loadCatalog() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerCatalogCollectionId,
        queries: [Query.orderAsc('sortOrder'), Query.limit(100)],
      );
      _flowers = result.documents.isEmpty
          ? _defaultFlowers
          : result.documents
              .map((doc) => FlowerCatalogItem.fromDocument(doc.data, doc.$id))
              .toList();
    } catch (e) {
      debugPrint('❌ Failed to load flower catalog: $e — using defaults');
      _flowers = _defaultFlowers;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addFlower(FlowerCatalogItem flower) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerCatalogCollectionId,
        documentId: flower.id,
        data: flower.toMap(),
      );
      await loadCatalog();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to add flower: $e');
      return false;
    }
  }

  Future<bool> updateFlower(String id, Map<String, dynamic> data) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerCatalogCollectionId,
        documentId: id,
        data: data,
      );
      await loadCatalog();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update flower: $e');
      return false;
    }
  }

  Future<bool> deleteFlower(String id) async {
    try {
      await _svc.db.deleteDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerCatalogCollectionId,
        documentId: id,
      );
      await loadCatalog();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete flower: $e');
      return false;
    }
  }
}
