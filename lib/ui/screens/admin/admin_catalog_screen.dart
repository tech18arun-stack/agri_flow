import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../core/utils/image_url_utils.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProductTemplates();
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
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
      ),
      body: Column(
        children: [
          _buildHeader(templates.length, web),
          Expanded(
            child: adminProv.loading && templates.isEmpty
                ? const Center(child: CircularProgressIndicator(color: C.primary))
                : _buildGrid(templates, web),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count, bool web) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: C.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BiLabel(
                    en: 'Product Catalog',
                    ta: 'தயாரிப்பு அட்டவணை',
                    enSize: web ? 28 : 20,
                    enWeight: FontWeight.w900,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Managing $count canonical definitions',
                    style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              if (web)
                Row(
                  children: [
                    _buildSyncButton(),
                    const SizedBox(width: 16),
                    _buildSearchField(250),
                  ],
                ),
            ],
          ),
          if (!web) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSearchField(double.infinity)),
                const SizedBox(width: 12),
                _buildSyncButton(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    final adminProv = context.watch<AdminProvider>();
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: adminProv.loading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: C.primary))
          : const Icon(Icons.sync_rounded, color: C.primary, size: 20),
        tooltip: 'Sync with Master Catalog',
        onPressed: adminProv.loading ? null : () async {
          final results = await context.read<AdminProvider>().syncProductTemplates();
          if (mounted) {
            if (results.containsKey('error')) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync failed. Check connection.'), backgroundColor: Colors.red));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Catalog Synchronized: ${results['added']} added, ${results['updated']} updated.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: C.primary,
              ));
            }
          }
        },
      ),
    );
  }

  Widget _buildSearchField(double width) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search identifiers...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: C.surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildGrid(List<ProductTemplateModel> templates, bool web) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, size: 48, color: C.onSurfaceVariant.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('Zero products found', style: TextStyle(fontWeight: FontWeight.w700, color: C.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: web ? 0.9 : 0.85,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        return AnimatedBuilder(
          animation: _revealController,
          builder: (context, child) {
            final delay = (index % 10) * 0.05;
            final ani = CurvedAnimation(
              parent: _revealController,
              curve: Interval(delay.clamp(0, 1), (delay + 0.4).clamp(0, 1), curve: Curves.easeOutCubic),
            );
            return Transform.translate(
              offset: Offset(0, 40 * (1 - ani.value)),
              child: Opacity(opacity: ani.value, child: child),
            );
          },
          child: _ProductTemplateCard(
            template: t,
            onTap: () => _showEditDialog(context, template: t),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, {ProductTemplateModel? template}) {
    final bool isEdit = template != null;
    final nameEnController = TextEditingController(text: template?.nameEn);
    final nameTaController = TextEditingController(text: template?.nameTa);
    final imageUrlController = TextEditingController(
        text: ImageUrlUtils.getDisplayUrl(template?.imageUrl ?? ''));
    final categoryController = TextEditingController(text: template?.category);
    final unitController = TextEditingController(text: template?.unit);
    final idController = TextEditingController(text: template?.id);

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
            title: Text(isEdit ? 'Refine Definition' : 'Define New Product', style: const TextStyle(fontWeight: FontWeight.w900)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEdit) ...[
                    _buildFieldLabel('Product ID (Slug)'),
                    _buildDialogField(idController, 'e.g. carrot-red'),
                  ],
                  _buildFieldLabel('Name (English)'),
                  _buildDialogField(nameEnController, 'Name in English'),
                  _buildFieldLabel('Name (Tamil)'),
                  _buildDialogField(nameTaController, 'பெயர் தமிழில்'),
                  _buildFieldLabel('Visual Identity (Image URL)'),
                  _buildDialogField(imageUrlController, 'https://...', onChanged: (_) => setDialogState((){})),
                  
                  if (imageUrlController.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: ImageUrlUtils.normalizeImageUrl(imageUrlController.text.trim()),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: C.surfaceContainerLow, child: const Center(child: CircularProgressIndicator())),
                          errorWidget: (_, __, ___) => Container(color: Colors.red.withValues(alpha: 0.05), child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.red))),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Category'),
                            _buildDialogField(categoryController, 'e.g. vegetables'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Unit'),
                            _buildDialogField(unitController, 'e.g. kg'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: C.onSurfaceVariant)),
              ),
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: C.primary,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                 ),
                 onPressed: () async {
                   final normalizedImageUrl = ImageUrlUtils.normalizeImageUrl(imageUrlController.text.trim());
                   final data = {
                     'nameEn': nameEnController.text,
                     'nameTa': nameTaController.text,
                     'imageUrl': normalizedImageUrl,
                     'category': categoryController.text,
                     'unit': unitController.text,
                   };

                   bool success;
                   if (isEdit) {
                     success = await context.read<AdminProvider>().updateProductTemplate(template.id, data);
                   } else {
                     success = await context.read<AdminProvider>().createProductTemplate(idController.text, data);
                   }

                   if (!context.mounted) return;
                   if (success) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Definition updated' : 'Definition created'), behavior: SnackBarBehavior.floating));
                   }
                 },
                 child: Text(isEdit ? 'Commit Changes' : 'Initialize Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: C.onSurfaceVariant.withValues(alpha: 0.6), letterSpacing: 0.5)),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: C.surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _ProductTemplateCard extends StatelessWidget {
  final ProductTemplateModel template;
  final VoidCallback onTap;
  const _ProductTemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      child: CachedNetworkImage(
                        imageUrl: template.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: C.surfaceContainerLow),
                        errorWidget: (_, __, ___) => Container(
                          color: C.primary.withValues(alpha: 0.05),
                          child: Center(child: Text(template.icon, style: const TextStyle(fontSize: 48))),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        template.category.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: BiLabel(en: template.nameEn, ta: template.nameTa, enSize: 16, enWeight: FontWeight.w900)),
                        Text(template.icon, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                    const Spacer(),
                    const Divider(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Standard: ${template.unit}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
                        const Icon(Icons.navigate_next_rounded, color: C.primary, size: 20),
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
}
