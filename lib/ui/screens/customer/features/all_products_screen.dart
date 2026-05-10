import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../ui/widgets/premium_product_cards.dart';
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
  RangeValues _priceRange = const RangeValues(0, 5000);
  bool _organicOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
      if (_selectedCategory == 'fresh') {
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

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _priceRange = const RangeValues(0, 5000);
      _organicOnly = false;
      _sortBy = 'popularity';
      _searchQuery = '';
      _searchController.clear();
    });
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
    final filtered = _getFilteredProducts(provider.all);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(color: C.primary))
          : provider.error != null
              ? _buildErrorState(provider.error!)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth.isInfinite ? 1200.0 : constraints.maxWidth;
                    final crossAxisCount = _ResponsiveBreakpoints.gridCrossAxisCount(width);

                    return RefreshIndicator(
                      color: C.primary,
                      onRefresh: () async => await context.read<ProductProvider>().loadAll(),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _LuxuryMarketHeader(
                            searchController: _searchController,
                            onSearchChanged: (v) => setState(() => _searchQuery = v),
                            onFilterTap: _openFilterSheet,
                            onMapTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductMapScreen())),
                          ),

                          SliverToBoxAdapter(
                            child: _PremiumCategoryStrip(
                              selectedId: _selectedCategory,
                              onSelect: (id) => setState(() => _selectedCategory = id),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: _RefinedSortBar(
                              activeSort: _sortBy,
                              onSortChange: (sort) => setState(() => _sortBy = sort),
                            ),
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Text(
                                    '${filtered.length} PREMIUM LISTINGS',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6B7280),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedCategory != 'all' || _searchQuery.isNotEmpty || _organicOnly)
                                    GestureDetector(
                                      onTap: _clearFilters,
                                      child: const Text(
                                        'CLEAR FILTERS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF14532D),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (filtered.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.65,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => PremiumProductCard(product: filtered[index]),
                                  childCount: filtered.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.search_off_rounded, size: 80, color: Color(0xFF14532D)),
          ),
          const SizedBox(height: 24),
          const Text('No Results Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or category filters.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('RESET MARKETPLACE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
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
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Connection Issue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.read<ProductProvider>().loadAll(),
              child: const Text('RETRY LOADING', style: TextStyle(fontWeight: FontWeight.w900, color: C.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== LUXURY COMPONENTS ====================

class _LuxuryMarketHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onMapTap;

  const _LuxuryMarketHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 180,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB).withValues(alpha: 0.95),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.white.withValues(alpha: 0.2), BlendMode.srcOver),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      InteractiveCard(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Premium Market', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
                          Text('EXPLORE LOCAL PRODUCE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const Spacer(),
                      _CircleAction(icon: Icons.map_rounded, onTap: onMapTap),
                      const SizedBox(width: 12),
                      _CircleAction(icon: Icons.tune_rounded, onTap: onFilterTap, highlight: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Search seeds, fruits, vegetables...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF14532D), size: 22),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _CircleAction({required this.icon, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF14532D) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: highlight ? Colors.transparent : const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 20, color: highlight ? Colors.white : const Color(0xFF14532D)),
      ),
    );
  }
}

class _PremiumCategoryStrip extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _PremiumCategoryStrip({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final categories = const [
      {'id': 'all', 'label': 'All Market', 'icon': '🛍️'},
      {'id': 'vegetables', 'label': 'Vegetables', 'icon': '🥬'},
      {'id': 'fruits', 'label': 'Fruits', 'icon': '🍎'},
      {'id': 'grains', 'label': 'Grains', 'icon': '🌾'},
      {'id': 'spices', 'label': 'Spices', 'icon': '🌶️'},
      {'id': 'flowers', 'label': 'Flowers', 'icon': '🌸'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedId == cat['id'];
          return InteractiveCard(
            onTap: () => onSelect(cat['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF14532D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Text(cat['icon'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RefinedSortBar extends StatelessWidget {
  final String activeSort;
  final ValueChanged<String> onSortChange;

  const _RefinedSortBar({required this.activeSort, required this.onSortChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SortItem(label: 'POPULAR', id: 'popularity', active: activeSort == 'popularity', onSelect: onSortChange),
          _SortItem(label: 'LOWEST', id: 'price_low', active: activeSort == 'price_low', onSelect: onSortChange),
          _SortItem(label: 'NEWEST', id: 'newest', active: activeSort == 'newest', onSelect: onSortChange),
          _SortItem(label: 'RATING', id: 'rating', active: activeSort == 'rating', onSelect: onSortChange),
        ],
      ),
    );
  }
}

class _SortItem extends StatelessWidget {
  final String label;
  final String id;
  final bool active;
  final ValueChanged<String> onSelect;

  const _SortItem({required this.label, required this.id, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onSelect(id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? const Color(0xFF14532D) : const Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPanel extends StatefulWidget {
  final String selectedCategory;
  final RangeValues priceRange;
  final bool organicOnly;
  final Function(String category, RangeValues priceRange, bool organic) onApply;

  const _FilterPanel({
    required this.selectedCategory,
    required this.priceRange,
    required this.organicOnly,
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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text('Market Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
          const SizedBox(height: 32),
          const Text('CATEGORIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterChip(label: 'All', id: 'all', selected: _category == 'all', onSelect: (v) => setState(() => _category = v)),
              _FilterChip(label: 'Vegetables', id: 'vegetables', selected: _category == 'vegetables', onSelect: (v) => setState(() => _category = v)),
              _FilterChip(label: 'Fruits', id: 'fruits', selected: _category == 'fruits', onSelect: (v) => setState(() => _category = v)),
              _FilterChip(label: 'Grains', id: 'grains', selected: _category == 'grains', onSelect: (v) => setState(() => _category = v)),
              _FilterChip(label: 'Spices', id: 'spices', selected: _category == 'spices', onSelect: (v) => setState(() => _category = v)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PRICE RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Color(0xFF6B7280))),
              Text('₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 50,
            activeColor: const Color(0xFF14532D),
            inactiveColor: const Color(0xFFF3F4F6),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Organic Only', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            subtitle: const Text('Only show certified organic produce', style: TextStyle(fontSize: 12)),
            value: _organic,
            activeColor: const Color(0xFF14532D),
            onChanged: (v) => setState(() => _organic = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              widget.onApply(_category, _priceRange, _organic);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String id;
  final bool selected;
  final ValueChanged<String> onSelect;

  const _FilterChip({required this.label, required this.id, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF14532D) : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF14532D) : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
