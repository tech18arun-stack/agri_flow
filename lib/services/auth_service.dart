import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_service.dart';
import 'appwrite_config.dart';
import '../data/models.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _svc = AppwriteService.instance;

  /// Get current session
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _svc.account.get();
      final roleStr = user.prefs.data['role'] ?? 'customer';
      return UserModel(
        id: user.$id,
        name: user.name,
        email: user.email,
        role: _parseRole(roleStr),
        district: user.prefs.data['district'] ?? '',
        taluk: user.prefs.data['taluk'] ?? '',
        municipality: user.prefs.data['municipality'] ?? '',
        status: user.prefs.data['status'] ?? 'active',
      );
    } catch (_) {
      return null;
    }
  }

  /// Email/password signup
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String district,
    String taluk = '',
    String municipality = '',
  }) async {
    debugPrint('📝 Signup: Creating auth account for $email');
    final user = await _svc.account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    debugPrint('📝 Signup: Auth account created with ID ${user.$id}');

    debugPrint('📝 Signup: Saving prefs');
    try {
      await _svc.account.updatePrefs(prefs: {
        'role': role.name,
        'district': district,
        'taluk': taluk,
        'municipality': municipality,
        'status': 'active',
      });
    } catch (e) {
      debugPrint('📝 Signup WARN: updatePrefs failed (API key may need "account" scope): $e');
      // Not fatal — users collection document is the source of truth
    }

    debugPrint('📝 Signup: Creating users collection document');
    try {
      await _svc.db.createDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.$id,
        data: {
          'userId': user.$id,
          'name': name,
          'email': email,
          'role': role.name,
          'district': district,
          'taluk': taluk,
          'municipality': municipality,
          'profileImage': '',
          'status': 'active',
        },
      );
      debugPrint('📝 Signup: users collection document created');
    } catch (e) {
      debugPrint('📝 Signup ERROR creating users doc: $e');
      rethrow;
    }

    return user;
  }

  /// Email/password login
  Future<Session> login({required String email, required String password}) async {
    return await _svc.account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _svc.account.deleteSession(sessionId: 'current');
  }

  /// Update user role
  Future<void> updateRole(UserRole role) async {
    await _svc.account.updatePrefs(prefs: {'role': role.name});
  }

  UserRole _parseRole(String role) {
    switch (role) {
      case 'farmer': return UserRole.farmer;
      case 'merchant': return UserRole.merchant;
      case 'admin': return UserRole.admin;
      case 'price_updater': return UserRole.priceUpdater;
      default: return UserRole.customer;
    }
  }
}
