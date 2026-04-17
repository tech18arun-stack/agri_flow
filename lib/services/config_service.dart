import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'appwrite_config.dart';
import 'map_service.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static ConfigService get instance => _instance;

  static const String githubConfigUrl = 
      'https://raw.githubusercontent.com/tech18arun-stack/agriflow_config/refs/heads/main/config.json';
  
  Map<String, dynamic>? _config;

  Future<void> init() async {
    try {
      // 1. Load local config first (as fallback/base)
      final localJson = await rootBundle.loadString('assets/data/config.json');
      _config = json.decode(localJson);
      _applyConfig(_config!);
      debugPrint('📦 Local config loaded');

      // 2. Try to fetch latest from GitHub (non-blocking update)
      _syncWithGithub();
    } catch (e) {
      debugPrint('❌ Config init failed: $e');
    }
  }

  Future<void> _syncWithGithub() async {
    try {
      final response = await http.get(Uri.parse(githubConfigUrl))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final remoteConfig = json.decode(response.body);
        _config = remoteConfig;
        _applyConfig(_config!);
        debugPrint('🌍 Remote config synced from GitHub');
      }
    } catch (e) {
      debugPrint('⚠️ GitHub config sync failed (using local): $e');
    }
  }

  void _applyConfig(Map<String, dynamic> config) {
    final appwrite = config['appwrite'];
    final collections = config['collections'];
    final buckets = config['buckets'];
    final maps = config['maps'];

    if (appwrite != null) {
      AppwriteConfig.endpoint = appwrite['endpoint'] ?? '';
      AppwriteConfig.projectId = appwrite['projectId'] ?? '';
      AppwriteConfig.databaseId = appwrite['databaseId'] ?? '';
    }

    if (collections != null) {
      AppwriteConfig.usersCollectionId = collections['users'] ?? '';
      AppwriteConfig.productsCollectionId = collections['products'] ?? '';
      AppwriteConfig.ordersCollectionId = collections['orders'] ?? '';
      AppwriteConfig.cartCollectionId = collections['cart'] ?? '';
      AppwriteConfig.transactionsCollectionId = collections['transactions'] ?? '';
      AppwriteConfig.bidsCollectionId = collections['bids'] ?? '';
      AppwriteConfig.reviewsCollectionId = collections['reviews'] ?? '';
      AppwriteConfig.notificationsCollectionId = collections['notifications'] ?? '';
      AppwriteConfig.priceLogsCollectionId = collections['price_logs'] ?? '';
      AppwriteConfig.aggregatedPricesCollectionId = collections['aggregated_prices'] ?? '';
      AppwriteConfig.priceTrendsCollectionId = collections['price_trends'] ?? '';
      AppwriteConfig.categoriesCollectionId = collections['categories'] ?? '';
      AppwriteConfig.districtsCollectionId = collections['districts'] ?? '';
      AppwriteConfig.appSettingsCollectionId = collections['app_settings'] ?? '';
      AppwriteConfig.talukasCollectionId = collections['talukas'] ?? '';
      AppwriteConfig.municipalitiesCollectionId = collections['municipalities'] ?? '';
      AppwriteConfig.loiRequestsCollectionId = collections['loi_requests'] ?? '';
      AppwriteConfig.wishlistCollectionId = collections['wishlist'] ?? '';
      AppwriteConfig.addressesCollectionId = collections['addresses'] ?? '';
      AppwriteConfig.inventoryCollectionId = collections['inventory'] ?? '';
      AppwriteConfig.bannersCollectionId = collections['banners'] ?? '';
      AppwriteConfig.couponsCollectionId = collections['coupons'] ?? '';
      AppwriteConfig.orderItemsCollectionId = collections['order_items'] ?? '';
      AppwriteConfig.analyticsCollectionId = collections['analytics'] ?? '';
      AppwriteConfig.recentlyViewedCollectionId = collections['recently_viewed'] ?? '';
      AppwriteConfig.adminSettingsCollectionId = collections['admin_settings'] ?? '';
      AppwriteConfig.productTemplatesCollectionId = collections['product_templates'] ?? '';
      AppwriteConfig.flowerPricesCollectionId = collections['flower_prices'] ?? '';
      AppwriteConfig.flowerCatalogCollectionId = collections['flower_catalog'] ?? '';
    }

    if (buckets != null) {
      AppwriteConfig.productImagesBucketId = buckets['product_images'] ?? '';
      AppwriteConfig.profileImagesBucketId = buckets['profile_images'] ?? '';
    }

    if (maps != null) {
      MapService.maptilerApiKey = maps['maptiler_key'] ?? MapService.maptilerApiKey;
    }
  }

  dynamic get(String key) => _config?[key];
}
