import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import '../data/models.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_config.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _svc = AppwriteService.instance;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserRole? get role => _user?.role;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null && _user?.role != UserRole.guest;
  bool get isGuest => _user?.role == UserRole.guest;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();
      // getSession will throw 401 if no user is logged in (normal)
      await _svc.account.getSession(sessionId: 'current');
      await _fetchUser();
    } catch (e) {
      // Don't log normal 401 errors
      if (e is AppwriteException && e.code != 401) {
        debugPrint('Auth check error: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      // Try to delete existing session first just in case
      try { await _svc.account.deleteSession(sessionId: 'current'); } catch(_) {}

      debugPrint('🔐 Login: Creating session for $email');
      await _svc.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint('🔐 Login: Session created, fetching user profile');
      await _fetchUser();
      debugPrint('🔐 Login: User loaded - ${_user?.name}, role=${_user?.role}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Login error: $e');
      return false;
    } finally {
      _loading = false;
      debugPrint('🔐 Login: Setting loading=false, calling notifyListeners');
      notifyListeners();
    }
  }

  Future<void> loginAsGuest() async {
    _loading = true;
    notifyListeners();
    try {
      _user = const UserModel(
        id: 'guest',
        name: 'Guest User',
        email: 'guest@Farm Flow.com',
        role: UserRole.guest,
        district: 'None',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUser() async {
    try {
      debugPrint('👤 _fetchUser: Getting account info');
      final account = await _svc.account.get();
      debugPrint('👤 _fetchUser: Account ID=${account.$id}, name=${account.name}');
      debugPrint('👤 _fetchUser: Account prefs: ${account.prefs.data}');
      
      final doc = await _svc.db.getDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: account.$id,
      );
      debugPrint('👤 _fetchUser: Found users collection doc: ${doc.data}');
      _user = _parseUser(doc);
      debugPrint('👤 _fetchUser: User parsed - role=${_user?.role}, district=${_user?.district}');
    } catch (e) {
      debugPrint('👤 _fetchUser: No users doc found, falling back to account prefs: $e');
      // Fallback if profile doc doesn't exist but account does
      final account = await _svc.account.get();
      debugPrint('👤 _fetchUser: Account prefs fallback: ${account.prefs.data}');
      _user = UserModel(
        id: account.$id,
        name: account.name,
        email: account.email,
        role: _parseRoleFromPrefs(account.prefs.data['role']),
        district: account.prefs.data['district'] ?? '',
        taluk: account.prefs.data['taluk'] ?? '',
        municipality: account.prefs.data['municipality'] ?? '',
      );
      debugPrint('👤 _fetchUser: Fallback user created - role=${_user?.role}');
    }
  }

  UserRole _parseRoleFromPrefs(String? roleStr) {
    final r = roleStr?.toLowerCase();
    if (r == 'farmer') return UserRole.farmer;
    if (r == 'merchant') return UserRole.merchant;
    if (r == 'admin') return UserRole.admin;
    if (r == 'price_updater' || r == 'priceupdater') return UserRole.priceUpdater;
    return UserRole.customer;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String district,
    String taluk = '',
    String municipality = '',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (!_svc.isInitialized) await _svc.init();

      // 1. Create auth account + users collection document
      debugPrint('📝 Register: Creating account for $email');
      await AuthService.instance.signup(
        email: email,
        password: password,
        name: name,
        role: role,
        district: district,
        taluk: taluk,
        municipality: municipality,
      );
      debugPrint('📝 Register: Account created, auto-logging in');

      // 2. Auto-login: create session so user is immediately logged in
      try { await _svc.account.deleteSession(sessionId: 'current'); } catch(_) {}
      await _svc.account.createEmailPasswordSession(email: email, password: password);
      debugPrint('📝 Register: Session created, fetching profile');

      // 3. Fetch the user profile from database
      await _fetchUser();
      debugPrint('📝 Register: User loaded - ${_user?.name}, role=${_user?.role}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _svc.account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      // Always clear user state regardless of session deletion success
      _user = null;
      notifyListeners();
    }
  }

  /// Update user profile information
  Future<bool> updateProfile({
    String? name,
    String? district,
    String? taluk,
    String? municipality,
    String? phone,
    String? address,
    double? lat,
    double? lng,
  }) async {
    if (_user == null) return false;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Update the users collection document
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _user!.id,
        data: {
          if (name != null) 'name': name,
          if (district != null) 'district': district,
          if (taluk != null) 'taluk': taluk,
          if (municipality != null) 'municipality': municipality,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Also update account name if changed
      if (name != null && name != _user!.name) {
        try {
          await _svc.account.updateName(name: name);
        } catch (e) {
          debugPrint('Failed to update account name: $e');
        }
      }

      // Refresh user data
      await _fetchUser();

      debugPrint('✅ Profile updated successfully');
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint('❌ Profile update error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Request account deletion (48 hour grace period)
  Future<bool> requestAccountDeletion() async {
    if (_user == null) return false;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _user!.id,
        data: {
          'status': 'deletion_requested',
          'deletionRequestedAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      );

      // Refresh local user data
      await _fetchUser();
      debugPrint('✅ Account deletion requested');
      return true;
    } catch (e) {
      _error = 'Failed to request deletion: $e';
      debugPrint('❌ Deletion request error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cancel a pending account deletion request
  Future<bool> cancelAccountDeletion() async {
    if (_user == null) return false;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _svc.db.updateDocument(
        databaseId: _svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _user!.id,
        data: {
          'status': 'active',
          'deletionRequestedAt': null,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Refresh local user data
      await _fetchUser();
      debugPrint('✅ Account deletion request cancelled');
      return true;
    } catch (e) {
      _error = 'Failed to cancel deletion: $e';
      debugPrint('❌ Cancel deletion error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update user password
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _svc.account.updatePassword(password: newPassword);
      debugPrint('✅ Password updated successfully');
      return true;
    } catch (e) {
      _error = 'Failed to update password: $e';
      debugPrint('❌ Password update error: $e');
      return false;
    }
  }

  /// Request password recovery email
  Future<bool> requestPasswordReset(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await AuthService.instance.createRecovery(
        email: email,
        url: 'https://Farm Flow-app.web.app/auth/reset-password', // Placeholder URL
      );
      if (success) {
        debugPrint('✅ Recovery email sent to $email');
        return true;
      } else {
        _error = 'Failed to send recovery email. Please check the email address.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Recovery error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  UserModel _parseUser(aw.Document doc) {
    UserRole role = UserRole.customer;
    final roleStr = doc.data['role']?.toString().toLowerCase();
    if (roleStr == 'farmer') role = UserRole.farmer;
    if (roleStr == 'merchant') role = UserRole.merchant;
    if (roleStr == 'admin') role = UserRole.admin;
    if (roleStr == 'price_updater' || roleStr == 'priceupdater') role = UserRole.priceUpdater;

    return UserModel(
      id: doc.$id,
      name: doc.data['name'] ?? '',
      email: doc.data['email'] ?? '',
      role: role,
      district: doc.data['district'] ?? '',
      taluk: doc.data['taluk'] ?? '',
      municipality: doc.data['municipality'] ?? '',
      status: doc.data['status'] ?? 'active',
      deletionRequestedAt: doc.data['deletionRequestedAt'] != null
          ? DateTime.tryParse(doc.data['deletionRequestedAt'].toString())
          : null,
      phone: doc.data['phone'],
      address: doc.data['address'],
      lat: doc.data['lat']?.toDouble(),
      lng: doc.data['lng']?.toDouble(),
    );
  }
}
