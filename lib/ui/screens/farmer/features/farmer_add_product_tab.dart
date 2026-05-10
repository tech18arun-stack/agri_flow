import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../services/product_template_service.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../data/models.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../widgets/map_location_picker.dart';
import 'package:latlong2/latlong.dart';

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
  final _imageUrlCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  double? _lat;
  double? _lng;
  final bool _gettingLocation = false;

  ProductTemplateModel? _selectedProduct;
  List<ProductTemplateModel> _allTemplates = [];
  List<ProductTemplateModel> _filteredTemplates = [];
  bool _loadingTemplates = true;
  bool _submitting = false;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isOrganic = false;
  bool _useCustomImage = false;

  // Category labels with icons
  final Map<String, String> _categoryIcons = {
    'all': '🌾',
    'vegetables': '🥬',
    'fruits': '🍎',
    'grains': '🍚',
    'greens': '🍃',
    'spices': '🌿',
    'flowers': '🌸',
    'tubers': '🥔',
    'plantation': '☕',
    'oilseeds': '🥜',
    'pulses': '🫘',
    'industrial': '🏭',
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
    _imageUrlCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
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

  Future<void> _getLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          title: 'Pick Product Location',
          initialLocation: _lat != null && _lng != null ? LatLng(_lat!, _lng!) : null,
        ),
      ),
    );

    if (mounted && result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _locationCtrl.text = 'Pinned on Map';
        _addressCtrl.text = 'Lat: ${result.latitude.toStringAsFixed(4)}, Lng: ${result.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_isFormValid) return;

    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final user = auth.user;

    // Get image URL - use custom if provided, otherwise use template
    String imageUrl = _selectedProduct!.imageUrl;
    if (_useCustomImage && _imageUrlCtrl.text.trim().isNotEmpty) {
      imageUrl = ImageUrlUtils.normalizeImageUrl(_imageUrlCtrl.text.trim());
    }

    final success = await context.read<ProductProvider>().addProduct(
          name: _selectedProduct!.nameEn,
          nameTa: _selectedProduct!.nameTa,
          category: _selectedProduct!.category,
          price: double.parse(_priceCtrl.text),
          quantity: double.parse(_quantityCtrl.text),
          unit: _selectedProduct!.unit,
          organic: _isOrganic,
          location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : (user?.district ?? ''),
          address: _addressCtrl.text,
          farmerId: user?.id ?? '',
          farmerName: user?.name ?? '',
          farmerPhone: user?.phone ?? '',
          imageUrl: imageUrl,
          harvestedDate: DateTime.now().toIso8601String(),
          lat: _lat,
          lng: _lng,
        );

    if (mounted) {
      setState(() => _submitting = false);
      if (success != null) {
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
      _imageUrlCtrl.clear();
      _locationCtrl.clear();
      _addressCtrl.clear();
      _lat = null;
      _lng = null;
      _isOrganic = false;
      _useCustomImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7F2),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Selected Product Summary
          if (_selectedProduct != null) _buildSelectedSummary(),

          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _selectedProduct == null
                  ? _buildProductSelector()
                  : _buildConfigurationForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33064E3B),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProduct != null ? 'Configure Listing' : 'Market Catalog',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedProduct != null 
                          ? 'Set your market price and available stock' 
                          : 'Select a premium crop to list for sale',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedProduct != null)
                IconButton(
                  onPressed: _resetForm,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SELECTED SUMMARY ====================

  Widget _buildSelectedSummary() {
    final product = _selectedProduct!;
    final color = _parseColor(product.color);

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                product.icon.isNotEmpty ? product.icon : '🌾',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameEn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                Text(
                  product.nameTa,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'per ${product.unit}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                      ),
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
    return const Color(0xFF059669);
  }

  // ==================== PRODUCT SELECTOR ====================

  Widget _buildProductSelector() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _filterProducts();
              },
              decoration: InputDecoration(
                hintText: 'Search high-quality crops...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w600),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF059669)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),

        // Category Chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categoryIcons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = _categoryIcons.entries.elementAt(index);
              final isSelected = entry.key == _selectedCategory;
              return ChoiceChip(
                label: Text(
                  '${entry.value} ${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedCategory = entry.key);
                  _filterProducts();
                },
                selectedColor: const Color(0xFF059669),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF059669) : Colors.grey.shade100,
                  ),
                ),
                showCheckmark: false,
                elevation: isSelected ? 8 : 0,
                shadowColor: const Color(0xFF059669).withValues(alpha: 0.3),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Product Grid
        Expanded(
          child: _loadingTemplates
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
              : _filteredTemplates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌾', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text('No crops found',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF064E3B))),
                          const SizedBox(height: 4),
                          Text('Try a different search or category',
                              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
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

  // ==================== CONFIGURATION FORM ====================

  Widget _buildConfigurationForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('COMMERCIAL DETAILS'),
        _buildInputCard(
          title: 'MARKET PRICE',
          subtitle: 'Per ${_selectedProduct!.unit}',
          icon: Icons.payments_outlined,
          child: Row(
            children: [
              const Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildInputCard(
          title: 'AVAILABLE STOCK',
          subtitle: 'Total volume for sale',
          icon: Icons.inventory_2_outlined,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedProduct!.unit.toUpperCase(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        _buildSectionHeader('LOCATION & LOGISTICS'),

        _buildInputCard(
          title: 'PICKUP LOCATION',
          subtitle: 'Where the crop is stored',
          icon: Icons.location_on_outlined,
          child: Column(
            children: [
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g., Coimbatore Farm',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map_rounded, color: Color(0xFF059669)),
                    onPressed: _getLocation,
                  ),
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (_lat != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Coordinates Linked',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),
        _buildSectionHeader('PREMIUM FEATURES'),

        InteractiveCard(
          onTap: () => setState(() => _isOrganic = !_isOrganic),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isOrganic ? const Color(0xFFECFDF5) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isOrganic ? const Color(0xFF059669) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isOrganic ? const Color(0xFF059669) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: _isOrganic ? Colors.white : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Organic Certification',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
                      ),
                      Text(
                        'Chemical-free & natural farming',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isOrganic,
                  onChanged: (v) => setState(() => _isOrganic = v),
                  activeColor: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Submit Button
        InteractiveCard(
          onTap: _isFormValid && !_submitting ? _submitProduct : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: _isFormValid && !_submitting
                  ? const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF059669)])
                  : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isFormValid && !_submitting
                  ? [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'LIST PRODUCT IN MARKET',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade400,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ==================== WIDGETS ====================

class _ProductCard extends StatelessWidget {
  final ProductTemplateModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(product.color);

    return InteractiveCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    product.icon.isNotEmpty ? product.icon : '🌾',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    product.nameEn,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.nameTa,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return const Color(0xFF059669);
  }
}
