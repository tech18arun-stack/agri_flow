class AppwriteConfig {
  static String endpoint = '';
  static String projectId = '';
  static String databaseId = '';

  // Collection IDs
  static String usersCollectionId = '';
  static String productsCollectionId = '';
  static String ordersCollectionId = '';
  static String cartCollectionId = '';
  static String transactionsCollectionId = '';
  static String bidsCollectionId = '';
  static String reviewsCollectionId = '';
  static String notificationsCollectionId = '';
  static String priceLogsCollectionId = '';
  static String aggregatedPricesCollectionId = '';
  static String priceTrendsCollectionId = '';
  static String categoriesCollectionId = '';
  static String districtsCollectionId = '';
  static String appSettingsCollectionId = '';
  static String talukasCollectionId = '';
  static String municipalitiesCollectionId = '';
  static String loiRequestsCollectionId = '';
  static String wishlistCollectionId = '';
  static String addressesCollectionId = '';
  static String inventoryCollectionId = '';
  static String bannersCollectionId = '';
  static String couponsCollectionId = '';
  static String orderItemsCollectionId = '';
  static String analyticsCollectionId = '';
  static String recentlyViewedCollectionId = '';
  static String adminSettingsCollectionId = '';
  static String productTemplatesCollectionId = '';
  static String harvestPreviewsCollectionId = '';

  // Flower Price System
  static String flowerPricesCollectionId = '';
  static String flowerCatalogCollectionId = '';

  // Bucket IDs
  static String productImagesBucketId = '';
  static String profileImagesBucketId = '';

  // Legacy compatibility getters
  static String get productsTableId => productsCollectionId;
  static String get usersTableId => usersCollectionId;
  static String get priceLogsTableId => priceLogsCollectionId;
  static String get aggregatedPricesTableId => aggregatedPricesCollectionId;
  static String get priceTrendsTableId => priceTrendsCollectionId;
  static String get ordersTableId => ordersCollectionId;
  static String get cartTableId => cartCollectionId;
  static String get transactionsTableId => transactionsCollectionId;
  static String get categoriesTableId => categoriesCollectionId;
  static String get districtsTableId => districtsCollectionId;
  static String get talukasTableId => talukasCollectionId;
  static String get municipalitiesTableId => municipalitiesCollectionId;
  static String get productTemplatesTableId => productTemplatesCollectionId;
  static String get harvestPreviewsTableId => harvestPreviewsCollectionId;
}
