// Price Engine Models
import 'package:intl/intl.dart';

class PriceLog {
  final String id;
  final String productId;
  final String productName;
  final String farmerId;
  final String farmerName;
  final double price;
  final double quantity;
  final String unit;
  final String district;
  final DateTime createdAt;

  const PriceLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.farmerId,
    required this.farmerName,
    required this.price,
    required this.quantity,
    this.unit = 'kg',
    required this.district,
    required this.createdAt,
  });
}

class AggregatedPrice {
  final String productId;
  final String productName;
  final String district;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double totalQuantity;
  final String unit;
  final int sellerCount;
  final DateTime lastUpdated;
  final DemandLevel demand;

  const AggregatedPrice({
    required this.productId,
    required this.productName,
    required this.district,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.totalQuantity,
    this.unit = 'kg',
    required this.sellerCount,
    required this.lastUpdated,
    required this.demand,
  });

  double get priceSpread => maxPrice - minPrice;
  double get savingsPercent => ((maxPrice - minPrice) / maxPrice) * 100;
}

enum DemandLevel { low, moderate, high, veryHigh }

class PriceTrend {
  final String productId;
  final String productName;
  final String district;
  final List<PricePoint> points;

  const PriceTrend({
    required this.productId,
    required this.productName,
    required this.district,
    required this.points,
  });

  double get currentPrice => points.isNotEmpty ? points.last.price : 0;
  double get weekAgoPrice => points.length > 7 ? points[points.length - 8].price : (points.isNotEmpty ? points.first.price : 0);

  double get weekChangePercent {
    if (weekAgoPrice == 0) return 0;
    return ((currentPrice - weekAgoPrice) / weekAgoPrice) * 100;
  }

  bool get isUp => weekChangePercent > 0;
  bool get isDown => weekChangePercent < 0;
}

class PricePoint {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});
  String get label => DateFormat('dd MMM').format(date);
}

class PriceInsight {
  final String type; // 'alert', 'suggestion', 'trend'
  final String message;
  final String messageTa;
  final String icon;

  const PriceInsight({
    required this.type,
    required this.message,
    required this.messageTa,
    required this.icon,
  });
}

class DistrictPriceComparison {
  final String productId;
  final String productName;
  final List<DistrictPrice> districts;

  const DistrictPriceComparison({
    required this.productId,
    required this.productName,
    required this.districts,
  });

  String get cheapestDistrict {
    if (districts.isEmpty) return '';
    districts.sort((a, b) => a.avgPrice.compareTo(b.avgPrice));
    return districts.first.name;
  }

  String get costliestDistrict {
    if (districts.isEmpty) return '';
    districts.sort((a, b) => b.avgPrice.compareTo(a.avgPrice));
    return districts.first.name;
  }
}

class DistrictPrice {
  final String name;
  final String nameTa;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final int sellers;

  const DistrictPrice({
    required this.name,
    required this.nameTa,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.sellers,
  });
}
