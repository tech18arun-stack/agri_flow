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
                const Text('Price Comparison',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002b02))),
                const SizedBox(height: 4),
                Text('Compare your prices with other farmers',
                    style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
              ],
            ),
          ),

          // Product Filter
          if (productNames.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productNames.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _FilterChip(
                      label: 'All Products',
                      isSelected: _selectedProduct == 'all',
                      onTap: () => setState(() => _selectedProduct = 'all'),
                    );
                  }
                  final productName = productNames[index - 1];
                  return _FilterChip(
                    label: productName,
                    isSelected: _selectedProduct == productName,
                    onTap: () => setState(() => _selectedProduct = productName),
                  );
                },
              ),
            ),

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
        borderRadius: BorderRadius.circular(16),
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
          // Product Name & Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002b02))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$farmerCount farmers',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    const Icon(Icons.inventory_2, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${totalQuantity.toStringAsFixed(0)} units total',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),

          // Price Comparison Bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Market Average
                _PriceBar(
                  label: 'Market Average',
                  value: avgPrice,
                  color: Colors.blue,
                  maxValue: maxPrice,
                ),
                const SizedBox(height: 8),
                // Market Min
                _PriceBar(
                  label: 'Market Min',
                  value: minPrice,
                  color: Colors.green,
                  maxValue: maxPrice,
                ),
                const SizedBox(height: 8),
                // Market Max
                _PriceBar(
                  label: 'Market Max',
                  value: maxPrice,
                  color: Colors.orange,
                  maxValue: maxPrice,
                ),
                if (myAvgPrice != null) ...[
                  const SizedBox(height: 8),
                  // My Price (Highlighted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFc8f17a).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFc8f17a), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFF002b02)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Your Price',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF002b02))),
                        ),
                        Text('₹${myAvgPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002b02))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price Position Indicator
          if (myAvgPrice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

// ==================== PRICE BAR WIDGET ====================

class _PriceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double maxValue;

  const _PriceBar({
    required this.label,
    required this.value,
    required this.color,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxValue > 0 ? (value / maxValue) : 0;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('₹${value.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompetitive
            ? const Color(0xFFc8f17a).withValues(alpha: 0.2)
            : diff > 0
                ? const Color(0xFFffddb6)
                : const Color(0xFFc8f17a).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCompetitive
                ? Icons.check_circle
                : diff > 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
            color: isCompetitive
                ? const Color(0xFF2b3f00)
                : diff > 0
                    ? Colors.orange
                    : const Color(0xFF2b3f00),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompetitive
                      ? '✓ Your price is competitive!'
                      : diff > 0
                          ? '↑ ${percentage.toStringAsFixed(0)}% above market'
                          : '↓ ${percentage.abs().toStringAsFixed(0)}% below market',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCompetitive
                          ? const Color(0xFF2b3f00)
                          : diff > 0
                              ? Colors.orange.shade800
                              : const Color(0xFF2b3f00)),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompetitive
                      ? 'Good balance between profit and competitiveness'
                      : diff > 0
                          ? 'Consider lowering price to be more competitive'
                          : 'You could increase price for better margins',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
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

