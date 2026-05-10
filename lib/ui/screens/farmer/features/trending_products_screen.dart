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

    return Container(
      color: const Color(0xFFF6F7F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Momentum',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Products gaining traction based on recent order velocity and volume',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(Icons.auto_graph_rounded, size: 64, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Trends Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Once your products start receiving orders, we will analyze the momentum here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: trendingItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
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
    final trendColor = _getTrendColor(rank);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [trendColor, trendColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: trendColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1B1B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _MomentumBadge(orders: item.stats.totalOrders),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatTile(
                  label: 'ORDERS',
                  value: '${item.stats.totalOrders}',
                  color: const Color(0xFF1E3A8A),
                  bgColor: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 12),
                _StatTile(
                  label: 'UNITS',
                  value: item.stats.totalQuantity.toStringAsFixed(0),
                  color: const Color(0xFF065F46),
                  bgColor: const Color(0xFFF0FDF4),
                ),
                const SizedBox(width: 12),
                _StatTile(
                  label: 'REVENUE',
                  value: '₹${item.stats.totalRevenue.toStringAsFixed(0)}',
                  color: const Color(0xFF92400E),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              border: Border(top: BorderSide(color: trendColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: trendColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMomentumMessage(item.stats),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(int rank) {
    if (rank == 1) return const Color(0xFF2563EB);
    if (rank == 2) return const Color(0xFF7C3AED);
    if (rank == 3) return const Color(0xFFDB2777);
    return Colors.grey.shade600;
  }

  String _getMomentumMessage(_TrendingStats stats) {
    if (stats.totalOrders >= 20) return 'Exceptional velocity. High priority for restocking.';
    if (stats.totalOrders >= 10) return 'Strong performance. Consider scaling production.';
    if (stats.totalOrders >= 5) return 'Healthy growth. Product is gaining market share.';
    return 'Gaining visibility. Keep maintaining quality.';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: color.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentumBadge extends StatelessWidget {
  final int orders;
  const _MomentumBadge({required this.orders});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final label = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (orders >= 20) return const Color(0xFFDC2626);
    if (orders >= 10) return const Color(0xFFEA580C);
    return const Color(0xFF2563EB);
  }

  String _getLabel() {
    if (orders >= 20) return 'VIRAL VELOCITY';
    if (orders >= 10) return 'HOT PERFORMANCE';
    return 'STEADY GROWTH';
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
