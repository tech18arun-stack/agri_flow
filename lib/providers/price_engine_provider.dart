import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../data/price_engine.dart';

class PriceEngineProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  final bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  // ==================== PRICE LOGS ====================

  Future<List<PriceLog>> getPriceLogs(String productId,
      {String? district}) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      final queries = [
        Query.equal('productId', productId),
        Query.orderDesc('createdAt'),
        Query.limit(50),
      ];
      if (district != null) queries.add(Query.equal('district', district));

      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.priceLogsTableId,
        queries: queries,
      );
      return result.documents.map(_parsePriceLog).toList();
    } catch (e) {
      _error = 'Failed to load price logs: $e';
      debugPrint('❌ Failed to load price logs: $e');
      return [];
    }
  }

  Future<void> addPriceLog(PriceLog log) async {
    try {
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.priceLogsTableId,
        documentId: ID.unique(),
        data: {
          'productId': log.productId,
          'productName': log.productName,
          'farmerId': log.farmerId,
          'farmerName': log.farmerName,
          'price': log.price,
          'quantity': log.quantity,
          'unit': log.unit,
          'district': log.district,
          'createdAt': log.createdAt.toIso8601String(),
        },
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add price log: $e';
      debugPrint('❌ Failed to add price log: $e');
    }
  }

  // ==================== AGGREGATED PRICES ====================

  Future<AggregatedPrice> getAggregated(
      String productId, String district) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.aggregatedPricesTableId,
        queries: [
          Query.equal('productId', productId),
          Query.equal('district', district)
        ],
      );
      if (result.documents.isEmpty) {
        return _calculateFromLogs(productId, district);
      }
      return _parseAggregated(result.documents.first);
    } catch (e) {
      return _calculateFromLogs(productId, district);
    }
  }

  Future<AggregatedPrice> _calculateFromLogs(
      String productId, String district) async {
    try {
      final logs = await getPriceLogs(productId, district: district);
      if (logs.isEmpty) {
        return AggregatedPrice(
            productId: productId,
            productName: '',
            district: district,
            avgPrice: 0,
            minPrice: 0,
            maxPrice: 0,
            totalQuantity: 0,
            sellerCount: 0,
            lastUpdated: DateTime.now(),
            demand: DemandLevel.moderate);
      }
      final prices = logs.map((l) => l.price).toList()..sort();
      final avg = prices.reduce((a, b) => a + b) / prices.length;
      final uniqueFarmers = logs.map((l) => l.farmerId).toSet().length;
      final totalQty = logs.fold(0.0, (sum, l) => sum + l.quantity);
      return AggregatedPrice(
        productId: productId,
        productName: logs.first.productName,
        district: district,
        avgPrice: avg.round().toDouble(),
        minPrice: prices.first,
        maxPrice: prices.last,
        totalQuantity: totalQty,
        sellerCount: uniqueFarmers,
        lastUpdated: logs.first.createdAt,
        demand: _calculateDemand(totalQty, uniqueFarmers),
      );
    } catch (_) {
      return AggregatedPrice(
          productId: productId,
          productName: '',
          district: district,
          avgPrice: 0,
          minPrice: 0,
          maxPrice: 0,
          totalQuantity: 0,
          sellerCount: 0,
          lastUpdated: DateTime.now(),
          demand: DemandLevel.moderate);
    }
  }

  DemandLevel _calculateDemand(double totalQty, int sellers) {
    if (totalQty < 100) return DemandLevel.veryHigh;
    if (totalQty < 300) return DemandLevel.high;
    if (totalQty < 600) return DemandLevel.moderate;
    return DemandLevel.low;
  }

  String getDemandLabel(DemandLevel level) {
    switch (level) {
      case DemandLevel.veryHigh:
        return 'Very High';
      case DemandLevel.high:
        return 'High';
      case DemandLevel.moderate:
        return 'Moderate';
      case DemandLevel.low:
        return 'Low';
    }
  }

  String getDemandLabelTa(DemandLevel level) {
    switch (level) {
      case DemandLevel.veryHigh:
        return 'மிக அதிகம்';
      case DemandLevel.high:
        return 'அதிகம்';
      case DemandLevel.moderate:
        return 'மிதமான';
      case DemandLevel.low:
        return 'குறைவு';
    }
  }

  // ==================== PRICE TRENDS ====================

  Future<PriceTrend> getTrend(String productId, String district,
      {int days = 30}) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.priceTrendsTableId,
        queries: [
          Query.equal('productId', productId),
          Query.equal('district', district),
          Query.orderAsc('date'),
          Query.limit(days),
        ],
      );
      final points = result.documents.map((doc) {
        return PricePoint(
            date: doc.data['date'] != null
                ? DateTime.parse(doc.data['date'])
                : DateTime.now(),
            price: (doc.data['avgPrice'] as num?)?.toDouble() ?? 0);
      }).toList();
      final productName = result.documents.isNotEmpty
          ? result.documents.first.data['productName'] ?? ''
          : '';
      return PriceTrend(
          productId: productId,
          productName: productName,
          district: district,
          points: points);
    } catch (e) {
      _error = 'Failed to load price trend: $e';
      debugPrint('❌ Failed to load price trend: $e');
      return PriceTrend(
          productId: productId,
          productName: '',
          district: district,
          points: []);
    }
  }

  // ==================== DISTRICT COMPARISON ====================

  Future<DistrictPriceComparison> getDistrictComparison(
      String productId) async {
    try {
      if (!_svc.isInitialized) await _svc.init();
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.aggregatedPricesTableId,
        queries: [Query.equal('productId', productId)],
      );
      if (result.documents.isEmpty) {
        return DistrictPriceComparison(
            productId: productId, productName: '', districts: []);
      }
      final districts = result.documents.map((doc) {
        return DistrictPrice(
            name: doc.data['district'] ?? '',
            nameTa: _getDistrictTa(doc.data['district'] ?? ''),
            avgPrice: (doc.data['avgPrice'] as num?)?.toDouble() ?? 0,
            minPrice: (doc.data['minPrice'] as num?)?.toDouble() ?? 0,
            maxPrice: (doc.data['maxPrice'] as num?)?.toDouble() ?? 0,
            sellers: doc.data['sellerCount'] ?? 0);
      }).toList()
        ..sort((a, b) => a.avgPrice.compareTo(b.avgPrice));
      return DistrictPriceComparison(
          productId: productId,
          productName: result.documents.first.data['productName'] ?? '',
          districts: districts);
    } catch (_) {
      return DistrictPriceComparison(
          productId: productId, productName: '', districts: []);
    }
  }

  String _getDistrictTa(String district) {
    switch (district) {
      case 'Salem':
        return 'சேலம்';
      case 'Coimbatore':
        return 'கோயம்புத்தூர்';
      case 'Madurai':
        return 'மதுரை';
      case 'Erode':
        return 'ஈரோடு';
      case 'Nilgiris':
        return 'நீலகிரி';
      case 'Thanjavur':
        return 'தஞ்சாவூர்';
      case 'Trichy':
        return 'திருச்சி';
      case 'Dindigul':
        return 'திண்டுக்கல்';
      case 'Theni':
        return 'தேனி';
      case 'Chennai':
        return 'சென்னை';
      default:
        return district;
    }
  }

  // ==================== INSIGHTS ====================

  Future<List<PriceInsight>> getInsights(
      String productId, String district) async {
    final trend = await getTrend(productId, district);
    final agg = await getAggregated(productId, district);
    final insights = <PriceInsight>[];
    if (trend.points.length >= 2) {
      final change = trend.weekChangePercent;
      if (change.abs() > 5) {
        final direction = change > 0 ? 'increased' : 'decreased';
        final directionTa = change > 0 ? 'அதிகரித்தது' : 'குறைந்தது';
        insights.add(PriceInsight(
            type: 'trend',
            message:
                'Price $direction ${change.abs().toStringAsFixed(0)}% this week',
            messageTa:
                'விலை இந்த வாரம் ${change.abs().toStringAsFixed(0)}% $directionTa',
            icon: change > 0 ? 'trending_up' : 'trending_down'));
      }
    }
    if (agg.demand == DemandLevel.veryHigh || agg.demand == DemandLevel.high) {
      insights.add(PriceInsight(
          type: 'alert',
          message: 'High demand in $district — good time to sell!',
          messageTa: '$district இல் அதிக தேவை — விற்க நல்ல நேரம்!',
          icon: 'local_fire_department'));
    }
    if (agg.priceSpread > 10) {
      insights.add(PriceInsight(
          type: 'suggestion',
          message: 'Price range is wide (₹${agg.minPrice}–₹${agg.maxPrice})',
          messageTa: 'விலை வரம்பு பெரியது (₹${agg.minPrice}–₹${agg.maxPrice})',
          icon: 'insights'));
    }
    return insights;
  }

  // ==================== RECOMMENDED PRICE ====================

  Future<Map<String, dynamic>> getRecommendedPrice(
      String productId, String district) async {
    final agg = await getAggregated(productId, district);
    final trend = await getTrend(productId, district);
    final change = trend.weekChangePercent;
    double recommended = agg.avgPrice;
    if (change > 5) {
      recommended = agg.avgPrice * 1.05;
    } else if (change < -5) recommended = agg.avgPrice * 0.95;
    return {
      'recommended': recommended.round(),
      'min': agg.minPrice,
      'max': agg.maxPrice,
      'avg': agg.avgPrice,
      'trend': change > 0
          ? 'up'
          : change < 0
              ? 'down'
              : 'stable',
      'change': change.toStringAsFixed(1),
      'demand': getDemandLabel(agg.demand),
      'demandTa': getDemandLabelTa(agg.demand),
    };
  }

  // Removed hardcoded sample insights - all insights now come from database
  Future<List<PriceInsight>> getFarmerInsights(String productId, String district) async {
    return getInsights(productId, district);
  }

  PriceLog _parsePriceLog(aw.Document doc) {
    return PriceLog(
        id: doc.$id,
        productId: doc.data['productId'] ?? '',
        productName: doc.data['productName'] ?? '',
        farmerId: doc.data['farmerId'] ?? '',
        farmerName: doc.data['farmerName'] ?? '',
        price: (doc.data['price'] as num?)?.toDouble() ?? 0,
        quantity: (doc.data['quantity'] as num?)?.toDouble() ?? 0,
        unit: doc.data['unit'] ?? 'kg',
        district: doc.data['district'] ?? '',
        createdAt: doc.data['createdAt'] != null
            ? DateTime.parse(doc.data['createdAt'])
            : DateTime.now());
  }

  AggregatedPrice _parseAggregated(aw.Document doc) {
    return AggregatedPrice(
        productId: doc.data['productId'] ?? '',
        productName: doc.data['productName'] ?? '',
        district: doc.data['district'] ?? '',
        avgPrice: (doc.data['avgPrice'] as num?)?.toDouble() ?? 0,
        minPrice: (doc.data['minPrice'] as num?)?.toDouble() ?? 0,
        maxPrice: (doc.data['maxPrice'] as num?)?.toDouble() ?? 0,
        totalQuantity: (doc.data['totalQuantity'] as num?)?.toDouble() ?? 0,
        sellerCount: doc.data['sellerCount'] ?? 0,
        lastUpdated: doc.data['lastUpdated'] != null
            ? DateTime.parse(doc.data['lastUpdated'])
            : DateTime.now(),
        demand: _parseDemand(doc.data['demand'] ?? 'moderate'));
  }

  DemandLevel _parseDemand(String demand) {
    switch (demand) {
      case 'very_high':
        return DemandLevel.veryHigh;
      case 'high':
        return DemandLevel.high;
      case 'low':
        return DemandLevel.low;
      default:
        return DemandLevel.moderate;
    }
  }
}
