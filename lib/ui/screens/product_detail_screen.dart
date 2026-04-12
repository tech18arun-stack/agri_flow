import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/providers.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/agri_map.dart';
import '../../services/map_service.dart';
import '../../data/models.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();

    // Track this product view
    _trackProductView(p.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: C.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    wishlist.isInWishlist(p.id) ? Icons.favorite : Icons.favorite_border,
                    color: wishlist.isInWishlist(p.id) ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: () {
                  wishlist.toggleWishlist(p.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(wishlist.isInWishlist(p.id) ? 'Added to wishlist' : 'Removed from wishlist'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: C.primaryContainer.withValues(alpha: 0.1)),
                child: Center(
                  child: Icon(Icons.eco, size: 80, color: C.primary.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: Responsive.padH(context, 16).copyWith(top: 16, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.primary)),
                          if (p.nameTa.isNotEmpty)
                            Text(p.nameTa, style: TextStyle(fontSize: 14, color: C.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(12)),
                      child: Text('₹${p.price}/${p.unit}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                Wrap(
                  spacing: 8,
                  children: [
                    if (p.organic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: C.tertiaryFixed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.eco, size: 14, color: Color(0xFF1a2800)), SizedBox(width: 4), Text('Organic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: C.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 14), const SizedBox(width: 4), Text(p.location, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: C.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
                      child: Text('${p.category.toUpperCase()} • ${p.quantity} ${p.unit} available', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Farmer Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(child: Text(p.farmerName.isNotEmpty ? p.farmerName[0].toUpperCase() : 'F', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.primary))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.farmerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            Text('Verified Farmer • ${p.location}', style: TextStyle(fontSize: 11, color: C.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: C.primaryFixed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [const Icon(Icons.verified, size: 14, color: C.primary), const SizedBox(width: 4), Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: C.primary))]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.primary)),
                const SizedBox(height: 8),
                Text('Fresh ${p.name.toLowerCase()} harvested from verified farms in ${p.location}. Quality checked and ready for delivery.', style: TextStyle(fontSize: 13, color: C.onSurfaceVariant, height: 1.6)),
                const SizedBox(height: 20),

                // Price Comparison (if products available)
                Consumer<ProductProvider>(
                  builder: (context, productProv, _) {
                    final similar = productProv.all.where((x) => x.category == p.category && x.id != p.id).take(3).toList();
                    if (similar.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price Comparison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.primary)),
                        const SizedBox(height: 12),
                        ...similar.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              Text('₹${s.price}/${s.unit}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: s.price < p.price ? Colors.green : Colors.red)),
                              if (s.price < p.price) const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                            ],
                          ),
                        )),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // Map (if location available)
                if (p.lat != null && p.lng != null) ...[
                  const Text('Farm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.primary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AgriMap(
                        initialCenter: LatLng(p.lat!, p.lng!),
                        initialZoom: 14,
                        showCurrentLocation: false,
                        interactive: false,
                        markers: [
                          MapMarker(
                            id: p.id,
                            position: LatLng(p.lat!, p.lng!),
                            title: p.name,
                            subtitle: p.location,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ]),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: 24),
        decoration: BoxDecoration(color: C.surface, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(color: C.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add to Cart
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      cart.addToCart(p);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $_quantity ${p.name} to cart')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _trackProductView(String productId) async {
    // Will be implemented with RecentlyViewedProvider
    // This is a placeholder
  }
}
