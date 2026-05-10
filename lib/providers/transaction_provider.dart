import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';

class Transaction {
  final String id;
  final String userId;
  final String userName;
  final String type; // buy, sell
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? counterpartyId;
  final String? counterpartyName;
  final String? orderId;
  final String status;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    this.counterpartyId,
    this.counterpartyName,
    this.orderId,
    required this.status,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  bool get isBuy => type == 'buy';
  bool get isSell => type == 'sell';
  bool get isCompleted => status == 'completed';

  factory Transaction.fromDocument(aw.Document doc) {
    return Transaction(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      userName: doc.data['userName'] ?? '',
      type: doc.data['type'] ?? '',
      productId: doc.data['productId'] ?? '',
      productName: doc.data['productName'] ?? '',
      quantity: (doc.data['quantity'] as num?)?.toDouble() ?? 0,
      unit: doc.data['unit'] ?? 'kg',
      pricePerUnit: (doc.data['pricePerUnit'] as num?)?.toDouble() ?? 0,
      totalAmount: (doc.data['totalAmount'] as num?)?.toDouble() ?? 0,
      counterpartyId: doc.data['counterpartyId'],
      counterpartyName: doc.data['counterpartyName'],
      orderId: doc.data['orderId'],
      status: doc.data['status'] ?? 'pending',
      paymentMethod: doc.data['paymentMethod'],
      notes: doc.data['notes'],
      createdAt: DateTime.parse(doc.data['createdAt']),
    );
  }
}

class ProfitLossReport {
  final double totalPurchases;
  final double totalSales;
  final double netProfit;
  final int transactionCount;
  final int buyCount;
  final int sellCount;

  const ProfitLossReport({
    required this.totalPurchases,
    required this.totalSales,
    required this.netProfit,
    required this.transactionCount,
    required this.buyCount,
    required this.sellCount,
  });

  double get profitMargin => totalSales > 0 ? (netProfit / totalSales * 100) : 0;
  bool get isProfitable => netProfit > 0;
}

class TransactionProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  final List<Transaction> _transactions = [];
  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;

  List<Transaction> get buys => _transactions.where((t) => t.isBuy).toList();
  List<Transaction> get sells => _transactions.where((t) => t.isSell).toList();
  List<Transaction> get completed => _transactions.where((t) => t.isCompleted).toList();

  ProfitLossReport get report {
    final totalPurchases = buys.where((t) => t.isCompleted).fold(0.0, (sum, t) => sum + t.totalAmount);
    final totalSales = sells.where((t) => t.isCompleted).fold(0.0, (sum, t) => sum + t.totalAmount);
    return ProfitLossReport(
      totalPurchases: totalPurchases,
      totalSales: totalSales,
      netProfit: totalSales - totalPurchases,
      transactionCount: _transactions.length,
      buyCount: buys.length,
      sellCount: sells.length,
    );
  }

  ProfitLossReport getReportForPeriod(DateTime start, DateTime end) {
    final filtered = _transactions.where((t) =>
        t.createdAt.isAfter(start) && t.createdAt.isBefore(end)
    ).toList();

    final totalPurchases = filtered.where((t) => t.isBuy && t.isCompleted).fold(0.0, (sum, t) => sum + t.totalAmount);
    final totalSales = filtered.where((t) => t.isSell && t.isCompleted).fold(0.0, (sum, t) => sum + t.totalAmount);

    return ProfitLossReport(
      totalPurchases: totalPurchases,
      totalSales: totalSales,
      netProfit: totalSales - totalPurchases,
      transactionCount: filtered.length,
      buyCount: filtered.where((t) => t.isBuy).length,
      sellCount: filtered.where((t) => t.isSell).length,
    );
  }

  List<Map<String, dynamic>> getTopProducts() {
    final productMap = <String, Map<String, dynamic>>{};

    for (final t in sells.where((t) => t.isCompleted)) {
      if (!productMap.containsKey(t.productId)) {
        productMap[t.productId] = {
          'productId': t.productId,
          'productName': t.productName,
          'totalSold': 0.0,
          'totalRevenue': 0.0,
          'transactionCount': 0,
        };
      }
      productMap[t.productId]!['totalSold'] = (productMap[t.productId]!['totalSold'] as double) + t.quantity;
      productMap[t.productId]!['totalRevenue'] = (productMap[t.productId]!['totalRevenue'] as double) + t.totalAmount;
      productMap[t.productId]!['transactionCount'] = (productMap[t.productId]!['transactionCount'] as int) + 1;
    }

    final products = productMap.values.toList();
    products.sort((a, b) => (b['totalRevenue'] as double).compareTo(a['totalRevenue'] as double));
    return products.take(10).toList();
  }

  Future<void> loadTransactions(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      final res = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.transactionsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
          Query.limit(200),
        ],
      );

      _transactions.clear();
      _transactions.addAll(res.documents.map((doc) => Transaction.fromDocument(doc)));
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> recordTransaction({
    required String userId,
    required String userName,
    required String type,
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required double totalAmount,
    String? counterpartyId,
    String? counterpartyName,
    String? orderId,
    String status = 'completed',
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      if (!_svc.isInitialized) await _svc.init();

      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.transactionsCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'userName': userName,
          'type': type,
          'productId': productId,
          'productName': productName,
          'quantity': quantity,
          'unit': unit,
          'pricePerUnit': pricePerUnit,
          'totalAmount': totalAmount,
          if (counterpartyId != null) 'counterpartyId': counterpartyId,
          if (counterpartyName != null) 'counterpartyName': counterpartyName,
          if (orderId != null) 'orderId': orderId,
          'status': status,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
          if (notes != null) 'notes': notes,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await loadTransactions(userId);
    } catch (e) {
      debugPrint('Error recording transaction: $e');
    }
  }

  Future<void> recordPurchase({
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    String? farmerId,
    String? farmerName,
    String? notes,
  }) async {
    return recordTransaction(
      userId: userId,
      userName: userName,
      type: 'buy',
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      totalAmount: pricePerUnit * quantity,
      counterpartyId: farmerId,
      counterpartyName: farmerName,
      paymentMethod: 'upi',
      notes: notes,
    );
  }

  Future<void> recordSale({
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    String? customerId,
    String? customerName,
    String? orderId,
    String? notes,
  }) async {
    return recordTransaction(
      userId: userId,
      userName: userName,
      type: 'sell',
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      totalAmount: pricePerUnit * quantity,
      counterpartyId: customerId,
      counterpartyName: customerName,
      orderId: orderId,
      notes: notes,
    );
  }

  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.transactionsCollectionId,
        documentId: transactionId,
        data: {'status': status},
      );

      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx >= 0) {
        await loadTransactions(_transactions[idx].userId);
      }
    } catch (e) {
      debugPrint('Error updating transaction status: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx >= 0) {
        await _svc.db.deleteDocument(
          databaseId: _svc.databaseId,
          collectionId: AppwriteConfig.transactionsCollectionId,
          documentId: transactionId,
        );

        _transactions.removeAt(idx);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }
}


