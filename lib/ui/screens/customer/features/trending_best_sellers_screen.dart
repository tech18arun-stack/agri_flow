import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';

class _ResponsiveBreakpoints {
  static double maxContentWidth = 1200;
  static int gridCrossAxisCount(double width) {
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 5;
    return 6;
  }
}

// ==================== TRENDING & BEST SELLERS SCREEN ====================

class TrendingAndBestSellersScreen extends StatelessWidget {
  const TrendingAndBestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isInfinite
            ? _ResponsiveBreakpoints.maxContentWidth
            : constraints.maxWidth;
        final crossAxisCount =
            _ResponsiveBreakpoints.gridCrossAxisCount(availableWidth);

        return Container(
          color: C.background,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _ResponsiveBreakpoints.maxContentWidth),
              child: CustomScrollView(
                slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe91e63), Color(0xFFc2185b)],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.whatshot, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    const Text('Trending Now',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Trending Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔥 Trending This Week',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002b02))),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= products.length) return null;
                  return _TrendingProductCard(
                    product: products[index],
                    rank: index + 1,
                  );
                },
                childCount: products.length.clamp(0, 6),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Best Sellers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text('⭐ Best Sellers',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002b02))),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= products.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BestSellerCard(
                      product: products[index],
                      rank: index + 1,
                    ),
                  );
                },
                childCount: products.length.clamp(0, 5),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
            ),
          ),
        );
        },
    );
  }
}

// ==================== TRENDING PRODUCT CARD ====================

class _TrendingProductCard extends StatelessWidget {
  final ProductModel product;
  final int rank;

  const _TrendingProductCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: rank <= 3
              ? Border.all(
                  color: rank == 1
                      ? const Color(0xFFFFD700)
                      : rank == 2
                          ? const Color(0xFFC0C0C0)
                          : const Color(0xFFCD7F32),
                  width: 2)
              : null,
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
            // Rank Badge & Image
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: C.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      product.category == 'vegetables'
                          ? Icons.grass
                          : product.category == 'fruits'
                              ? Icons.apple
                              : Icons.eco,
                      size: 48,
                      color: const Color(0xFF002b02).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? rank == 1
                              ? const Color(0xFFFFD700)
                              : rank == 2
                                  ? const Color(0xFFC0C0C0)
                                  : const Color(0xFFCD7F32)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002b02))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BEST SELLER CARD ====================

class _BestSellerCard extends StatelessWidget {
  final ProductModel product;
  final int rank;

  const _BestSellerCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? rank == 1
                        ? const Color(0xFFFFD700)
                        : rank == 2
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: C.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  product.category == 'vegetables'
                      ? Icons.grass
                      : product.category == 'fruits'
                          ? Icons.apple
                          : Icons.eco,
                  size: 28,
                  color: const Color(0xFF002b02).withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('4.5',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('₹${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002b02))),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
