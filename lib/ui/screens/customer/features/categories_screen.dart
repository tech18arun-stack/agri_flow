import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../ui/widgets/premium_product_cards.dart';

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

class CategoriesBrowsingScreen extends StatelessWidget {
  const CategoriesBrowsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;

    final categories = [
      _CategoryData(name: 'Vegetables', icon: Icons.grass_rounded, color: const Color(0xFF10B981), id: 'vegetables'),
      _CategoryData(name: 'Fruits', icon: Icons.apple_rounded, color: const Color(0xFFF59E0B), id: 'fruits'),
      _CategoryData(name: 'Grains', icon: Icons.grain_rounded, color: const Color(0xFFD97706), id: 'grains'),
      _CategoryData(name: 'Pulses', icon: Icons.circle_rounded, color: const Color(0xFF92400E), id: 'pulses'),
      _CategoryData(name: 'Greens', icon: Icons.yard_rounded, color: const Color(0xFF047857), id: 'greens'),
      _CategoryData(name: 'Spices', icon: Icons.water_drop_rounded, color: const Color(0xFFDC2626), id: 'spices'),
      _CategoryData(name: 'Flowers', icon: Icons.local_florist_rounded, color: const Color(0xFFDB2777), id: 'flowers'),
      _CategoryData(name: 'Tubers', icon: Icons.bakery_dining_rounded, color: const Color(0xFF78350F), id: 'tubers'),
      _CategoryData(name: 'Plantation', icon: Icons.coffee_rounded, color: const Color(0xFF451A03), id: 'plantation'),
      _CategoryData(name: 'Oilseeds', icon: Icons.circle_notifications_rounded, color: const Color(0xFFB45309), id: 'oilseeds'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _LuxuryCategoryHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  final catProducts = products.where((p) => p.category == cat.id).toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PremiumCategoryTile(
                      category: cat,
                      count: catProducts.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsScreen(
                            categoryName: cat.name,
                            categoryIcon: cat.icon,
                            categoryColor: cat.color,
                            products: catProducts,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryCategoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF14532D), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('EXPLORE CATEGORIES', 
          style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFFDCFCE7).withValues(alpha: 0.3), Colors.white],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumCategoryTile extends StatelessWidget {
  final _CategoryData category;
  final int count;
  final VoidCallback onTap;

  const _PremiumCategoryTile({required this.category, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: category.color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(category.icon, color: category.color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name.toUpperCase(), 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('$count Verified Listings', 
                    style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF14532D), size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final List<ProductModel> products;

  const CategoryProductsScreen({
    super.key, 
    required this.categoryName, 
    required this.categoryIcon, 
    required this.categoryColor,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _ResponsiveBreakpoints.gridCrossAxisCount(width);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _CategorySliverHeader(name: categoryName, icon: categoryIcon, color: categoryColor),
              
              if (products.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PremiumProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_rounded, size: 64, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),
          const Text('No Items Available', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text('We couldn\'t find any active listings here.', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CategorySliverHeader extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const _CategorySliverHeader({required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: color,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(name.toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: 0.2,
                child: Icon(icon, size: 120, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final String id;
  const _CategoryData({required this.name, required this.icon, required this.color, required this.id});
}
