import 'package:appwrite/appwrite.dart';
import 'appwrite_config.dart';

/// Singleton wrapper for all Appwrite services
class AppwriteService {
  AppwriteService._();
  static final AppwriteService instance = AppwriteService._();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;
  late Realtime _realtime;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    _client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId)
      ..setSelfSigned(status: true);

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);

    _initialized = true;
  }

  Account get account {
    if (!_initialized) throw Exception('AppwriteService not initialized');
    return _account;
  }

  Databases get db {
    if (!_initialized) throw Exception('AppwriteService not initialized');
    return _databases;
  }

  Storage get storage {
    if (!_initialized) throw Exception('AppwriteService not initialized');
    return _storage;
  }

  Realtime get realtime {
    if (!_initialized) throw Exception('AppwriteService not initialized');
    return _realtime;
  }

  String get databaseId => AppwriteConfig.databaseId;
}
