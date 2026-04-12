import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProductTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final templates = adminProv.productTemplates
        .where((t) =>
            t.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.nameTa.contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: C.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context),
        backgroundColor: C.primary,
        icon: const Icon(Icons.add, color: C.onPrimary),
        label: const Text('Add Product',
            style: TextStyle(color: C.onPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildHeader(templates.length),
          Expanded(
            child: adminProv.loading && templates.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildGrid(templates),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border(
            bottom: BorderSide(color: C.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catalog Management',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface),
                ),
                Text(
                  'Managing $count product templates',
                  style:
                      const TextStyle(fontSize: 14, color: C.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: C.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ProductTemplateModel> templates) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        return InteractiveCard(
          onTap: () => _showEditDialog(context, template: t),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          child: CachedNetworkImage(
                            imageUrl: t.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: C.surfaceContainer),
                            errorWidget: (_, __, ___) => Container(
                              color: Color(int.parse(
                                      t.color.replaceAll('#', '0xFF')))
                                  .withValues(alpha: 0.2),
                              child: Center(
                                  child: Text(t.icon,
                                      style: const TextStyle(fontSize: 40))),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          borderRadius: BorderRadius.circular(12),
                          child: Text(
                            t.category.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: C.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.nameEn,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(t.icon, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      Text(
                        t.nameTa,
                        style: const TextStyle(
                            fontSize: 14, color: C.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unit: ${t.unit}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: C.onSurfaceVariant),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 20, color: C.primary),
                            onPressed: () =>
                                _showEditDialog(context, template: t),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, {ProductTemplateModel? template}) {
    final bool isEdit = template != null;
    final nameEnController = TextEditingController(text: template?.nameEn);
    final nameTaController = TextEditingController(text: template?.nameTa);
    final imageUrlController = TextEditingController(text: template?.imageUrl);
    final categoryController = TextEditingController(text: template?.category);
    final unitController = TextEditingController(text: template?.unit);
    final idController = TextEditingController(text: template?.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit)
                TextField(
                  controller: idController,
                  decoration:
                      const InputDecoration(labelText: 'Product ID (slug)'),
                ),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(labelText: 'Name (English)'),
              ),
              TextField(
                controller: nameTaController,
                decoration: const InputDecoration(labelText: 'Name (Tamil)'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                    labelText: 'Category (vegetables, fruits, etc.)'),
              ),
              TextField(
                controller: unitController,
                decoration:
                    const InputDecoration(labelText: 'Unit (kg, bunch, piece)'),
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
              final data = {
                'nameEn': nameEnController.text,
                'nameTa': nameTaController.text,
                'imageUrl': imageUrlController.text,
                'category': categoryController.text,
                'unit': unitController.text,
              };

              bool success;
              if (isEdit) {
                success = await context
                    .read<AdminProvider>()
                    .updateProductTemplate(template.id, data);
              } else {
                success = await context
                    .read<AdminProvider>()
                    .createProductTemplate(idController.text, data);
              }

              if (mounted && success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          isEdit ? 'Template updated!' : 'Template created!')),
                );
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Create'),
          ),
        ],
      ),
    );
  }
}
