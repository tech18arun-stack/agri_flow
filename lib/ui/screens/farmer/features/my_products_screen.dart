import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../widgets/glass_container.dart';

// ==================== MY PRODUCTS SCREEN ====================

class MyProductsScreen extends StatelessWidget {
  final VoidCallback onAddProduct;
  const MyProductsScreen({super.key, required this.onAddProduct});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final loading = context.watch<ProductProvider>().loading;
    final auth = context.watch<AuthProvider>();
    final farmerId = auth.user?.id ?? '';

    // Filter only current farmer's products
    final myProducts = products.where((p) => p.farmerId == farmerId).toList();

    return Container(
      color: C.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Products',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: C.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${myProducts.length} product${myProducts.length != 1 ? 's' : ''} listed',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: loading && myProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : myProducts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<ProductProvider>().loadAll(),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 2;
                            if (constraints.maxWidth > 800) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth > 500) {
                              crossAxisCount = 3;
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio:
                                    0.60, // lowered for more vertical space
                              ),
                              itemCount: myProducts.length,
                              itemBuilder: (context, index) {
                                final product = myProducts[index];
                                return _ProductCard(product: product);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: C.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 64, color: C.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add" to list your first harvest',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      scaleFactor: 0.95,
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: C.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Area
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: C.surfaceContainer,
                              child: const Center(
                                  child: Icon(Icons.image, color: Colors.grey)),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GlassContainer(
                      blur: 10,
                      opacity: 0.7,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 12, color: Colors.orangeAccent),
                          const SizedBox(width: 4),
                          Text(
                            product.organic ? 'Organic' : 'Standard',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: C.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: C.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${product.price.toStringAsFixed(0)} / ${product.unit}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: C.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: C.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 12, color: C.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: C.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InteractiveCard(
                            scaleFactor: 0.9,
                            onTap: () => _showEditDialog(context, product),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: C.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 20, color: C.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InteractiveCard(
                            scaleFactor: 0.9,
                            onTap: () => _showDeleteDialog(context, product),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  size: 20, color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: C.primaryContainer.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          _getCategoryIcon(product.category),
          size: 48,
          color: C.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductModel product) {
    final priceCtrl = TextEditingController(text: product.price.toString());
    final qtyCtrl = TextEditingController(text: product.quantity.toString());
    bool organic = product.organic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${product.name}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Price (₹)', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: 'Quantity (${product.unit})'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Organic'),
                  value: organic,
                  onChanged: (v) => setDialogState(() => organic = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await context.read<ProductProvider>().updateProduct(
                      productId: product.id,
                      price: double.tryParse(priceCtrl.text),
                      quantity: double.tryParse(qtyCtrl.text),
                      organic: organic,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Product updated'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary, foregroundColor: Colors.white),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProductProvider>().deleteProduct(product.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Product deleted'),
                      backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.water_drop;
      case 'flowers':
        return Icons.local_florist;
      default:
        return Icons.eco;
    }
  }
}
