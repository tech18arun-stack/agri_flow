class AppwriteConfig {
  static const String endpoint = 'https://api.websitescorp.com/v1';
  static const String projectId = '69d5d5ff0014699913f4';
  static const String databaseId = '69d5d6770036e6c9bfc';

  // Table/Collection IDs — match your Appwrite schema
  static const String usersTableId = 'users';
  static const String usersCollectionId = usersTableId; // alias
  static const String productsTableId = 'products';
  static const String productsCollectionId = productsTableId; // alias
  static const String ordersTableId = 'orders';
  static const String ordersCollectionId = ordersTableId;
  static const String cartTableId = 'cart';
  static const String cartCollectionId = cartTableId;
  static const String transactionsTableId = 'transactions';
  static const String transactionsCollectionId = transactionsTableId;
  static const String bidsTableId = 'bids';
  static const String bidsCollectionId = bidsTableId;
  static const String reviewsTableId = 'reviews';
  static const String reviewsCollectionId = reviewsTableId;
  static const String notificationsTableId = 'notifications';
  static const String notificationsCollectionId = notificationsTableId;
  static const String priceLogsTableId = 'price_logs';
  static const String priceLogsCollectionId = priceLogsTableId; // alias
  static const String aggregatedPricesTableId = 'aggregated_prices';
  static const String aggregatedPricesCollectionId = aggregatedPricesTableId; // alias
  static const String priceTrendsTableId = 'price_trends';
  static const String priceTrendsCollectionId = priceTrendsTableId; // alias
  static const String categoriesTableId = 'categories';
  static const String categoriesCollectionId = categoriesTableId;
  static const String districtsTableId = 'districts';
  static const String districtsCollectionId = districtsTableId;
  static const String appSettingsTableId = 'app_settings';
  static const String appSettingsCollectionId = appSettingsTableId;
  static const String talukasTableId = 'talukas';
  static const String talukasCollectionId = talukasTableId;
  static const String municipalitiesTableId = 'municipalities';
  static const String municipalitiesCollectionId = municipalitiesTableId;
  static const String loiRequestsTableId = 'loi_requests';
  static const String loiRequestsCollectionId = loiRequestsTableId;
  static const String wishlistTableId = 'wishlist';
  static const String wishlistCollectionId = wishlistTableId;
  static const String addressesTableId = 'addresses';
  static const String addressesCollectionId = addressesTableId;
  static const String inventoryTableId = 'inventory';
  static const String inventoryCollectionId = inventoryTableId;
  static const String bannersTableId = 'banners';
  static const String bannersCollectionId = bannersTableId;
  static const String couponsTableId = 'coupons';
  static const String couponsCollectionId = couponsTableId;
  static const String orderItemsTableId = 'order_items';
  static const String orderItemsCollectionId = orderItemsTableId;
  static const String analyticsTableId = 'analytics';
  static const String analyticsCollectionId = analyticsTableId;
  static const String recentlyViewedTableId = 'recently_viewed';
  static const String recentlyViewedCollectionId = recentlyViewedTableId;
  static const String adminSettingsTableId = 'admin_settings';
  static const String adminSettingsCollectionId = adminSettingsTableId;
  static const String productTemplatesTableId = 'product_templates';
  static const String productTemplatesCollectionId = productTemplatesTableId;

  // Bucket IDs
  static const String productImagesBucketId = 'product_images';
  static const String profileImagesBucketId = 'profile_images';
}
