import 'package:appwrite/appwrite.dart' show ID;

/// All 38 Tamil Nadu Districts with Tamil names
class TamilNaduDistricts {
  static const List<Map<String, String>> all = [
    {'en': 'Ariyalur', 'ta': 'அரியலூர்'},
    {'en': 'Chengalpattu', 'ta': 'செங்கல்பட்டு'},
    {'en': 'Chennai', 'ta': 'சென்னை'},
    {'en': 'Coimbatore', 'ta': 'கோயம்புத்தூர்'},
    {'en': 'Cuddalore', 'ta': 'கடலூர்'},
    {'en': 'Dharmapuri', 'ta': 'தர்மபுரி'},
    {'en': 'Dindigul', 'ta': 'திண்டுக்கல்'},
    {'en': 'Erode', 'ta': 'ஈரோடு'},
    {'en': 'Kallakurichi', 'ta': 'கள்ளக்குறிச்சி'},
    {'en': 'Kancheepuram', 'ta': 'காஞ்சிபுரம்'},
    {'en': 'Kanniyakumari', 'ta': 'கன்னியாகுமரி'},
    {'en': 'Karur', 'ta': 'கரூர்'},
    {'en': 'Krishnagiri', 'ta': 'கிருஷ்ணகிரி'},
    {'en': 'Madurai', 'ta': 'மதுரை'},
    {'en': 'Mayiladuthurai', 'ta': 'மயிலாடுதுறை'},
    {'en': 'Nagapattinam', 'ta': 'நாகப்பட்டினம்'},
    {'en': 'Namakkal', 'ta': 'நாமக்கல்'},
    {'en': 'Nilgiris', 'ta': 'நீலகிரி'},
    {'en': 'Perambalur', 'ta': 'பெரம்பலூர்'},
    {'en': 'Pudukkottai', 'ta': 'புதுக்கோட்டை'},
    {'en': 'Ramanathapuram', 'ta': 'இராமநாதபுரம்'},
    {'en': 'Ranipet', 'ta': 'ராணிப்பேட்டை'},
    {'en': 'Salem', 'ta': 'சேலம்'},
    {'en': 'Sivaganga', 'ta': 'சிவகங்கை'},
    {'en': 'Tenkasi', 'ta': 'தென்காசி'},
    {'en': 'Thanjavur', 'ta': 'தஞ்சாவூர்'},
    {'en': 'Theni', 'ta': 'தேனி'},
    {'en': 'Thoothukudi', 'ta': 'தூத்துக்குடி'},
    {'en': 'Tiruchirappalli', 'ta': 'திருச்சிராப்பள்ளி'},
    {'en': 'Tirunelveli', 'ta': 'திருநெல்வேலி'},
    {'en': 'Tirupattur', 'ta': 'திருப்பத்தூர்'},
    {'en': 'Tiruppur', 'ta': 'திருப்பூர்'},
    {'en': 'Tiruvallur', 'ta': 'திருவள்ளூர்'},
    {'en': 'Tiruvannamalai', 'ta': 'திருவண்ணாமலை'},
    {'en': 'Tiruvarur', 'ta': 'திருவாரூர்'},
    {'en': 'Vellore', 'ta': 'வேலூர்'},
    {'en': 'Viluppuram', 'ta': 'விழுப்புரம்'},
    {'en': 'Virudhunagar', 'ta': 'விருதுநகர்'},
  ];

  static List<String> get names => all.map((d) => d['en']!).toList();

  static String getTamil(String english) {
    try {
      return all.firstWhere((d) => d['en'] == english)['ta']!;
    } catch (_) {
      return english;
    }
  }
}

/// A flower item in the catalog managed by admin
class FlowerCatalogItem {
  final String id;
  final String nameEn;
  final String nameTa;
  final String icon;
  final String color; // hex color string e.g. '#ec4899'
  final String unit; // kg, bunch, dozen, piece
  final bool active;
  final int sortOrder;

  const FlowerCatalogItem({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    this.icon = '🌸',
    this.color = '#ec4899',
    this.unit = 'kg',
    this.active = true,
    this.sortOrder = 0,
  });

  factory FlowerCatalogItem.fromDocument(Map<String, dynamic> data, String id) {
    return FlowerCatalogItem(
      id: id,
      nameEn: data['nameEn'] ?? '',
      nameTa: data['nameTa'] ?? '',
      icon: data['icon'] ?? '🌸',
      color: data['color'] ?? '#ec4899',
      unit: data['unit'] ?? 'kg',
      active: data['active'] ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nameEn': nameEn,
        'nameTa': nameTa,
        'icon': icon,
        'color': color,
        'unit': unit,
        'active': active,
        'sortOrder': sortOrder,
      };
}

/// Daily flower price entry — one per (flower, district, date)
class FlowerPriceEntry {
  final String? docId;
  final String flowerId;
  final String flowerName;
  final String flowerNameTa;
  final String district;
  final double priceMin;
  final double priceMax;
  final String unit;
  final String status; // 'draft' or 'published'
  final String date; // ISO date: YYYY-MM-DD
  final String? updatedById;
  final String? updatedByName;
  final DateTime? createdAt;

  const FlowerPriceEntry({
    this.docId,
    required this.flowerId,
    required this.flowerName,
    required this.flowerNameTa,
    required this.district,
    required this.priceMin,
    required this.priceMax,
    required this.unit,
    this.status = 'draft',
    required this.date,
    this.updatedById,
    this.updatedByName,
    this.createdAt,
  });

  double get avgPrice => (priceMin + priceMax) / 2;
  bool get isPublished => status == 'published';
  bool get isDraft => status == 'draft';

  factory FlowerPriceEntry.fromDocument(Map<String, dynamic> data, String id) {
    return FlowerPriceEntry(
      docId: id,
      flowerId: data['flowerId'] ?? '',
      flowerName: data['flowerName'] ?? '',
      flowerNameTa: data['flowerNameTa'] ?? '',
      district: data['district'] ?? '',
      priceMin: (data['priceMin'] as num?)?.toDouble() ?? 0,
      priceMax: (data['priceMax'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] ?? 'kg',
      status: data['status'] ?? 'draft',
      date: data['date'] ?? '',
      updatedById: data['updatedById'],
      updatedByName: data['updatedByName'],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
    );
  }

  FlowerPriceEntry copyWith({
    String? docId,
    double? priceMin,
    double? priceMax,
    String? status,
    String? updatedById,
    String? updatedByName,
  }) {
    return FlowerPriceEntry(
      docId: docId ?? this.docId,
      flowerId: flowerId,
      flowerName: flowerName,
      flowerNameTa: flowerNameTa,
      district: district,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      unit: unit,
      status: status ?? this.status,
      date: date,
      updatedById: updatedById ?? this.updatedById,
      updatedByName: updatedByName ?? this.updatedByName,
      createdAt: createdAt,
    );
  }
}

/// Helper to generate unique IDs
String generateId() => ID.unique();
