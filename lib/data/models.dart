enum UserRole { farmer, merchant, customer, admin, priceUpdater }

extension UserRoleExtension on UserRole {
  /// The string stored in the Appwrite database for this role
  String get dbValue {
    if (this == UserRole.priceUpdater) return 'price_updater';
    return name;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String district;
  final String taluk;
  final String municipality;
  final String status;
  final DateTime? deletionRequestedAt;
  final String? phone;
  final String? address;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.district,
    this.taluk = '',
    this.municipality = '',
    this.status = 'active',
    this.deletionRequestedAt,
    this.phone,
    this.address,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
  });

  bool get isDeletionPending {
    if (status != 'deletion_requested' || deletionRequestedAt == null) return false;
    // Account deletion is processed after 48 hours
    return true;
  }

  int get deletionHoursRemaining {
    if (deletionRequestedAt == null) return 0;
    final deadline = deletionRequestedAt!.add(const Duration(hours: 48));
    final remaining = deadline.difference(DateTime.now()).inHours;
    return remaining > 0 ? remaining : 0;
  }

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get locationSummary {
    final parts = [municipality, taluk, district].where((s) => s.isNotEmpty);
    return parts.join(', ');
  }

  String operator [](String key) => '';
}

class ProductModel {
  final String id;
  final String name;
  final String nameTa;
  final String category;
  final double price;
  final double quantity;
  final String unit;
  final bool organic;
  final String location;
  final String? address;
  final String farmerName;
  final String farmerId;
  final String? farmerPhone;
  final String? imageUrl;
  final double rating;
  final int reviews;
  final double? lat;
  final double? lng;
  final DateTime? harvestedDate;

  const ProductModel({
    required this.id,
    required this.name,
    this.nameTa = '',
    required this.category,
    required this.price,
    required this.quantity,
    this.unit = 'kg',
    this.organic = true,
    required this.location,
    this.address,
    required this.farmerName,
    required this.farmerId,
    this.farmerPhone,
    this.imageUrl,
    this.rating = 0,
    this.reviews = 0,
    this.lat,
    this.lng,
    this.harvestedDate,
  });

  String get freshnessIndicator {
    if (harvestedDate == null) return 'Fresh';
    final diff = DateTime.now().difference(harvestedDate!);
    if (diff.inDays <= 2) return 'Very Fresh';
    if (diff.inDays <= 5) return 'Fresh';
    return 'Harvested ${diff.inDays} days ago';
  }

  String get freshnessIndicatorTa {
    if (harvestedDate == null) return 'புதியது';
    final diff = DateTime.now().difference(harvestedDate!);
    if (diff.inDays <= 2) return 'மிகவும் புதியது';
    if (diff.inDays <= 5) return 'புதியது';
    return '${diff.inDays} நாட்களுக்கு முன் அறுவடை செய்யப்பட்டது';
  }
}

class LOIRequestModel {
  final String id;
  final String merchantId;
  final String merchantName;
  final String farmerId;
  final String farmerName;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double priceOffer;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  const LOIRequestModel({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.farmerId,
    required this.farmerName,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unit = 'kg',
    required this.priceOffer,
    required this.status,
    required this.createdAt,
  });
}

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String farmerId;
  final String farmerName;
  final List<OrderItem> items;
  final double total;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String shippingAddress;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;
  const OrderItem({
    required this.productId,
    required this.productName,
    this.productImageUrl = '',
    required this.price,
    required this.quantity,
  });
  double get total => price * quantity;
}

/// Product template model for farmer product selection
class ProductTemplateModel {
  final String id;
  final String nameEn;
  final String nameTa;
  final String category;
  final String unit;
  final String imageUrl;
  final String icon;
  final String color;
  final bool active;
  final int sortOrder;

  const ProductTemplateModel({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.category,
    required this.unit,
    this.imageUrl = '',
    this.icon = '🌾',
    this.color = '#4CAF50',
    this.active = true,
    this.sortOrder = 0,
  });

  factory ProductTemplateModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductTemplateModel(
      id: id,
      nameEn: data['nameEn'] ?? '',
      nameTa: data['nameTa'] ?? '',
      category: data['category'] ?? '',
      unit: data['unit'] ?? 'kg',
      imageUrl: data['imageUrl'] ?? '',
      icon: data['icon'] ?? '🌾',
      color: data['color'] ?? '#4CAF50',
      active: data['active'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  factory ProductTemplateModel.fromDocument(
      Map<String, dynamic> data, String id) {
    return ProductTemplateModel.fromMap(data, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameTa': nameTa,
      'category': category,
      'unit': unit,
      'imageUrl': imageUrl,
      'icon': icon,
      'color': color,
      'active': active,
      'sortOrder': sortOrder,
    };
  }
}
