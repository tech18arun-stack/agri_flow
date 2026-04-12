import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';

// ==================== MARKET PRICES SCREEN ====================

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'vegetables',
    'fruits',
    'grains',
    'spices',
    'flowers'
  ];

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final auth = context.watch<AuthProvider>();
    final district = auth.user?.district ?? '';

    return Container(
      color: C.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Market Prices',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002b02))),
                const SizedBox(height: 4),
                Text('Live prices from $district district',
                    style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
              ],
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF002b02)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFF002b02)
                              : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryLabel(category),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade700),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Market Price Cards
          Expanded(
            child: _MarketPriceList(
              category: _selectedCategory,
              district: district,
              allProducts: products,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'vegetables':
        return 'Vegetables';
      case 'fruits':
        return 'Fruits';
      case 'grains':
        return 'Grains';
      case 'spices':
        return 'Spices';
      case 'flowers':
        return 'Flowers';
      default:
        return category;
    }
  }
}

// ==================== MARKET PRICE LIST ====================

class _MarketPriceList extends StatelessWidget {
  final String category;
  final String district;
  final List<ProductModel> allProducts;
  const _MarketPriceList(
      {required this.category,
      required this.district,
      required this.allProducts});

  @override
  Widget build(BuildContext context) {
    // Filter products by category
    final filteredProducts = category == 'all'
        ? allProducts
        : allProducts.where((p) => p.category == category).toList();

    // Group by product name and calculate averages
    final priceMap = <String, List<ProductModel>>{};
    for (final product in filteredProducts) {
      if (!priceMap.containsKey(product.name)) {
        priceMap[product.name] = [];
      }
      priceMap[product.name]!.add(product);
    }

    // Calculate averages and sort by demand
    final marketItems = priceMap.entries.map((entry) {
      final products = entry.value;
      final avgPrice =
          products.fold(0.0, (sum, p) => sum + p.price) / products.length;
      final minPrice = products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      final maxPrice = products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
      final totalQuantity =
          products.fold(0.0, (sum, p) => sum + p.quantity);
      final farmerCount = products.map((p) => p.farmerId).toSet().length;

      return _MarketItem(
        productName: entry.key,
        avgPrice: avgPrice,
        minPrice: minPrice,
        maxPrice: maxPrice,
        totalQuantity: totalQuantity,
        farmerCount: farmerCount,
        products: products,
      );
    }).toList();

    // Sort by total quantity (demand indicator)
    marketItems.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    if (marketItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No market data available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Add products to see market prices',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: marketItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = marketItems[index];
        return _MarketPriceCard(item: item, district: district);
      },
    );
  }
}

// ==================== MARKET PRICE CARD ====================

class _MarketPriceCard extends StatelessWidget {
  final _MarketItem item;
  final String district;
  const _MarketPriceCard({required this.item, required this.district});

  @override
  Widget build(BuildContext context) {
    final priceProvider = context.read<PriceEngineProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name & Trending Badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF002b02))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${item.farmerCount} farmers selling',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
              // Demand Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDemandColor(item.totalQuantity).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up,
                        size: 14, color: _getDemandColor(item.totalQuantity)),
                    const SizedBox(width: 4),
                    Text(
                      _getDemandLabel(item.totalQuantity),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getDemandColor(item.totalQuantity)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Statistics
          Row(
            children: [
              // Average Price
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf5f4ed),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Avg Price',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('₹${item.avgPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF002b02))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Min Price
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc8f17a).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Min Price',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2b3f00),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('₹${item.minPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2b3f00))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Max Price
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFffddb6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Max Price',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF735a3a),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('₹${item.maxPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF735a3a))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total Quantity Available
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                  'Total Available: ${item.totalQuantity.toStringAsFixed(0)} units',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDemandColor(double quantity) {
    if (quantity >= 1000) return const Color(0xFFc8f17a); // High demand
    if (quantity >= 500) return Colors.orange;
    if (quantity >= 200) return Colors.yellow.shade700;
    return Colors.red;
  }

  String _getDemandLabel(double quantity) {
    if (quantity >= 1000) return 'HIGH';
    if (quantity >= 500) return 'MODERATE';
    if (quantity >= 200) return 'LOW';
    return 'VERY LOW';
  }
}

// ==================== MARKET ITEM MODEL ====================

class _MarketItem {
  final String productName;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double totalQuantity;
  final int farmerCount;
  final List<ProductModel> products;

  const _MarketItem({
    required this.productName,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.totalQuantity,
    required this.farmerCount,
    required this.products,
  });
}
