import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';

// ==================== BEST SELLERS SCREEN ====================

class BestSellersScreen extends StatelessWidget {
  const BestSellersScreen({super.key});

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

          // Best Sellers List
          Expanded(
            child: _BestSellersList(
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
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Excellence',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Celebrating your top-performing products by total revenue and volume',
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

// ==================== BEST SELLERS LIST ====================

class _BestSellersList extends StatelessWidget {
  final String farmerId;
  final List<OrderModel> orders;
  final List<ProductModel> allProducts;
  const _BestSellersList({
    required this.farmerId,
    required this.orders,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    // Filter orders for this farmer
    final farmerOrders =
        orders.where((o) => o.farmerId == farmerId).toList();

    // Calculate sales per product
    final productSales = <String, _ProductSales>{};

    for (final order in farmerOrders) {
      for (final item in order.items) {
        if (!productSales.containsKey(item.productId)) {
          productSales[item.productId] = _ProductSales(
            productId: item.productId,
            productName: item.productName,
            totalSold: 0,
            totalRevenue: 0,
            orderCount: 0,
            avgPrice: item.price,
          );
        }

        final current = productSales[item.productId]!;
        productSales[item.productId] = _ProductSales(
          productId: item.productId,
          productName: item.productName,
          totalSold: current.totalSold + item.quantity,
          totalRevenue: current.totalRevenue + (item.price * item.quantity),
          orderCount: current.orderCount + 1,
          avgPrice:
              (current.avgPrice * current.orderCount + item.price) /
              (current.orderCount + 1),
        );
      }
    }

    // Get current product details
    final bestSellers = productSales.values.map((sales) {
      final product = allProducts.firstWhere(
        (p) => p.id == sales.productId,
        orElse: () => ProductModel(
          id: sales.productId,
          name: sales.productName,
          category: 'other',
          price: sales.avgPrice,
          quantity: 0,
          unit: 'kg',
          location: '',
          farmerName: '',
          farmerId: farmerId,
        ),
      );

      return _BestSellerItem(
        product: product,
        sales: sales,
      );
    }).toList();

    // Sort by revenue
    bestSellers.sort((a, b) => b.sales.totalRevenue.compareTo(a.sales.totalRevenue));

    if (bestSellers.isEmpty) {
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
              child: const Icon(Icons.emoji_events_rounded, size: 64, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Sales Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF92400E),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Once your products are sold, we will showcase your top performers here.',
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
      itemCount: bestSellers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = bestSellers[index];
        return _BestSellerCard(
            item: item, rank: index + 1, totalItems: bestSellers.length);
      },
    );
  }
}

// ==================== BEST SELLER CARD ====================

class _BestSellerCard extends StatelessWidget {
  final _BestSellerItem item;
  final int rank;
  final int totalItems;
  const _BestSellerCard(
      {required this.item, required this.rank, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final themeColor = _getMedalColor(rank);

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
                // Medal
                _MedalBadge(rank: rank),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.sales.orderCount} orders • ${item.sales.totalSold.toStringAsFixed(0)} units',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
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
                _StatBox(
                  label: 'REVENUE',
                  value: '₹${item.sales.totalRevenue.toStringAsFixed(0)}',
                  color: const Color(0xFF065F46),
                  bgColor: const Color(0xFFF0FDF4),
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'AVG. PRICE',
                  value: '₹${item.sales.avgPrice.toStringAsFixed(0)}',
                  color: const Color(0xFF1E40AF),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              border: Border(top: BorderSide(color: themeColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 14, color: themeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPerformanceMessage(item.sales),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
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

  Color _getMedalColor(int rank) {
    if (rank == 1) return const Color(0xFFD97706);
    if (rank == 2) return const Color(0xFF4B5563);
    if (rank == 3) return const Color(0xFF92400E);
    return Colors.grey.shade600;
  }

  String _getPerformanceMessage(_ProductSales sales) {
    if (sales.totalRevenue >= 10000) return 'Exceptional market dominance. Primary profit driver.';
    if (sales.totalRevenue >= 5000) return 'Strong performance. Reliable revenue stream.';
    if (sales.totalRevenue >= 1000) return 'Consistent sales. Good customer retention.';
    return 'Building market presence. Potential for growth.';
  }
}

class _MedalBadge extends StatelessWidget {
  final int rank;
  const _MedalBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final isTop3 = rank <= 3;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: isTop3
            ? Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24)
            : Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Color _getColor() {
    if (rank == 1) return const Color(0xFFF59E0B);
    if (rank == 2) return const Color(0xFF94A3B8);
    if (rank == 3) return const Color(0xFFB45309);
    return const Color(0xFF64748B);
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                fontSize: 18,
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

// ==================== MODELS ====================

class _ProductSales {
  final String productId;
  final String productName;
  final double totalSold;
  final double totalRevenue;
  final int orderCount;
  final double avgPrice;

  const _ProductSales({
    required this.productId,
    required this.productName,
    required this.totalSold,
    required this.totalRevenue,
    required this.orderCount,
    required this.avgPrice,
  });
}

class _BestSellerItem {
  final ProductModel product;
  final _ProductSales sales;

  const _BestSellerItem({
    required this.product,
    required this.sales,
  });
}
