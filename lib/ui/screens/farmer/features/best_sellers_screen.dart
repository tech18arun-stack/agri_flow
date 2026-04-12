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
                const Text('Best Sellers',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002b02))),
                const SizedBox(height: 4),
                Text('Your top-performing products by sales',
                    style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
              ],
            ),
          ),

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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sales yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Your best sellers will appear here',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bestSellers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final isTopPerformer = rank <= 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopPerformer
            ? Border.all(color: _getMedalColor(rank), width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: isTopPerformer
                  ? _getMedalColor(rank).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Rank
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Medal/Rank
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getMedalColor(rank),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Icon(
                            rank == 1
                                ? Icons.emoji_events
                                : rank == 2
                                    ? Icons.emoji_events
                                    : Icons.emoji_events,
                            size: 28,
                            color: Colors.white,
                          )
                        : Text(
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
                      Text('${item.sales.orderCount} orders • ${item.sales.totalSold.toStringAsFixed(0)} units sold',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                if (isTopPerformer)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMedalColor(rank).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rank == 1
                          ? '🏆 #1 Seller'
                          : rank == 2
                              ? '🥈 Runner Up'
                              : '🥉 Third Place',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getMedalColor(rank)),
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
                // Revenue
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
                        const Text('Total Revenue',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('₹${item.sales.totalRevenue.toStringAsFixed(0)}',
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
                        Text(item.sales.totalSold.toStringAsFixed(0),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2b3f00))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Performance Indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getPerformanceColor(item.sales).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _getPerformanceColor(item.sales).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPerformanceIcon(item.sales),
                    size: 18,
                    color: _getPerformanceColor(item.sales),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPerformanceMessage(item.sales),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getPerformanceColor(item.sales)),
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

  Color _getMedalColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.grey.shade400;
  }

  Color _getPerformanceColor(_ProductSales sales) {
    if (sales.totalRevenue >= 10000) return Colors.green;
    if (sales.totalRevenue >= 5000) return const Color(0xFFc8f17a);
    if (sales.totalRevenue >= 1000) return Colors.orange;
    return Colors.yellow.shade700;
  }

  IconData _getPerformanceIcon(_ProductSales sales) {
    if (sales.totalRevenue >= 10000) return Icons.trending_up;
    if (sales.totalRevenue >= 5000) return Icons.thumb_up;
    if (sales.totalRevenue >= 1000) return Icons.show_chart;
    return Icons.info;
  }

  String _getPerformanceMessage(_ProductSales sales) {
    if (sales.totalRevenue >= 10000) {
      return '🌟 Outstanding performer! Keep up the great work!';
    }
    if (sales.totalRevenue >= 5000) {
      return '💪 Strong seller! Consider increasing supply.';
    }
    if (sales.totalRevenue >= 1000) {
      return '📈 Good progress! Growing demand detected.';
    }
    return '🌱 Building momentum. Keep listing regularly.';
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
