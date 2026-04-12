import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'appwrite_service.dart';
import 'appwrite_config.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static LocationService get instance => _instance;
  final _svc = AppwriteService.instance;

  /// Get all districts
  Future<List<aw.Document>> getDistricts() async {
    if (!_svc.isInitialized) await _svc.init();
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.districtsCollectionId,
      queries: [Query.equal('active', true), Query.orderAsc('name')],
    );
    return result.documents;
  }

  /// Get talukas for a district
  Future<List<aw.Document>> getTalukas(String district) async {
    if (!_svc.isInitialized) await _svc.init();
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.talukasCollectionId,
      queries: [Query.equal('district', district), Query.equal('active', true), Query.orderAsc('name')],
    );
    return result.documents;
  }

  /// Get municipalities for a district (optionally filtered by taluk)
  Future<List<aw.Document>> getMunicipalities(String district, {String? taluk}) async {
    if (!_svc.isInitialized) await _svc.init();
    final queries = [
      Query.equal('district', district),
      Query.equal('active', true),
    ];
    if (taluk != null && taluk.isNotEmpty) {
      queries.add(Query.equal('taluk', taluk));
    }
    queries.add(Query.orderAsc('name'));
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.municipalitiesCollectionId,
      queries: queries,
    );
    return result.documents;
  }

  /// Get products near user's location
  Future<List<aw.Document>> getNearbyProducts(String district, {String? taluk, int limit = 50}) async {
    if (!_svc.isInitialized) await _svc.init();
    final queries = [
      Query.equal('location', district),
      Query.orderDesc('createdAt'),
      Query.limit(limit),
    ];
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: queries,
    );
    return result.documents;
  }

  /// Get price comparison for a product category in a district
  Future<List<aw.Document>> getPriceComparison(String productId, String district) async {
    if (!_svc.isInitialized) await _svc.init();
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.aggregatedPricesCollectionId,
      queries: [Query.equal('productId', productId), Query.equal('district', district)],
    );
    return result.documents;
  }

  /// Get all active product categories from database
  Future<List<aw.Document>> getCategories() async {
    if (!_svc.isInitialized) await _svc.init();
    final result = await _svc.db.listDocuments(
      databaseId: _svc.databaseId,
      collectionId: AppwriteConfig.categoriesCollectionId,
      queries: [Query.equal('active', true), Query.orderAsc('name')],
    );
    return result.documents;
  }
}
