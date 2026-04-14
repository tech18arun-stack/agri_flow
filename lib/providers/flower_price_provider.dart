import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/flower_models.dart';

class FlowerPriceProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;

  List<FlowerPriceEntry> _todayPrices = [];
  List<FlowerPriceEntry> _yesterdayPrices = [];
  List<FlowerPriceEntry> _allPrices = []; // admin: all districts
  bool _loading = false;
  bool _saving = false;
  String? _error;
  String? _successMessage;

  List<FlowerPriceEntry> get todayPrices => _todayPrices;
  List<FlowerPriceEntry> get yesterdayPrices => _yesterdayPrices;
  List<FlowerPriceEntry> get allPrices => _allPrices;
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  String? get successMessage => _successMessage;

  int get publishedCount => _todayPrices.where((p) => p.isPublished).length;
  int get draftCount => _todayPrices.where((p) => p.isDraft).length;
  int get totalCount => _todayPrices.length;

  /// Returns 'YYYY-MM-DD' for the given DateTime
  static String dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Deterministic document ID for a flower+district+date combo
  static String buildDocId(String flowerId, String district, String date) {
    final dSlug = district.toLowerCase().replaceAll(' ', '_');
    final fSlug = flowerId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return '${fSlug}_${dSlug}_$date';
  }

  FlowerPriceEntry? getPriceFor(String flowerId) {
    try {
      return _todayPrices.firstWhere((p) => p.flowerId == flowerId);
    } catch (_) {
      return null;
    }
  }

  FlowerPriceEntry? getYesterdayPriceFor(String flowerId) {
    try {
      return _yesterdayPrices.firstWhere((p) => p.flowerId == flowerId);
    } catch (_) {
      return null;
    }
  }

  // ==================== LOAD ====================

  Future<void> loadPrices(String district, {DateTime? date}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final dateStr = dateKey(date ?? DateTime.now());
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerPricesCollectionId,
        queries: [
          Query.equal('district', district),
          Query.equal('date', dateStr),
          Query.limit(100),
        ],
      );
      _todayPrices = result.documents
          .map((doc) => FlowerPriceEntry.fromDocument(doc.data, doc.$id))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to load flower prices: $e');
      _todayPrices = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadYesterdayPrices(String district) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateStr = dateKey(yesterday);
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerPricesCollectionId,
        queries: [
          Query.equal('district', district),
          Query.equal('date', dateStr),
          Query.equal('status', 'published'),
          Query.limit(100),
        ],
      );
      _yesterdayPrices = result.documents
          .map((doc) => FlowerPriceEntry.fromDocument(doc.data, doc.$id))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to load yesterday prices: $e');
      _yesterdayPrices = [];
    }
    notifyListeners();
  }

  /// Admin: load all district prices for a given date
  Future<void> loadAllDistrictPrices({DateTime? date}) async {
    _loading = true;
    notifyListeners();
    final dateStr = dateKey(date ?? DateTime.now());
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.flowerPricesCollectionId,
        queries: [
          Query.equal('date', dateStr),
          Query.orderAsc('district'),
          Query.limit(500),
        ],
      );
      _allPrices = result.documents
          .map((doc) => FlowerPriceEntry.fromDocument(doc.data, doc.$id))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to load all district prices: $e');
      _allPrices = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ==================== SAVE ====================

  /// Save/update a single flower price entry (upsert by deterministic ID)
  Future<bool> savePrice({
    required String flowerId,
    required String flowerName,
    required String flowerNameTa,
    required String district,
    required double priceMin,
    required double priceMax,
    required String unit,
    required String updatedById,
    required String updatedByName,
    String status = 'draft',
  }) async {
    if (!_svc.isInitialized) await _svc.init();

    final today = DateTime.now();
    final dateStr = dateKey(today);
    final id = buildDocId(flowerId, district, dateStr);

    final existing = getPriceFor(flowerId);

    try {
      if (existing?.docId != null) {
        // Update existing
        await _svc.db.updateDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.flowerPricesCollectionId,
          documentId: existing!.docId!,
          data: {
            'priceMin': priceMin,
            'priceMax': priceMax,
            'status': status,
            'updatedById': updatedById,
            'updatedByName': updatedByName,
          },
        );
        final idx = _todayPrices.indexWhere((p) => p.flowerId == flowerId);
        if (idx >= 0) {
          _todayPrices[idx] = existing.copyWith(
            priceMin: priceMin,
            priceMax: priceMax,
            status: status,
          );
        }
      } else {
        // Create with deterministic ID
        try {
          final doc = await _svc.db.createDocument(
            databaseId: _svc.databaseId,
            collectionId: AppwriteConfig.flowerPricesCollectionId,
            documentId: id,
            data: {
              'flowerId': flowerId,
              'flowerName': flowerName,
              'flowerNameTa': flowerNameTa,
              'district': district,
              'priceMin': priceMin,
              'priceMax': priceMax,
              'unit': unit,
              'status': status,
              'date': dateStr,
              'updatedById': updatedById,
              'updatedByName': updatedByName,
              'createdAt': today.toIso8601String(),
            },
          );
          _todayPrices.add(FlowerPriceEntry.fromDocument(doc.data, doc.$id));
        } catch (_) {
          // Doc may already exist in DB but not in local state — try update
          await _svc.db.updateDocument(
            databaseId: _svc.databaseId,
            collectionId: AppwriteConfig.flowerPricesCollectionId,
            documentId: id,
            data: {
              'priceMin': priceMin,
              'priceMax': priceMax,
              'status': status,
              'updatedById': updatedById,
              'updatedByName': updatedByName,
            },
          );
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save: $e';
      debugPrint('❌ savePrice error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Bulk save all prices from the dashboard table
  Future<int> saveAllPrices({
    required String district,
    required List<FlowerCatalogItem> flowers,
    required Map<String, ({double min, double max})> prices,
    required String updatedById,
    required String updatedByName,
    String status = 'draft',
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();

    int successCount = 0;
    for (final flower in flowers) {
      final p = prices[flower.id];
      if (p == null || (p.min <= 0 && p.max <= 0)) continue;

      final ok = await savePrice(
        flowerId: flower.id,
        flowerName: flower.nameEn,
        flowerNameTa: flower.nameTa,
        district: district,
        priceMin: p.min,
        priceMax: p.max,
        unit: flower.unit,
        updatedById: updatedById,
        updatedByName: updatedByName,
        status: status,
      );
      if (ok) successCount++;
    }

    _saving = false;
    if (successCount > 0) {
      _successMessage = status == 'published'
          ? '$successCount prices published! ✅'
          : '$successCount prices saved as draft';
    }
    notifyListeners();
    return successCount;
  }

  /// Publish all draft prices for a district today
  Future<bool> publishAll(String district) async {
    _saving = true;
    notifyListeners();

    final drafts = _todayPrices.where((p) => p.isDraft && p.docId != null).toList();
    int count = 0;
    for (final entry in drafts) {
      try {
        await _svc.db.updateDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.flowerPricesCollectionId,
          documentId: entry.docId!,
          data: {'status': 'published'},
        );
        final idx = _todayPrices.indexWhere((p) => p.flowerId == entry.flowerId);
        if (idx >= 0) {
          _todayPrices[idx] = entry.copyWith(status: 'published');
        }
        count++;
      } catch (e) {
        debugPrint('❌ publish error: $e');
      }
    }

    _successMessage = 'Published $count prices ✅';
    _saving = false;
    notifyListeners();
    return count > 0;
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
