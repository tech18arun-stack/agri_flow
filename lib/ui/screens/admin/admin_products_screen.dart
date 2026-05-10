import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../core/utils/image_url_utils.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllProducts();
      _revealController.forward();
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);
    final pad = adaptivePadding(context);
    final adminProv = context.watch<AdminProvider>();
    final products = adminProv.allProducts
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.farmerName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: pad,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(products.length, web),
            const SizedBox(height: 24),
            _buildSearchPanel(web),
            const SizedBox(height: 24),
            adminProv.loading && products.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: C.primary)))
                : _buildRegistryView(products, web),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count, bool web) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Audit',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Text(
              'Overseeing $count live listings across the platform',
              style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary, size: 20),
        onPressed: () => context.read<AdminProvider>().loadAllProducts(),
      ),
    );
  }

  Widget _buildSearchPanel(bool web) {
    return SizedBox(
      width: web ? 400 : double.infinity,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search audit records...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: C.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildRegistryView(List<ProductModel> products, bool web) {
    if (products.isEmpty) {
      return const EmptyStateWidget(icon: Icons.inventory_rounded, title: 'No active listings', subtitle: 'No products match the current audit criteria.');
    }

    return FadeTransition(
      opacity: _revealController,
      child: Container(
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: web ? _buildWebTable(products) : _buildMobileList(products),
      ),
    );
  }

  Widget _buildWebTable(List<ProductModel> products) {
    return DataTable(
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(C.surfaceContainerLow.withValues(alpha: 0.5)),
      dataRowMinHeight: 70,
      dataRowMaxHeight: 80,
      columns: const [
        DataColumn(label: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        DataColumn(label: Text('SUBMITTED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        DataColumn(label: Text('CLASSIFICATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        DataColumn(label: Text('UNIT RATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        DataColumn(label: Text('STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
      ],
      rows: products.map((p) => DataRow(cells: [
        DataCell(Row(
          children: [
            _buildThumbnail(p.imageUrl),
            const SizedBox(width: 16),
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        )),
        DataCell(Text(p.farmerName, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(_buildCategoryPill(p.category)),
        DataCell(Text('₹${p.price}', style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary))),
        DataCell(Text('${p.quantity} ${p.unit}', style: TextStyle(color: C.onSurfaceVariant.withValues(alpha: 0.7)))),
        DataCell(_buildActionButton(p)),
      ])).toList(),
    );
  }

  Widget _buildMobileList(List<ProductModel> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildThumbnail(p.imageUrl),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          subtitle: Text('by ${p.farmerName} • ₹${p.price}/${p.unit}', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
          trailing: _buildActionButton(p),
        );
      },
    );
  }

  Widget _buildThumbnail(String? url) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: C.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: ImageUrlUtils.normalizeImageUrl(url ?? ''),
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) => const Icon(Icons.eco_rounded, color: C.primary, size: 24),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 0.5)),
    );
  }

  Widget _buildActionButton(ProductModel p) {
    return Container(
      decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
      child: IconButton(
        icon: const Icon(Icons.edit_note_rounded, color: C.primary, size: 22),
        onPressed: () => _showEditDialog(context, p),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final quantityController = TextEditingController(text: product.quantity.toString());
    final imageUrlController = TextEditingController(text: ImageUrlUtils.getDisplayUrl(product.imageUrl ?? ''));

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: C.surfaceContainerLowest,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            title: const Text('Refine Listing', style: TextStyle(fontWeight: FontWeight.w900)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('listing identification'),
                  _buildDialogField(nameController, 'Product name'),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('unit rate (₹)'),
                            _buildDialogField(priceController, 'Price', type: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('availability'),
                            _buildDialogField(quantityController, 'Qty', type: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),

                  _buildFieldLabel('visual identity'),
                  _buildDialogField(imageUrlController, 'Image URL', onChanged: (_) => setDialogState((){})),

                  if (imageUrlController.text.trim().isNotEmpty)
                    _buildImagePreview(imageUrlController.text),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: C.onSurfaceVariant, fontWeight: FontWeight.w700))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: () async {
                  final success = await context.read<AdminProvider>().updateProduct(product.id, {
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? product.price,
                    'quantity': double.tryParse(quantityController.text) ?? product.quantity,
                    'imageUrl': ImageUrlUtils.normalizeImageUrl(imageUrlController.text.trim()),
                  });
                  if (context.mounted && success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audit record committed successfully'), behavior: SnackBarBehavior.floating));
                  }
                },
                child: const Text('Commit Refinement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1)));
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint, {TextInputType? type, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: C.surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: ImageUrlUtils.normalizeImageUrl(url.trim()),
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(color: C.surfaceContainerLow, child: const Center(child: Icon(Icons.broken_image_rounded, color: C.error))),
        ),
      ),
    );
  }
}
