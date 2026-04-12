import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';

// ==================== WHOLESALE BUYING SCREEN ====================

class WholesaleBuyingScreen extends StatefulWidget {
  const WholesaleBuyingScreen({super.key});

  @override
  State<WholesaleBuyingScreen> createState() => _WholesaleBuyingScreenState();
}

class _WholesaleBuyingScreenState extends State<WholesaleBuyingScreen> {
  String _selectedCategory = 'all';
  final String _sortBy = 'price_low';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProv, child) {
        final products = productProv.all;
        final filteredProducts = _selectedCategory == 'all'
            ? products
            : products.where((p) => p.category == _selectedCategory).toList();

        // Sort products
        if (_sortBy == 'price_low') {
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        } else if (_sortBy == 'price_high') {
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        }

        // Group by product name
        final Map<String, List<ProductModel>> productGroups = {};
        for (var p in filteredProducts) {
          if (!productGroups.containsKey(p.name)) {
            productGroups[p.name] = [];
          }
          productGroups[p.name]!.add(p);
        }

        return Container(
          color: C.background,
          child: CustomScrollView(
            slivers: [
              // Smart Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 240,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [C.primary, C.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MARKET INTELLIGENCE',
                            style: TextStyle(
                                color: C.tertiaryFixed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'WHOLESALE DEALS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Direct procurement from verified farms.',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _FilterChip(
                                label: 'All Produce',
                                isActive: _selectedCategory == 'all',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'all')),
                            _FilterChip(
                                label: 'Vegetables',
                                isActive: _selectedCategory == 'vegetables',
                                onTap: () => setState(
                                    () => _selectedCategory = 'vegetables')),
                            _FilterChip(
                                label: 'Fruits',
                                isActive: _selectedCategory == 'fruits',
                                onTap: () => setState(
                                    () => _selectedCategory = 'fruits')),
                            _FilterChip(
                                label: 'Grains',
                                isActive: _selectedCategory == 'grains',
                                onTap: () => setState(
                                    () => _selectedCategory = 'grains')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Deal Grid
              if (productGroups.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No active deals found',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final name = productGroups.keys.elementAt(index);
                        final group = productGroups[name]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _WholesaleDealCardModern(
                            key: ValueKey(name),
                            productName: name,
                            products: group,
                          ),
                        );
                      },
                      childCount: productGroups.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? C.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: isActive ? C.primary : Colors.grey.shade200),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _WholesaleDealCardModern extends StatelessWidget {
  final String productName;
  final List<ProductModel> products;
  const _WholesaleDealCardModern(
      {super.key, required this.productName, required this.products});

  @override
  Widget build(BuildContext context) {
    final minPrice = products.fold(
        double.infinity, (min, p) => p.price < min ? p.price : min);
    final maxPrice =
        products.fold(0.0, (max, p) => p.price > max ? p.price : max);
    final totalQty = products.fold(0.0, (sum, p) => sum + p.quantity);

    return InteractiveCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: C.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16)),
                  child:
                      const Icon(Icons.inventory_2_rounded, color: C.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF1e1b4b),
                              letterSpacing: -0.5)),
                      Text('${products.length} Farm Offers Available',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatTile(
                    label: 'PRICE RANGE',
                    value: minPrice == maxPrice
                        ? '₹${minPrice.toInt()}'
                        : '₹${minPrice.toInt()} - ₹${maxPrice.toInt()}'),
                _StatTile(
                    label: 'TOTAL YIELD', value: '${totalQty.toInt()} KG'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('VIEW PROCUREMENT DETAILS',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1)),
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
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade400,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1e1b4b))),
        ],
      ),
    );
  }
}
