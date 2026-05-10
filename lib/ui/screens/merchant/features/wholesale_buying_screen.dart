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
                        color: C.background,
                      ),
                    ),
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [C.primary.withValues(alpha: 0.15), Colors.transparent],
                            )),
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
                                color: C.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'WHOLESALE DEALS',
                            style: TextStyle(
                                color: C.onSurface,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Direct procurement from verified farms.',
                            style: TextStyle(
                                color: C.onSurfaceVariant.withValues(alpha: 0.6),
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
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
      child: InteractiveCard(
        scaleFactor: 0.95,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? C.primary : C.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: isActive ? C.primary : C.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: isActive ? [
              BoxShadow(color: C.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : C.onSurfaceVariant,
              fontWeight: FontWeight.w900,
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 30,
                offset: const Offset(0, 15)),
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
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: C.onSurface,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('${products.length} Farm Offers Available',
                          style: TextStyle(
                              color: C.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            InteractiveCard(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Text('VIEW PROCUREMENT DETAILS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1)),
                ),
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
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: C.onSurfaceVariant.withValues(alpha: 0.5),
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: C.onSurface,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}
