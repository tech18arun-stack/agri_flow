import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';

/// Notification model
class NotificationModel {
  final String id;
  final String userId;
  final String role;
  final String title;
  final String message;
  final String type; // order, loi, system, promotion
  final String? data;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.title,
    required this.message,
    this.type = 'system',
    this.data,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromDocument(aw.Document doc) {
    return NotificationModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      role: doc.data['role'] ?? 'customer',
      title: doc.data['title'] ?? '',
      message: doc.data['message'] ?? '',
      type: doc.data['type'] ?? 'system',
      data: doc.data['data'],
      imageUrl: doc.data['imageUrl'],
      isRead: doc.data['isRead'] ?? false,
      createdAt: DateTime.parse(doc.data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IconData get icon {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'loi':
        return Icons.description;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'order':
        return const Color(0xFF2196F3);
      case 'loi':
        return const Color(0xFFFF9800);
      case 'promotion':
        return const Color(0xFF4CAF50);
      case 'system':
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// Notification Service - Handles all notification operations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;
  final _svc = AppwriteService.instance;

  /// Create a new notification
  Future<bool> create({
    required String userId,
    required String role,
    required String title,
    required String message,
    String type = 'system',
    String? data,
    String? imageUrl,
  }) async {
    try {
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'role': role,
          'title': title,
          'message': message,
          'type': type,
          'data': data ?? '',
          'imageUrl': imageUrl ?? '',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('✅ Notification created: $title for $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Create notification error: $e');
      return false;
    }
  }

  /// Get user notifications
  Future<List<NotificationModel>> getUserNotifications(String userId, {int limit = 50}) async {
    try {
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
          Query.limit(limit),
        ],
      );
      return result.documents.map((doc) => NotificationModel.fromDocument(doc)).toList();
    } catch (e) {
      debugPrint('❌ Get notifications error: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: notificationId,
        data: {'isRead': true},
      );
      return true;
    } catch (e) {
      debugPrint('❌ Mark as read error: $e');
      return false;
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      final notifications = await getUserNotifications(userId);
      for (final notification in notifications) {
        if (!notification.isRead) {
          await markAsRead(notification.id);
        }
      }
      return true;
    } catch (e) {
      debugPrint('❌ Mark all as read error: $e');
      return false;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _svc.db.listDocuments(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isRead', false),
        ],
      );
      return result.total;
    } catch (e) {
      debugPrint('❌ Get unread count error: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<bool> delete(String notificationId) async {
    try {
      await _svc.db.deleteDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: notificationId,
      );
      return true;
    } catch (e) {
      debugPrint('❌ Delete notification error: $e');
      return false;
    }
  }

  /// Clear all notifications for user
  Future<bool> clearAll(String userId) async {
    try {
      final notifications = await getUserNotifications(userId, limit: 100);
      for (final notification in notifications) {
        await delete(notification.id);
      }
      return true;
    } catch (e) {
      debugPrint('❌ Clear all error: $e');
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Send order notification
  Future<bool> sendOrderNotification({
    required String userId,
    required String role,
    required String orderId,
    required String status,
  }) async {
    return create(
      userId: userId,
      role: role,
      title: 'Order $status',
      message: 'Your order #$orderId has been $status',
      type: 'order',
      data: orderId,
    );
  }

  /// Send LOI notification
  Future<bool> sendLOINotification({
    required String userId,
    required String role,
    required String loiId,
    required String status,
    required String productName,
  }) async {
    return create(
      userId: userId,
      role: role,
      title: 'LOI $status',
      message: 'Your LOI for $productName has been $status',
      type: 'loi',
      data: loiId,
    );
  }

  /// Send system notification
  Future<bool> sendSystemNotification({
    required String userId,
    required String role,
    required String title,
    required String message,
  }) async {
    return create(
      userId: userId,
      role: role,
      title: title,
      message: message,
      type: 'system',
    );
  }

  /// Send promotion notification
  Future<bool> sendPromotion({
    required String userId,
    required String role,
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    return create(
      userId: userId,
      role: role,
      title: title,
      message: message,
      type: 'promotion',
      imageUrl: imageUrl,
    );
  }
}
