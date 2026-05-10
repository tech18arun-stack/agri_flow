import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/models.dart';

class HarvestProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  List<HarvestPreviewModel> _all = [];
  List<HarvestPreviewModel> _farmerHarvests = [];
  bool _loading = false;
  String? _error;

  List<HarvestPreviewModel> get all => _all;
  List<HarvestPreviewModel> get farmerHarvests => _farmerHarvests;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.harvestPreviewsTableId,
        queries: [Query.orderDesc('expectedDate')],
      );
      _all = result.documents.map(_parseHarvest).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to load harvests: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadFarmerHarvests(String farmerId) async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.harvestPreviewsTableId,
        queries: [
          Query.equal('farmerId', farmerId),
          Query.orderDesc('createdAt'),
        ],
      );
      _farmerHarvests = result.documents.map(_parseHarvest).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to load farmer harvests: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createHarvest(HarvestPreviewModel harvest) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.harvestPreviewsTableId,
        documentId: ID.unique(),
        data: {
          'farmerId': harvest.farmerId,
          'cropName': harvest.cropName,
          'cropNameTa': harvest.cropNameTa,
          'expectedDate': harvest.expectedDate.toIso8601String(),
          'expectedYield': harvest.expectedYield,
          'unit': harvest.unit,
          'interestCount': harvest.interestCount,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      await loadFarmerHarvests(harvest.farmerId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to create harvest: $e');
      return false;
    }
  }

  Future<void> addInterest(String harvestId) async {
    try {
      final h = _all.firstWhere((element) => element.id == harvestId);
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.harvestPreviewsTableId,
        documentId: harvestId,
        data: {'interestCount': h.interestCount + 1},
      );
      await loadAll();
    } catch (e) {
      debugPrint('❌ Failed to add interest: $e');
    }
  }

  HarvestPreviewModel _parseHarvest(aw.Document doc) {
    return HarvestPreviewModel(
      id: doc.$id,
      farmerId: doc.data['farmerId'] ?? '',
      cropName: doc.data['cropName'] ?? '',
      cropNameTa: doc.data['cropNameTa'] ?? '',
      expectedDate: doc.data['expectedDate'] != null
          ? DateTime.parse(doc.data['expectedDate'])
          : DateTime.now(),
      expectedYield: (doc.data['expectedYield'] as num?)?.toDouble() ?? 0,
      unit: doc.data['unit'] ?? 'kg',
      interestCount: doc.data['interestCount'] ?? 0,
      createdAt: doc.data['createdAt'] != null
          ? DateTime.parse(doc.data['createdAt'])
          : DateTime.now(),
    );
  }
}
