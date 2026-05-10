import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _service = NotificationService.instance;
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnread => _unreadCount > 0;

  /// Load notifications for user
  Future<void> loadNotifications(String userId) async {
    _loading = true;
    notifyListeners();

    try {
      _notifications.clear();
      final notifs = await _service.getUserNotifications(userId);
      _notifications.addAll(notifs);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('❌ Load notifications error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Create a notification
  Future<bool> create({
    required String userId,
    required String role,
    required String title,
    required String message,
    String type = 'system',
    String? data,
  }) async {
    return await _service.create(
      userId: userId,
      role: role,
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }

  /// Send order notification
  Future<bool> sendOrderNotification({
    required String userId,
    required String role,
    required String orderId,
    required String status,
  }) async {
    return await _service.sendOrderNotification(
      userId: userId,
      role: role,
      orderId: orderId,
      status: status,
    );
  }

  /// Refresh notifications
  Future<void> refresh(String userId) async {
    await loadNotifications(userId);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          role: _notifications[index].role,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          data: _notifications[index].data,
          imageUrl: _notifications[index].imageUrl,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final success = await _service.markAllAsRead(userId);
    if (success) {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            userId: _notifications[i].userId,
            role: _notifications[i].role,
            title: _notifications[i].title,
            message: _notifications[i].message,
            type: _notifications[i].type,
            data: _notifications[i].data,
            imageUrl: _notifications[i].imageUrl,
            isRead: true,
            createdAt: _notifications[i].createdAt,
          );
        }
      }
      _unreadCount = 0;
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> delete(String notificationId) async {
    final success = await _service.delete(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final wasUnread = !_notifications[index].isRead;
        _notifications.removeAt(index);
        if (wasUnread) _unreadCount--;
        notifyListeners();
      }
    }
  }

  /// Clear all notifications
  Future<void> clearAll(String userId) async {
    final success = await _service.clearAll(userId);
    if (success) {
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    }
  }

  /// Send a test notification
  Future<void> sendTestNotification(String userId, String role) async {
    await _service.sendSystemNotification(
      userId: userId,
      role: role,
      title: 'Test Notification',
      message: 'This is a test notification from Farm Flow',
    );
    await loadNotifications(userId);
  }
}
