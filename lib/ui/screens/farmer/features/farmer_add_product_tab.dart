import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../services/product_template_service.dart';
import '../../../../data/models.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../widgets/glass_container.dart';

// ==================== MAIN WIDGET ====================

class FarmerAddProductTab extends StatefulWidget {
  const FarmerAddProductTab({super.key});

  @override
  State<FarmerAddProductTab> createState() => _FarmerAddProductTabState();
}

class _FarmerAddProductTabState extends State<FarmerAddProductTab> {
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  ProductTemplateModel? _selectedProduct;
  List<ProductTemplateModel> _allTemplates = [];
  List<ProductTemplateModel> _filteredTemplates = [];
  bool _loadingTemplates = true;
  bool _submitting = false;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isOrganic = false;

  // Category labels with icons
  final Map<String, String> _categoryIcons = {
    'all': '🌾',
    'vegetables': '🥬',
    'fruits': '🍎',
    'grains': '🌾',
    'spices': '🌿',
    'flowers': '🌸',
    'processed': '🧴',
  };

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => _loadingTemplates = true);
    final templates = await ProductTemplateService.instance.getAllTemplates();
    if (mounted) {
      setState(() {
        _allTemplates = templates;
        _filteredTemplates = templates;
        _loadingTemplates = false;
      });
    }
  }

  void _filterProducts() {
    var products = _allTemplates;

    if (_selectedCategory != 'all') {
      products = products
          .where((p) =>
              p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.nameEn.toLowerCase().contains(query) ||
              p.nameTa.toLowerCase().contains(query))
          .toList();
    }

    setState(() => _filteredTemplates = products);
  }

  void _selectProduct(ProductTemplateModel product) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedProduct = product;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  bool get _isFormValid {
    return _selectedProduct != null &&
        _priceCtrl.text.isNotEmpty &&
        _quantityCtrl.text.isNotEmpty &&
        double.tryParse(_priceCtrl.text) != null &&
        double.tryParse(_quantityCtrl.text) != null;
  }

  Future<void> _submitProduct() async {
    if (!_isFormValid) return;

    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final user = auth.user;

    final success = await context.read<ProductProvider>().addProduct(
          name: _selectedProduct!.nameEn,
          nameTa: _selectedProduct!.nameTa,
          category: _selectedProduct!.category,
          price: double.parse(_priceCtrl.text),
          quantity: double.parse(_quantityCtrl.text),
          unit: _selectedProduct!.unit,
          organic: _isOrganic,
          location: user?.district ?? '',
          farmerId: user?.id ?? '',
          farmerName: user?.name ?? '',
          imageUrl: _selectedProduct!.imageUrl ?? '',
          harvestedDate: DateTime.now().toIso8601String(),
        );

    if (mounted) {
      setState(() => _submitting = false);
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_selectedProduct!.nameEn} added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add product. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedProduct = null;
      _priceCtrl.clear();
      _quantityCtrl.clear();
      _isOrganic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.background,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Selected Product Card
          if (_selectedProduct != null) _buildSelectedCard(),

          // Main Content
          Expanded(
            child: _selectedProduct == null
                ? _buildProductSelector()
                : _buildSimpleForm(),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0d631b), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _selectedProduct != null
                    ? '✅ Crop Selected'
                    : '🌾 Select Your Crop',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              if (_selectedProduct != null)
                InteractiveCard(
                  scaleFactor: 0.9,
                  onTap: _resetForm,
                  child: GlassContainer(
                    blur: 10,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _selectedProduct != null
                ? '${_selectedProduct!.nameEn} • ${_selectedProduct!.nameTa}'
                : 'Tap to choose your product from our catalog',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SELECTED PRODUCT CARD ====================

  Widget _buildSelectedCard() {
    final product = _selectedProduct!;
    final Color color = _parseColor(product.color);
    final String imageUrl = product.imageUrl ?? '';
    final String icon = product.icon.isNotEmpty ? product.icon : '🌾';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Center(
                          child:
                              Text(icon, style: const TextStyle(fontSize: 32))),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child:
                            Text(icon, style: const TextStyle(fontSize: 32))),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameEn,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: C.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  product.nameTa,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Per ${product.unit}',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    try {
      if (hexColor != null && hexColor.isNotEmpty) {
        return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
      }
    } catch (e) {
      // ignore
    }
    return C.primary;
  }

  // ==================== PRODUCT SELECTOR ====================

  Widget _buildProductSelector() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) {
              setState(() => _searchQuery = v);
              _filterProducts();
            },
            decoration: InputDecoration(
              hintText: '🔍 Search crop...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: C.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Category Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categoryIcons.entries.map((entry) {
                final isSelected = entry.key == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                        '${entry.value} ${entry.key[0].toUpperCase()}${entry.key.substring(1)}'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = entry.key);
                      _filterProducts();
                    },
                    selectedColor: C.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Product Grid
        Expanded(
          child: _loadingTemplates
              ? const Center(child: CircularProgressIndicator())
              : _filteredTemplates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🌾', style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text('No crops found',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Try a different search or category',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: _filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final product = _filteredTemplates[index];
                        return _ProductCard(
                          product: product,
                          onTap: () => _selectProduct(product),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ==================== SIMPLE FORM ====================

  Widget _buildSimpleForm() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // Price Input
        _buildInputCard(
          title: '💰 Price',
          subtitle: 'Per ${_selectedProduct!.unit}',
          child: TextField(
            controller: _priceCtrl,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter price',
              prefixText: '₹ ',
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, color: C.primary),
          ),
        ),

        const SizedBox(height: 16),

        // Quantity Input
        _buildInputCard(
          title: '📦 Quantity',
          subtitle: 'Available stock',
          child: TextField(
            controller: _quantityCtrl,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter quantity',
              suffixText: _selectedProduct!.unit,
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, color: C.onSurface),
          ),
        ),

        const SizedBox(height: 16),

        // Organic Toggle
        InteractiveCard(
          scaleFactor: 0.96,
          onTap: () => setState(() => _isOrganic = !_isOrganic),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _isOrganic
                  ? const LinearGradient(
                      colors: [Color(0xFFd9f99d), Color(0xFFbef264)])
                  : LinearGradient(colors: [
                      C.surfaceContainerLowest,
                      C.surfaceContainerLowest
                    ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isOrganic
                    ? const Color(0xFFa3e635)
                    : C.outlineVariant.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: _isOrganic
                  ? [
                      BoxShadow(
                          color: const Color(0xFF84cc16).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isOrganic ? Colors.white : C.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_isOrganic ? '🌿' : '🌾',
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Organic Certified',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(
                        _isOrganic
                            ? '✅ Certified organic produce'
                            : 'Not certified organic',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOrganic
                              ? Colors.green.shade900
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isOrganic
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color:
                      _isOrganic ? Colors.green.shade800 : Colors.grey.shade400,
                  size: 32,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Submit Button
        InteractiveCard(
          scaleFactor: 0.95,
          onTap: _isFormValid && !_submitting
              ? () {
                  _submitProduct();
                }
              : () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: _isFormValid
                  ? const LinearGradient(
                      colors: [Color(0xFF0d631b), Color(0xFF16A34A)])
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade300]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isFormValid
                  ? [
                      BoxShadow(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ]
                  : [],
            ),
            child: _submitting
                ? const Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Product',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _isFormValid
                                ? Colors.white
                                : Colors.grey.shade500),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: _isFormValid
                              ? Colors.white
                              : Colors.grey.shade500),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInputCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================

class _ProductCard extends StatelessWidget {
  final ProductTemplateModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  Color get _color {
    try {
      if (product.color != null && product.color!.isNotEmpty) {
        return Color(int.parse(product.color!.replaceFirst('#', '0xFF')));
      }
    } catch (e) {
      // ignore
    }
    return C.primary;
  }

  String get _imageUrl => product.imageUrl ?? '';
  String get _icon => product.icon.isNotEmpty ? product.icon : '🌾';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: _imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: _color.withValues(alpha: 0.1),
                          child: Center(
                              child: Text(_icon,
                                  style: const TextStyle(fontSize: 40))),
                        ),
                      )
                    : Container(
                        color: _color.withValues(alpha: 0.1),
                        child: Center(
                            child: Text(_icon,
                                style: const TextStyle(fontSize: 40))),
                      ),
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  Text(
                    product.nameEn,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.nameTa,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
