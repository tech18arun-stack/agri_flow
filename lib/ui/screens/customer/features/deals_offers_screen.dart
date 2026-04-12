import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';

class _ResponsiveBreakpoints {
  static double maxContentWidth = 1200;
}

// ==================== DEALS & OFFERS SCREEN ====================

class DealsAndOffersScreen extends StatelessWidget {
  const DealsAndOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.all;

    return Container(
      color: C.background,
      child: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? _buildErrorState(context, provider.error!)
              : products.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(context, products),
    );
  }

  Widget _buildContent(BuildContext context, List<ProductModel> products) {
    final deals = _findBestDeals(products);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _ResponsiveBreakpoints.maxContentWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return CustomScrollView(
              slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFff9800), Color(0xFFf57c00)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text('Today\'s Deals',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Fresh produce at unbeatable prices',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Flash Sale Timer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF002b02),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.horizontal,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(Icons.flash_on,
                        color: Color(0xFFc8f17a), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('⚡ Flash Sale!',
                              style: TextStyle(
                                  fontSize: isWide ? 18 : 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFc8f17a))),
                          Text('Ends in 05:23:45',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFc8f17a),
                        foregroundColor: const Color(0xFF002b02),
                      ),
                      child: const Text('Shop Now',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Best Deals Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Best Deals',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002b02))),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    child: const Text('View All',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          // Deals List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= deals.length) return null;
                  final deal = deals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DealCard(
                      product: deal.product,
                      discount: deal.discount,
                    ),
                  );
                },
                childCount: deals.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      );
          },
        ),
      ),
    );
  }


  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text('Failed to load deals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<ProductProvider>().loadAll(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFff9800).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.local_offer_outlined, size: 64, color: Color(0xFFff9800)),
            ),
            const SizedBox(height: 24),
            const Text('No deals available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Check back later for fresh deals!',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  List<_Deal> _findBestDeals(List<ProductModel> products) {
    // Mock deals - in real app, calculate based on price history
    return products.take(5).map((product) {
      final discount = (10 + (product.price * 0.1)).round().toDouble();
      return _Deal(
        product: product,
        discount: discount.clamp(0, 50),
      );
    }).toList();
  }
}

class _Deal {
  final ProductModel product;
  final double discount;

  const _Deal({required this.product, required this.discount});
}

// ==================== DEAL CARD ====================

class _DealCard extends StatelessWidget {
  final ProductModel product;
  final double discount;

  const _DealCard({required this.product, required this.discount});

  @override
  Widget build(BuildContext context) {
    final discountedPrice = (product.price * (1 - discount / 100)).round();

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          final imageSize = isWide ? 120.0 : 100.0;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFff9800), width: 2),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFff9800).withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: imageSize,
                  height: imageSize,
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
                      size: 40,
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
                      // Discount Badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${discount.toInt()}% OFF',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002b02))),
                      const SizedBox(height: 4),
                      Text('${product.location} • ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('₹$discountedPrice',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFff9800))),
                          const SizedBox(width: 8),
                          Text(
                            '₹${product.price.toInt()}',
                            style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Add to Cart Button
                ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002b02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 20),
                      SizedBox(height: 4),
                      Text('Add', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
