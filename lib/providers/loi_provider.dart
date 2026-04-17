import 'package:flutter/material.dart';
import '../data/models.dart';
import '../services/loi_service.dart';

import '../services/notification_service.dart';

class LOIProvider with ChangeNotifier {
  final LOIService _service = LOIService();
  final NotificationService _notifSvc = NotificationService.instance;
  List<LOIRequestModel> _farmerRequests = [];
  List<LOIRequestModel> _merchantRequests = [];
  bool _isLoading = false;

  List<LOIRequestModel> get farmerRequests => _farmerRequests;
  List<LOIRequestModel> get merchantRequests => _merchantRequests;
  bool get isLoading => _isLoading;

  Future<void> fetchFarmerRequests(String farmerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _farmerRequests = await _service.getLOIRequestsForFarmer(farmerId);
    } catch (e) {
      debugPrint('Error fetching farmer LOI requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMerchantRequests(String merchantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _merchantRequests = await _service.getLOIRequestsForMerchant(merchantId);
    } catch (e) {
      debugPrint('Error fetching merchant LOI requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendLOI(LOIRequestModel request) async {
    try {
      final newLoi = await _service.createLOIRequest(request);
      _merchantRequests.add(newLoi);

      // Notify Farmer
      await _notifSvc.create(
        userId: request.farmerId,
        role: 'farmer',
        title: 'New Price Offer!',
        message: '${request.merchantName} sent an LOI for ${request.productName} (₹${request.priceOffer}/${request.unit})',
        type: 'loi',
        data: newLoi.id,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error sending LOI: $e');
      return false;
    }
  }

  Future<bool> updateStatus(String loiId, String status) async {
    try {
      final updatedLoi = await _service.updateStatus(loiId, status);
      final index = _farmerRequests.indexWhere((l) => l.id == loiId);
      if (index != -1) {
        _farmerRequests[index] = updatedLoi;
        
        // Notify Merchant
        await _notifSvc.sendLOINotification(
          userId: updatedLoi.merchantId,
          role: 'merchant',
          loiId: updatedLoi.id,
          status: status,
          productName: updatedLoi.productName,
        );

        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating LOI status: $e');
      return false;
    }
  }
}
