import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                color: C.background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.whatshot, color: Color(0xFFEF4444), size: 14),
                        SizedBox(width: 6),
                        Text('MARKET HOTLIST', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Trending & Top Picks',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface,
                          letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text('The highest velocity products across Tamil Nadu today',
                      style: TextStyle(
                          fontSize: 14,
                          color: C.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔥 Dynamic Trending',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface,
                          letterSpacing: -0.5)),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text('⭐ Performance Leaders',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface,
                      letterSpacing: -0.5)),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
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
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: rank <= 3
                ? (rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFB45309))).withValues(alpha: 0.5)
                : C.outlineVariant.withValues(alpha: 0.5),
            width: rank == 1 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8))
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
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => Center(
                              child: Icon(Icons.eco, size: 48, color: const Color(0xFF002b02).withValues(alpha: 0.1)),
                            ),
                          ),
                        )
                      : Center(
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
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (rank <= 3
                          ? (rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFB45309)))
                          : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900, color: C.onSurface)),
                      if (product.nameTa.isNotEmpty)
                        Text(product.nameTa,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0d631b))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: C.primary,
                              letterSpacing: -0.5)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.add, size: 14, color: C.primary),
                      ),
                    ],
                  ),
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
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (rank <= 3
                    ? (rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFB45309)))
                    : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: rank <= 3 ? Colors.white : Colors.grey.shade600),
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
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(
                            child: Icon(Icons.eco, size: 28, color: const Color(0xFF002b02).withValues(alpha: 0.1)),
                          ),
                        ),
                      )
                    : Center(
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
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -0.5)),
                      if (product.nameTa.isNotEmpty)
                        Text(product.nameTa,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0d631b))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('4.9 (120 reviews)',
                          style: TextStyle(
                              fontSize: 10, color: C.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('₹${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: C.primary,
                          letterSpacing: -1)),
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
