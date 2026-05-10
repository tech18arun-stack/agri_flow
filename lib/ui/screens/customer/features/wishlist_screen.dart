import 'package:flutter/material.dart';
import '../../../../ui/widgets/premium_product_cards.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.all;

    // Filter products that are in wishlist
    final wishlistProducts = allProducts
        .where((product) => wishlist.isInWishlist(product.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          _SliverWishlistHeader(wishlist: wishlist),
          if (wishlistProducts.isEmpty)
            SliverFillRemaining(child: _WishlistEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.crossAxisExtent >= 1200) {
                    crossAxisCount = 6;
                  } else if (constraints.crossAxisExtent >= 900) {
                    crossAxisCount = 4;
                  } else if (constraints.crossAxisExtent >= 600) {
                    crossAxisCount = 3;
                  }

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PremiumProductCard(product: wishlistProducts[index]),
                      childCount: wishlistProducts.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverWishlistHeader extends StatelessWidget {
  final WishlistProvider wishlist;
  const _SliverWishlistHeader({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 76,
      leading: Center(
        child: InteractiveCard(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
          ),
        ),
      ),
      actions: [
        if (wishlist.itemCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: InteractiveCard(
                onTap: () => _showClearConfirm(context, wishlist),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('CLEAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 76, bottom: 16),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            Text('${wishlist.itemCount} PREMIUM ITEMS SAVED', style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF6B7280))),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
      ),
    );
  }

  void _showClearConfirm(BuildContext context, WishlistProvider wishlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Clear Wishlist?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will remove all premium items from your favorites list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              wishlist.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('CLEAR ALL', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded, size: 80, color: Color(0xFF14532D)),
          ),
          const SizedBox(height: 32),
          const Text('Wishlist is Empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 12),
          const Text('Save items you love to find them later.', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('EXPLORE MARKET', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
