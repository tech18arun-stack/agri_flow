import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/interactive_card.dart';

// ==================== MARKET PRICES SCREEN ====================

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  String _selectedCategory = 'all';
  final Map<String, String> _categoryIcons = {
    'all': '🌾',
    'vegetables': '🥬',
    'fruits': '🍎',
    'grains': '🍚',
    'pulses': '🫘',
    'greens': '🍃',
    'spices': '🌿',
    'flowers': '🌸',
    'tubers': '🥔',
    'plantation': '☕',
    'oilseeds': '🥜',
    'industrial': '🏭',
    'processed': '🧴',
  };

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final auth = context.watch<AuthProvider>();
    final district = auth.user?.district ?? 'Coimbatore';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          _buildSliverHeader(district),

          // Filters & Stats
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryFilter(),
                _buildMarketInsights(products.length),
              ],
            ),
          ),

          // Market Price List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: _MarketPriceList(
              category: _selectedCategory,
              district: district,
              allProducts: products,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(String district) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF064E3B),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.show_chart_rounded, size: 280, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFc8f17a),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF064E3B)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MARKET INTELLIGENCE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$district District',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _categoryIcons.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final entry = _categoryIcons.entries.elementAt(index);
            final category = entry.key;
            final isSelected = category == _selectedCategory;
            return ChoiceChip(
              label: Text(
                '${entry.value} ${category[0].toUpperCase()}${category.substring(1)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: const Color(0xFF059669),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF059669) : Colors.grey.shade100,
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 8 : 0,
              shadowColor: const Color(0xFF059669).withValues(alpha: 0.3),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketInsights(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          _buildMiniStat(Icons.trending_up_rounded, 'Trending Up', const Color(0xFF059669)),
          const SizedBox(width: 12),
          _buildMiniStat(Icons.inventory_2_outlined, '$count Listings', const Color(0xFF1E40AF)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
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
      final avgPrice = products.fold(0.0, (sum, p) => sum + p.price) / products.length;
      final minPrice = products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      final maxPrice = products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
      final totalQuantity = products.fold(0.0, (sum, p) => sum + p.quantity);
      final farmerCount = products.map((p) => p.farmerId).toSet().length;
      final unit = products.first.unit;
      final nameTa = products.first.nameTa;

      return _MarketItem(
        productName: entry.key,
        productNameTa: nameTa,
        avgPrice: avgPrice,
        minPrice: minPrice,
        maxPrice: maxPrice,
        totalQuantity: totalQuantity,
        farmerCount: farmerCount,
        unit: unit,
      );
    }).toList();

    marketItems.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    if (marketItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📈', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              const Text(
                'Initializing Market Data...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF064E3B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to list in $district',
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MarketPriceCard(item: marketItems[index]),
          );
        },
        childCount: marketItems.length,
      ),
    );
  }
}

// ==================== MARKET PRICE CARD ====================

class _MarketPriceCard extends StatelessWidget {
  final _MarketItem item;
  const _MarketPriceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1B1B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        item.productNameTa,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                _DemandBadge(quantity: item.totalQuantity),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatTile(
                  label: 'AVERAGE',
                  value: '₹${item.avgPrice.toStringAsFixed(0)}',
                  unit: item.unit,
                  color: const Color(0xFF059669),
                  isMain: true,
                ),
                const SizedBox(width: 12),
                _StatTile(
                  label: 'RANGE',
                  value: '₹${item.minPrice.toStringAsFixed(0)} - ₹${item.maxPrice.toStringAsFixed(0)}',
                  unit: '',
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _InfoSnippet(Icons.groups_outlined, '${item.farmerCount} Sellers'),
                  const Spacer(),
                  _InfoSnippet(Icons.analytics_outlined, '${item.totalQuantity.toStringAsFixed(0)} ${item.unit} available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isMain;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isMain ? 3 : 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMain ? 24 : 14,
                  fontWeight: FontWeight.w900,
                  color: isMain ? const Color(0xFF1B1B1B) : Colors.grey.shade600,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/$unit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSnippet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoSnippet(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _DemandBadge extends StatelessWidget {
  final double quantity;
  const _DemandBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final label = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getColor() {
    if (quantity >= 1000) return const Color(0xFF059669);
    if (quantity >= 500) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _getLabel() {
    if (quantity >= 1000) return 'HIGH DEMAND';
    if (quantity >= 500) return 'MODERATE';
    return 'LIMITED SUPPLY';
  }
}

// ==================== MARKET ITEM MODEL ====================

class _MarketItem {
  final String productName;
  final String productNameTa;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double totalQuantity;
  final int farmerCount;
  final String unit;

  const _MarketItem({
    required this.productName,
    required this.productNameTa,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.totalQuantity,
    required this.farmerCount,
    required this.unit,
  });
}
