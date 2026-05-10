import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';

// ==================== PRICE COMPARISON SCREEN ====================

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  String _selectedProduct = 'all';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final auth = context.watch<AuthProvider>();
    final district = auth.user?.district ?? '';
    final farmerId = auth.user?.id ?? '';

    // Get unique product names
    final productNames = products.map((p) => p.name).toSet().toList();

    return Container(
      color: const Color(0xFFF6F7F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(district),

          // Product Filter
          if (productNames.isNotEmpty) _buildProductFilter(productNames),

          const SizedBox(height: 16),

          // Comparison Content
          Expanded(
            child: _PriceComparisonContent(
              selectedProduct: _selectedProduct,
              district: district,
              farmerId: farmerId,
              allProducts: products,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String district) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Competitive Analysis',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      district.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Strategic pricing insights',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductFilter(List<String> productNames) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: productNames.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final label = isAll ? 'All Products' : productNames[index - 1];
            final value = isAll ? 'all' : label;
            final isSelected = _selectedProduct == value;

            return GestureDetector(
              onTap: () => setState(() => _selectedProduct = value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF059669) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF059669) : Colors.grey.shade200,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF059669).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== PRICE COMPARISON CONTENT ====================

class _PriceComparisonContent extends StatelessWidget {
  final String selectedProduct;
  final String district;
  final String farmerId;
  final List<ProductModel> allProducts;
  const _PriceComparisonContent({
    required this.selectedProduct,
    required this.district,
    required this.farmerId,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    // Filter products
    final filteredProducts = selectedProduct == 'all'
        ? allProducts
        : allProducts.where((p) => p.name == selectedProduct).toList();

    // Group by product name
    final productGroups = <String, List<ProductModel>>{};
    for (final product in filteredProducts) {
      if (!productGroups.containsKey(product.name)) {
        productGroups[product.name] = [];
      }
      productGroups[product.name]!.add(product);
    }

    if (productGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No products to compare',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Add products to see price comparisons',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: productGroups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final productName = productGroups.keys.elementAt(index);
        final products = productGroups[productName]!;

        return _ProductComparisonCard(
          productName: productName,
          products: products,
          farmerId: farmerId,
          district: district,
        );
      },
    );
  }
}

// ==================== PRODUCT COMPARISON CARD ====================

class _ProductComparisonCard extends StatelessWidget {
  final String productName;
  final List<ProductModel> products;
  final String farmerId;
  final String district;
  const _ProductComparisonCard({
    required this.productName,
    required this.products,
    required this.farmerId,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final allPrices = products.map((p) => p.price).toList();
    final avgPrice = allPrices.reduce((a, b) => a + b) / allPrices.length;
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final totalQuantity = products.fold(0.0, (sum, p) => sum + p.quantity);
    final farmerCount = products.map((p) => p.farmerId).toSet().length;

    // Find current farmer's product
    final myProducts = products.where((p) => p.farmerId == farmerId).toList();
    final myAvgPrice = myProducts.isNotEmpty
        ? myProducts.fold(0.0, (sum, p) => sum + p.price) / myProducts.length
        : null;

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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$farmerCount sellers • ${totalQuantity.toStringAsFixed(0)} units total',
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

          // Price Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _PriceRow(label: 'MARKET PEAK', value: maxPrice, color: const Color(0xFF991B1B), isMax: true),
                const SizedBox(height: 8),
                _PriceRow(label: 'MARKET AVERAGE', value: avgPrice, color: const Color(0xFF1E40AF)),
                const SizedBox(height: 8),
                _PriceRow(label: 'MARKET ENTRY', value: minPrice, color: const Color(0xFF065F46)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // My Position
          if (myAvgPrice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _PricePositionIndicator(
                myPrice: myAvgPrice,
                marketAvg: avgPrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isMax;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.color,
    this.isMax = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRICE POSITION INDICATOR ====================

class _PricePositionIndicator extends StatelessWidget {
  final double myPrice;
  final double marketAvg;
  final double minPrice;
  final double maxPrice;

  const _PricePositionIndicator({
    required this.myPrice,
    required this.marketAvg,
    required this.minPrice,
    required this.maxPrice,
  });

  @override
  Widget build(BuildContext context) {
    final diff = myPrice - marketAvg;
    final percentage = marketAvg > 0 ? ((diff / marketAvg) * 100) : 0;
    final isCompetitive = diff.abs() <= marketAvg * 0.1;

    final themeColor = isCompetitive 
        ? const Color(0xFF059669) 
        : diff > 0 ? const Color(0xFFD97706) : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'YOU',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Price: ₹${myPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompetitive
                          ? 'Perfectly competitive'
                          : diff > 0
                              ? '${percentage.toStringAsFixed(0)}% above average'
                              : '${percentage.abs().toStringAsFixed(0)}% below average',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: themeColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 14, color: themeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCompetitive
                        ? 'Maintain this price for optimal market performance.'
                        : diff > 0
                            ? 'Consider adjusting for higher volume.'
                            : 'Good value! Quality assurance will drive sales.',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
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
}

// ==================== FILTER CHIP WIDGET ====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002b02) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? const Color(0xFF002b02) : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

