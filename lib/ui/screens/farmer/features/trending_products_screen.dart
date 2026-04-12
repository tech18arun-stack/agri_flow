import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/responsive_containers.dart';

// ==================== TRENDING PRODUCTS SCREEN ====================

class TrendingProductsScreen extends StatelessWidget {
  const TrendingProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final farmerId = auth.user?.id ?? '';
    final orders = context.watch<OrderProvider>().orders;
    final products = context.watch<ProductProvider>().all;

    return ResponsiveScreen(
      child: Container(
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
                  const Text('Trending Products',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002b02))),
                  const SizedBox(height: 4),
                  Text('Products gaining momentum based on order volume',
                      style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                ],
              ),
            ),

            // Trending Products List
            Expanded(
              child: _TrendingProductsList(
                farmerId: farmerId,
                orders: orders,
                allProducts: products,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TRENDING PRODUCTS LIST ====================

class _TrendingProductsList extends StatelessWidget {
  final String farmerId;
  final List<OrderModel> orders;
  final List<ProductModel> allProducts;
  const _TrendingProductsList({
    required this.farmerId,
    required this.orders,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    // Filter orders for this farmer
    final farmerOrders =
        orders.where((o) => o.farmerId == farmerId).toList();

    // Calculate order volume per product
    final productVolume = <String, _TrendingStats>{};

    for (final order in farmerOrders) {
      for (final item in order.items) {
        if (!productVolume.containsKey(item.productId)) {
          productVolume[item.productId] = _TrendingStats(
            productId: item.productId,
            productName: item.productName,
            totalOrders: 0,
            totalQuantity: 0,
            totalRevenue: 0,
            lastOrderDate: order.createdAt,
          );
        }

        final current = productVolume[item.productId]!;
        productVolume[item.productId] = _TrendingStats(
          productId: item.productId,
          productName: item.productName,
          totalOrders: current.totalOrders + 1,
          totalQuantity: current.totalQuantity + item.quantity,
          totalRevenue: current.totalRevenue + (item.price * item.quantity),
          lastOrderDate: order.createdAt.isAfter(current.lastOrderDate)
              ? order.createdAt
              : current.lastOrderDate,
        );
      }
    }

    // Build trending items with current product details
    final trendingItems = productVolume.values.map((stats) {
      final product = allProducts.firstWhere(
        (p) => p.id == stats.productId,
        orElse: () => ProductModel(
          id: stats.productId,
          name: stats.productName,
          category: 'other',
          price: stats.totalRevenue / stats.totalQuantity,
          quantity: 0,
          unit: 'kg',
          location: '',
          farmerName: '',
          farmerId: farmerId,
        ),
      );

      return _TrendingItem(
        product: product,
        stats: stats,
      );
    }).toList();

    // Sort by total orders (volume indicator)
    trendingItems.sort((a, b) => b.stats.totalOrders.compareTo(a.stats.totalOrders));

    if (trendingItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No trending data yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Your trending products will appear here once orders come in',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trendingItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = trendingItems[index];
        return _TrendingProductCard(
            item: item, rank: index + 1, totalItems: trendingItems.length);
      },
    );
  }
}

// ==================== TRENDING PRODUCT CARD ====================

class _TrendingProductCard extends StatelessWidget {
  final _TrendingItem item;
  final int rank;
  final int totalItems;
  const _TrendingProductCard(
      {required this.item, required this.rank, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final isHot = rank <= 3;
    final trendLevel = _getTrendLevel(item.stats.totalOrders);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHot
            ? Border.all(color: _getTrendColor(rank), width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: isHot
                  ? _getTrendColor(rank).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Rank & Trend Badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTrendColor(rank),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002b02))),
                      const SizedBox(height: 4),
                      Text('${item.stats.totalOrders} orders • ${item.stats.totalQuantity.toStringAsFixed(0)} units',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                // Trend Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTrendColor(rank).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.whatshot,
                          size: 14, color: _getTrendColor(rank)),
                      const SizedBox(width: 4),
                      Text(
                        trendLevel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _getTrendColor(rank)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Order Volume
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf5f4ed),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Volume',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${item.stats.totalOrders}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002b02))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Units Sold
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFc8f17a).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Units Sold',
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF2b3f00),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(item.stats.totalQuantity.toStringAsFixed(0),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2b3f00))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Revenue
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFffddb6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Revenue',
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF735a3a),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('₹${item.stats.totalRevenue.toStringAsFixed(0)}',
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
          ),

          const SizedBox(height: 16),

          // Trending Indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getMomentumColor(item.stats).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _getMomentumColor(item.stats).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMomentumIcon(item.stats),
                    size: 18,
                    color: _getMomentumColor(item.stats),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMomentumMessage(item.stats),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getMomentumColor(item.stats)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(int rank) {
    if (rank == 1) return const Color(0xFFc8f17a);
    if (rank == 2) return Colors.orange;
    if (rank == 3) return Colors.yellow.shade700;
    return Colors.grey.shade400;
  }

  String _getTrendLevel(int orders) {
    if (orders >= 20) return 'VIRAL';
    if (orders >= 10) return 'HOT';
    if (orders >= 5) return 'RISING';
    return 'NEW';
  }

  Color _getMomentumColor(_TrendingStats stats) {
    if (stats.totalOrders >= 20) return Colors.green;
    if (stats.totalOrders >= 10) return const Color(0xFFc8f17a);
    if (stats.totalOrders >= 5) return Colors.orange;
    return Colors.blue;
  }

  IconData _getMomentumIcon(_TrendingStats stats) {
    if (stats.totalOrders >= 20) return Icons.local_fire_department;
    if (stats.totalOrders >= 10) return Icons.whatshot;
    if (stats.totalOrders >= 5) return Icons.trending_up;
    return Icons.auto_graph;
  }

  String _getMomentumMessage(_TrendingStats stats) {
    if (stats.totalOrders >= 20) {
      return '🔥 Viral product! Extremely high demand across all orders.';
    }
    if (stats.totalOrders >= 10) {
      return '💥 Hot seller! Consider increasing stock to meet demand.';
    }
    if (stats.totalOrders >= 5) {
      return '📈 Rising star! Growing interest from buyers.';
    }
    return '🌟 New entrant! Keep listing to build momentum.';
  }
}

// ==================== MODELS ====================

class _TrendingStats {
  final String productId;
  final String productName;
  final int totalOrders;
  final double totalQuantity;
  final double totalRevenue;
  final DateTime lastOrderDate;

  const _TrendingStats({
    required this.productId,
    required this.productName,
    required this.totalOrders,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.lastOrderDate,
  });
}

class _TrendingItem {
  final ProductModel product;
  final _TrendingStats stats;

  const _TrendingItem({
    required this.product,
    required this.stats,
  });
}
