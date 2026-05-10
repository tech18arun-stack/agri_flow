import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../core/utils/category_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models.dart';

import '../../../../ui/widgets/premium_product_cards.dart';

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
      color: const Color(0xFFF6F7F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, myProducts.length),
          
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.65,
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

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Inventory',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'எனது பொருட்கள் · $count listed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF14532D).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: onAddProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14532D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 64, color: const Color(0xFF14532D).withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Inventory is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14532D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'List your products to start selling.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
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
    return TapScaleAnimation(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0F0E8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: _buildImage(context),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.organic ? Icons.eco_rounded : Icons.inventory_2_rounded,
                            size: 10,
                            color: const Color(0xFF2D6A35),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.organic ? 'Organic' : 'Standard',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D6A35),
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF0F0E8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.analytics_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Stock: ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TapScaleAnimation(
                            onTap: () => _showEditDialog(context, product),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF2D6A35)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TapScaleAnimation(
                            onTap: () => _showDeleteDialog(context, product),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_rounded, size: 18, color: Color(0xFFE11D48)),
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

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return Container(
        color: const Color(0xFFF9F9F4),
        child: Center(
          child: Icon(
            CategoryUtils.getIcon(product.category),
            size: 40,
            color: const Color(0xFF2D6A35).withValues(alpha: 0.1),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: const Color(0xFFF5F5F5)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFF9F9F4),
        child: Center(
          child: Icon(CategoryUtils.getIcon(product.category), size: 40, color: const Color(0xFF2D6A35).withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductModel product) {
    final priceCtrl = TextEditingController(text: product.price.toString());
    final qtyCtrl = TextEditingController(text: product.quantity.toString());
    final imageUrlCtrl = TextEditingController(
        text: ImageUrlUtils.getDisplayUrl(product.imageUrl ?? ''));
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
                TextField(
                  controller: imageUrlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Image URL (Optional)',
                    hintText: ImageUrlUtils.getPlaceholderText(),
                    helperText: ImageUrlUtils.getHelpText(),
                    suffixIcon: imageUrlCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              imageUrlCtrl.clear();
                              setDialogState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                // Image preview
                if (imageUrlCtrl.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: C.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: ImageUrlUtils.normalizeImageUrl(
                              imageUrlCtrl.text.trim()),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.red.shade50,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                // Normalize the image URL
                final normalizedImageUrl = imageUrlCtrl.text.trim().isEmpty
                    ? null
                    : ImageUrlUtils.normalizeImageUrl(imageUrlCtrl.text.trim());

                await context.read<ProductProvider>().updateProduct(
                      productId: product.id,
                      price: double.tryParse(priceCtrl.text),
                      quantity: double.tryParse(qtyCtrl.text),
                      organic: organic,
                      imageUrl: normalizedImageUrl,
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
}
