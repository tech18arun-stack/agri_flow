import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'appwrite_service.dart';
import 'appwrite_config.dart';
import '../data/models.dart';

class LOIService {
  final Databases _db = AppwriteService.instance.db;

  Future<List<LOIRequestModel>> getLOIRequestsForFarmer(String farmerId) async {
    final response = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.loiRequestsCollectionId,
      queries: [Query.equal('farmerId', farmerId)],
    );
    return response.documents.map((doc) => _parseLOI(doc)).toList();
  }

  Future<List<LOIRequestModel>> getLOIRequestsForMerchant(
      String merchantId) async {
    final response = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.loiRequestsCollectionId,
      queries: [Query.equal('merchantId', merchantId)],
    );
    return response.documents.map((doc) => _parseLOI(doc)).toList();
  }

  Future<LOIRequestModel> createLOIRequest(LOIRequestModel request) async {
    final doc = await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.loiRequestsCollectionId,
      documentId: ID.unique(),
      data: {
        'merchantId': request.merchantId,
        'merchantName': request.merchantName,
        'farmerId': request.farmerId,
        'farmerName': request.farmerName,
        'productId': request.productId,
        'productName': request.productName,
        'quantity': request.quantity,
        'unit': request.unit,
        'priceOffer': request.priceOffer,
        'status': request.status,
        'createdAt': request.createdAt.toIso8601String(),
      },
    );
    return _parseLOI(doc);
  }

  Future<LOIRequestModel> updateStatus(String loiId, String status) async {
    final doc = await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.loiRequestsCollectionId,
      documentId: loiId,
      data: {'status': status},
    );
    return _parseLOI(doc);
  }

  LOIRequestModel _parseLOI(aw.Document doc) {
    return LOIRequestModel(
      id: doc.$id,
      merchantId: doc.data['merchantId'],
      merchantName: doc.data['merchantName'],
      farmerId: doc.data['farmerId'],
      farmerName: doc.data['farmerName'],
      productId: doc.data['productId'],
      productName: doc.data['productName'],
      quantity: (doc.data['quantity'] as num).toDouble(),
      unit: doc.data['unit'],
      priceOffer: (doc.data['priceOffer'] as num).toDouble(),
      status: doc.data['status'],
      createdAt: DateTime.parse(doc.data['createdAt']),
    );
  }
}
