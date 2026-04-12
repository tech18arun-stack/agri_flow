import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/interactive_card.dart';

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

// ==================== CATEGORIES BROWSING SCREEN ====================

class CategoriesBrowsingScreen extends StatelessWidget {
  const CategoriesBrowsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;

    return LayoutBuilder(
      builder: (context, constraints) {
        final categories = [
          CategoryData(
            name: 'Vegetables',
            icon: Icons.grass,
            color: const Color(0xFF4CAF50),
            products:
                products.where((p) => p.category == 'vegetables').toList(),
          ),
          CategoryData(
            name: 'Fruits',
            icon: Icons.apple,
            color: const Color(0xFFFF9800),
            products: products.where((p) => p.category == 'fruits').toList(),
          ),
          CategoryData(
            name: 'Grains',
            icon: Icons.grain,
            color: const Color(0xFF795548),
            products: products.where((p) => p.category == 'grains').toList(),
          ),
          CategoryData(
            name: 'Spices',
            icon: Icons.water_drop,
            color: const Color(0xFFE91E63),
            products: products.where((p) => p.category == 'spices').toList(),
          ),
          CategoryData(
            name: 'Flowers',
            icon: Icons.local_florist,
            color: const Color(0xFF9C27B0),
            products: products.where((p) => p.category == 'flowers').toList(),
          ),
        ];

        return Scaffold(
          backgroundColor: C.background,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: _ResponsiveBreakpoints.maxContentWidth),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF064e3b), Color(0xFF065f46)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'CATEGORIES',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _PremiumCategoryCard(
                          category: category,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/category_products',
                            arguments: category,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== CATEGORY DATA ====================

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final List<ProductModel> products;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.products,
  });
}

// ==================== CATEGORY CARD ====================

class _PremiumCategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;

  const _PremiumCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(category.icon, color: category.color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: category.color,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Browse Collections',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064e3b)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.products.length} products verified',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 24),
          ],
        ),
      ),
    );
  }
}

// ==================== CATEGORY PRODUCTS SCREEN ====================

class CategoryProductsScreen extends StatelessWidget {
  final CategoryData category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isInfinite
            ? _ResponsiveBreakpoints.maxContentWidth
            : constraints.maxWidth;
        final crossAxisCount =
            _ResponsiveBreakpoints.gridCrossAxisCount(availableWidth);

        return Scaffold(
          backgroundColor: C.background,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: _ResponsiveBreakpoints.maxContentWidth),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: category.color,
                    child: SafeArea(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Icon(category.icon, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(category.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  // Products Grid
                  Expanded(
                    child: category.products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No products in this category',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: category.products.length,
                            itemBuilder: (context, index) {
                              final product = category.products[index];
                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/product_detail',
                                    arguments: product),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: C.primaryContainer
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(16)),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              category.icon,
                                              size: 48,
                                              color: category.color
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 4),
                                            Text(
                                                '₹${product.price.toStringAsFixed(0)}/${product.unit}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF002b02))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
