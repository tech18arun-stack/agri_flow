import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models.dart';
import '../../../../core/constants/colors.dart';
import '../../../../ui/widgets/premium_product_cards.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../widgets/interactive_card.dart';
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

class TrendingAndBestSellersScreen extends StatelessWidget {
  const TrendingAndBestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final trending = products.where((p) => p.rating >= 4.5).take(6).toList();
    final topPerformers = products.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isInfinite ? 1200.0 : constraints.maxWidth;
        final crossAxisCount = _ResponsiveBreakpoints.gridCrossAxisCount(availableWidth);

        return Container(
          color: const Color(0xFFF8F9FB),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Hotlist Header
              SliverToBoxAdapter(
                child: _HotlistHeader(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Dynamic Trending Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dynamic Trending',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _TrendingProductCard(
                        product: trending[index],
                        rank: index + 1,
                      );
                    },
                    childCount: trending.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Performance Leaders List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14532D),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Performance Leaders',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _BestSellerCard(
                          product: topPerformers[index],
                          rank: index + 1,
                        ),
                      );
                    },
                    childCount: topPerformers.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

// ==================== LUXURY COMPONENTS ====================

class _HotlistHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.whatshot_rounded, color: Color(0xFFEF4444), size: 14),
                SizedBox(width: 6),
                Text(
                  'MARKET HOTLIST',
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Trending & Top Picks',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time market velocity across Tamil Nadu. Updated hourly.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _TrendingProductCard extends StatelessWidget {
  final ProductModel product;
  final int rank;

  const _TrendingProductCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    final Color rankColor = _getRankColor(rank);

    return InteractiveCard(
      onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: rankColor.withValues(alpha: 0.1), width: rank <= 3 ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: _buildImage(context),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _RankBadge(rank: rank, color: rankColor),
                ),
                if (product.organic)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                      ),
                      child: const Text(
                        '🌿 PURE',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF14532D)),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5),
                  ),
                  Text(
                    product.nameTa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF14532D)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -1),
                          ),
                          Text(
                            'per ${product.unit}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14532D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF14532D).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white),
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

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFB800); // Gold
    if (rank == 2) return const Color(0xFF94A3B8); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFFE5E7EB);
  }

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return Center(child: Icon(CategoryUtils.getIcon(product.category), size: 48, color: const Color(0xFFE5E7EB)));
    }
    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
    );
  }
}

class _BestSellerCard extends StatelessWidget {
  final ProductModel product;
  final int rank;

  const _BestSellerCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _RankBadge(rank: rank, color: _getRankColor(rank), compact: true),
            const SizedBox(width: 16),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(context),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5),
                  ),
                  Text(
                    product.nameTa,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF14532D)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}/${product.unit}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD1D5DB), size: 16),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFB800);
    if (rank == 2) return const Color(0xFF94A3B8);
    if (rank == 3) return const Color(0xFFCD7F32);
    return const Color(0xFFF3F4F6);
  }

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return Center(child: Icon(CategoryUtils.getIcon(product.category), size: 32, color: const Color(0xFFE5E7EB)));
    }
    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;
  final bool compact;

  const _RankBadge({required this.rank, required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 10, vertical: compact ? 12 : 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(compact ? 16 : 12),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank <= 3) ...[
            Icon(Icons.emoji_events_rounded, size: compact ? 16 : 12, color: rank <= 3 && color != const Color(0xFFF3F4F6) ? Colors.white : const Color(0xFF6B7280)),
            if (!compact) const SizedBox(width: 6),
          ],
          if (!compact)
            Text(
              'RANK #$rank',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
          if (compact && rank > 3)
            Text(
              '$rank',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }
}
