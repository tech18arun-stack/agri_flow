import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../widgets/interactive_card.dart';
import '../../map/product_map_screen.dart';

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

// ==================== ALL PRODUCTS SCREEN ====================

class AllProductsScreen extends StatefulWidget {
  final String? initialCategory;
  const AllProductsScreen({super.key, this.initialCategory});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _sortBy = 'popularity';
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _organicOnly = false;

  @override
  void initState() {
    super.initState();
    // Apply initial category from deep-link
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
      if (_selectedCategory == 'fresh') {
        // 'fresh' is not a DB category — use it as an organic-style filter via sortBy newest
        _selectedCategory = 'all';
        _sortBy = 'newest';
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.all.isEmpty && !provider.loading) {
        provider.loadAll();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> allProducts) {
    var filtered = allProducts.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedCategory != 'all' && p.category != _selectedCategory) {
        return false;
      }
      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }
      if (_organicOnly && !p.organic) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        filtered.sort((a, b) {
          if (a.harvestedDate == null) return 1;
          if (b.harvestedDate == null) return -1;
          return b.harvestedDate!.compareTo(a.harvestedDate!);
        });
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return filtered;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != 'all') count++;
    if (_priceRange.start > 0 || _priceRange.end < 1000) count++;
    if (_organicOnly) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _priceRange = const RangeValues(0, 1000);
      _organicOnly = false;
      _sortBy = 'popularity';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  set sortBy(String value) {
    setState(() => _sortBy = value);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterPanel(
        selectedCategory: _selectedCategory,
        priceRange: _priceRange,
        organicOnly: _organicOnly,
        isSidebar: false,
        onApply: (category, range, organic) {
          setState(() {
            _selectedCategory = category;
            _priceRange = range;
            _organicOnly = organic;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final allProducts = provider.all;
    final filtered = _getFilteredProducts(allProducts);
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: C.background,
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? _buildErrorState(provider.error!)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth.isInfinite
                        ? _ResponsiveBreakpoints.maxContentWidth
                        : constraints.maxWidth;
                    final crossAxisCount =
                        _ResponsiveBreakpoints.gridCrossAxisCount(width);

                    Widget mainScrollView = CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Glassy Header
                        SliverToBoxAdapter(child: _buildGlassyHeader()),

                        // Premium Categories
                        SliverToBoxAdapter(child: _buildModernCategoryStrip()),

                        // Refined Sort & Metrics
                        SliverToBoxAdapter(child: _buildRefinedSortBar()),

                        // Stats Summary
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Text(
                                  '${filtered.length} CURATED RESULTS',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const Spacer(),
                                if (_getActiveFiltersCount() > 0)
                                  GestureDetector(
                                    onTap: _clearFilters,
                                    child: const Text(
                                      'RESET',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF065f46),
                                          letterSpacing: 1),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Products Grid
                        if (filtered.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _PremiumProductCard(
                                    product: filtered[index],
                                    isInWishlist: wishlist
                                        .isInWishlist(filtered[index].id),
                                    onWishlistToggle: () {
                                      HapticFeedback.selectionClick();
                                      wishlist
                                          .toggleWishlist(filtered[index].id);
                                    },
                                    onAddToCart: () {
                                      HapticFeedback.mediumImpact();
                                      context
                                          .read<CartProvider>()
                                          .addToCart(filtered[index]);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${filtered[index].name} added to cart'),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(24),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: filtered.length,
                              ),
                            ),
                          ),
                      ],
                    );

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: _ResponsiveBreakpoints.maxContentWidth),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<ProductProvider>().loadAll();
                          },
                          child: width >= 900
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 280,
                                      child: _FilterPanel(
                                        selectedCategory: _selectedCategory,
                                        priceRange: _priceRange,
                                        organicOnly: _organicOnly,
                                        isSidebar: true,
                                        onApply: (category, range, organic) {
                                          setState(() {
                                            _selectedCategory = category;
                                            _priceRange = range;
                                            _organicOnly = organic;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(child: mainScrollView),
                                  ],
                                )
                              : mainScrollView,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildGlassyHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF064e3b), Color(0xFF065f46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'MARKETPLACE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5),
                ),
              ),
              InteractiveCard(
                onTap: _openFilterSheet,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              InteractiveCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductMapScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.map_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InteractiveCard(
            scaleFactor: 0.98,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search fresh crops...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF064e3b), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryStrip() {
    final categories = const [
      _CategoryItem('all', 'ALL', Icons.apps_rounded),
      _CategoryItem('vegetables', 'VEG', Icons.grass_rounded),
      _CategoryItem('fruits', 'FRUIT', Icons.apple_rounded),
      _CategoryItem('grains', 'GRAIN', Icons.grain_rounded),
      _CategoryItem('spices', 'SPICE', Icons.water_drop_rounded),
      _CategoryItem('flowers', 'FLOWER', Icons.local_florist_rounded),
      _CategoryItem('others', 'OTHERS', Icons.inventory_2_rounded),
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat.id;
          return InteractiveCard(
            onTap: () => setState(() => _selectedCategory = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 85,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF064e3b) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon,
                      color:
                          isSelected ? Colors.white : const Color(0xFF064e3b),
                      size: 20),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color:
                            isSelected ? Colors.white : const Color(0xFF064e3b),
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefinedSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SortChip('SMART SORT', isSelected: _sortBy == 'popularity'),
                  _SortChip('PRICE ↓', isSelected: _sortBy == 'price_low'),
                  _SortChip('NEWEST', isSelected: _sortBy == 'newest'),
                  _SortChip('RATING', isSelected: _sortBy == 'rating'),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: C.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.search_off, size: 64, color: C.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No crops found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child:
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<ProductProvider>().loadAll(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  const _CategoryItem(this.id, this.label, this.icon);
}

// ==================== SORT CHIP ====================

class _SortChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  const _SortChip(this.label, {required this.isSelected});

  @override
  State<_SortChip> createState() => _SortChipState();
}

class _SortChipState extends State<_SortChip> {
  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_AllProductsScreenState>();
    if (parent == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          parent.sortBy = widget.label.contains('↑')
              ? 'price_low'
              : widget.label.contains('↓')
                  ? 'price_high'
                  : widget.label.toLowerCase();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? C.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PREMIUM PRODUCT CARD ====================

class _PremiumProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isInWishlist;
  final VoidCallback onWishlistToggle;
  final VoidCallback onAddToCart;

  const _PremiumProductCard({
    required this.product,
    required this.isInWishlist,
    required this.onWishlistToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          C.primaryContainer.withValues(alpha: 0.12),
                          C.primaryContainer.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Center(
                                child: Icon(
                                  _categoryIcon(product.category),
                                  size: 48,
                                  color: C.primary.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              _categoryIcon(product.category),
                              size: 48,
                              color: C.primary.withValues(alpha: 0.25),
                            ),
                          ),
                  ),
                  // Organic Badge
                  if (product.organic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFc8f17a),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 10, color: Color(0xFF002b02)),
                            SizedBox(width: 2),
                            Text(
                              'Organic',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF002b02),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlistToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isInWishlist
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isInWishlist ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (product.nameTa.isNotEmpty)
                        Text(
                          product.nameTa,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065f46),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: C.primary,
                          ),
                        ),
                      ),
                      Text(
                        '/${product.unit}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  IconData _categoryIcon(String category) {
    switch (category) {
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

// ==================== FILTER PANEL ====================

class _FilterPanel extends StatefulWidget {
  final String selectedCategory;
  final RangeValues priceRange;
  final bool organicOnly;
  final bool isSidebar;
  final Function(String category, RangeValues priceRange, bool organic) onApply;

  const _FilterPanel({
    required this.selectedCategory,
    required this.priceRange,
    required this.organicOnly,
    this.isSidebar = false,
    required this.onApply,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late String _category;
  late RangeValues _priceRange;
  late bool _organic;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _priceRange = widget.priceRange;
    _organic = widget.organicOnly;
  }

  @override
  void didUpdateWidget(covariant _FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebar) {
      if (oldWidget.selectedCategory != widget.selectedCategory) {
        _category = widget.selectedCategory;
      }
      if (oldWidget.priceRange != widget.priceRange) {
        _priceRange = widget.priceRange;
      }
      if (oldWidget.organicOnly != widget.organicOnly) {
        _organic = widget.organicOnly;
      }
    }
  }

  void _apply() {
    if (!widget.isSidebar) {
      Navigator.pop(context);
    }
    widget.onApply(_category, _priceRange, _organic);
  }

  void _triggerInstantApplyIfSidebar() {
    if (widget.isSidebar) {
      widget.onApply(_category, _priceRange, _organic);
    }
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isSidebar ? C.background : Colors.white,
        borderRadius: widget.isSidebar
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isSidebar) ...[
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, widget.isSidebar ? 32 : 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = 'all';
                      _priceRange = const RangeValues(0, 1000);
                      _organic = false;
                    });
                    _triggerInstantApplyIfSidebar();
                  },
                  child: const Text('Reset',
                      style: TextStyle(
                          color: C.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SheetFilterSection(
                  title: 'Category',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SheetChip('All', 'all'),
                      _SheetChip('🥬 Vegetables', 'vegetables'),
                      _SheetChip('🍎 Fruits', 'fruits'),
                      _SheetChip('🌾 Grains', 'grains'),
                      _SheetChip('🌶️ Spices', 'spices'),
                      _SheetChip('🌸 Flowers', 'flowers'),
                      _SheetChip('📦 Others', 'others'),
                    ].map((chip) {
                      return _SheetChipWidget(
                        label: chip.label,
                        value: chip.value,
                        isSelected: _category == chip.value,
                        onTap: () {
                          setState(() => _category = chip.value);
                          _triggerInstantApplyIfSidebar();
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _SheetFilterSection(
                  title: 'Price Range',
                  child: Column(
                    children: [
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        activeColor: C.primary,
                        inactiveColor: C.primary.withValues(alpha: 0.2),
                        labels: RangeLabels(
                          '₹${_priceRange.start.round()}',
                          '₹${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setState(() => _priceRange = values);
                        },
                        onChangeEnd: (values) {
                          _triggerInstantApplyIfSidebar();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${_priceRange.start.round()}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: C.onSurface)),
                          Text('₹${_priceRange.end.round()}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: C.onSurface)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Organic Only',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: C.onSurface),
                      ),
                    ),
                    Switch(
                      value: _organic,
                      onChanged: (v) {
                        setState(() => _organic = v);
                        _triggerInstantApplyIfSidebar();
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: C.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Apply Button (Only if not sidebar)
          if (!widget.isSidebar)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSidebar) {
      return _buildContent();
    }

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.75,
      builder: (_, controller) {
        return _buildContent();
      },
    );
  }
}

class _SheetChip {
  final String label;
  final String value;
  const _SheetChip(this.label, this.value);
}

class _SheetFilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetFilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _SheetChipWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  const _SheetChipWidget({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? C.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
