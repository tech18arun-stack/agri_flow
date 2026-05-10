import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../widgets/interactive_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final List<String> _recentSearches = [];
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _selectedCategory = 'all';
  String _selectedLocation = 'all';
  String _sortBy = 'popularity';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('recent_searches');
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        setState(() {
          _recentSearches.clear();
          _recentSearches.addAll(decoded.cast<String>());
        });
      } catch (_) {}
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) _recentSearches.removeLast();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', jsonEncode(_recentSearches));
  }

  Future<void> _clearRecentSearches() async {
    setState(() => _recentSearches.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    _saveRecentSearch(query);

    final productProv = context.read<ProductProvider>();
    final allProducts = productProv.all;

    final filtered = allProducts.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.category.toLowerCase().contains(query.toLowerCase()) ||
          p.location.toLowerCase().contains(query.toLowerCase()) ||
          p.farmerName.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || p.category == _selectedCategory;
      final matchesLocation = _selectedLocation == 'all' || p.location == _selectedLocation;
      return matchesQuery && matchesCategory && matchesLocation;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() {
      _searchResults = filtered;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = context.watch<ProductProvider>().all;
    final categories = allProducts.map((p) => p.category).toSet().toList()..sort();
    final locations = allProducts.map((p) => p.location).toSet().toList()..sort();
    final hasQuery = _searchCtrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _SearchHeader(
            controller: _searchCtrl,
            onChanged: _performSearch,
            onBack: () => Navigator.pop(context),
          ),
          if (hasQuery)
            _SearchFilterStrip(
              selectedCategory: _selectedCategory,
              selectedLocation: _selectedLocation,
              sortBy: _sortBy,
              onCategoryTap: () => _showCategoryPicker(context, categories),
              onLocationTap: () => _showLocationPicker(context, locations),
              onSortTap: () => _showSortPicker(context),
            ),
          Expanded(
            child: hasQuery
                ? _buildSearchResults()
                : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF14532D)));
    }

    if (_searchResults.isEmpty) {
      return const _SearchNoResults();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 120,
          ),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) => _ProductSearchCard(product: _searchResults[index]),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT DISCOVERIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1)),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('CLEAR ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((query) => _RecentSearchTile(
                query: query,
                onTap: () {
                  _searchCtrl.text = query;
                  _performSearch(query);
                },
              )),
          const SizedBox(height: 32),
        ],
        const Text('POPULAR CATEGORIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CategorySearchChip(icon: Icons.grass_rounded, label: 'Vegetables', color: const Color(0xFF14532D), onTap: () => _updateCategory('Vegetables')),
            _CategorySearchChip(icon: Icons.apple_rounded, label: 'Fruits', color: const Color(0xFFD97706), onTap: () => _updateCategory('Fruits')),
            _CategorySearchChip(icon: Icons.grain_rounded, label: 'Grains', color: const Color(0xFF92400E), onTap: () => _updateCategory('Grains')),
            _CategorySearchChip(icon: Icons.local_florist_rounded, label: 'Flowers', color: const Color(0xFFDB2777), onTap: () => _updateCategory('Flowers')),
            _CategorySearchChip(icon: Icons.eco_rounded, label: 'Organic', color: const Color(0xFF059669), onTap: () => _updateCategory('Organic')),
          ],
        ),
      ],
    );
  }

  void _updateCategory(String cat) {
    setState(() {
      _selectedCategory = cat.toLowerCase();
      _performSearch(_searchCtrl.text);
    });
  }

  void _showCategoryPicker(BuildContext context, List<String> categories) {
    _showPicker(context, 'Market Categories', [
      _PickerItem(label: 'All Categories', value: 'all', icon: Icons.apps_rounded),
      ...categories.map((c) => _PickerItem(label: c[0].toUpperCase() + c.substring(1), value: c, icon: CategoryUtils.getIcon(c))),
    ], _selectedCategory, (val) {
      setState(() => _selectedCategory = val);
      _performSearch(_searchCtrl.text);
    });
  }

  void _showLocationPicker(BuildContext context, List<String> locations) {
    _showPicker(context, 'Farming Locations', [
      _PickerItem(label: 'All Regions', value: 'all', icon: Icons.public_rounded),
      ...locations.map((l) => _PickerItem(label: l, value: l, icon: Icons.location_on_rounded)),
    ], _selectedLocation, (val) {
      setState(() => _selectedLocation = val);
      _performSearch(_searchCtrl.text);
    });
  }

  void _showSortPicker(BuildContext context) {
    _showPicker(context, 'Refine Order', [
      _PickerItem(label: 'Most Popular', value: 'popularity', icon: Icons.star_rounded),
      _PickerItem(label: 'Price: Low to High', value: 'price_low', icon: Icons.arrow_downward_rounded),
      _PickerItem(label: 'Price: High to Low', value: 'price_high', icon: Icons.arrow_upward_rounded),
      _PickerItem(label: 'Highest Rated', value: 'rating', icon: Icons.thumb_up_rounded),
    ], _sortBy, (val) {
      setState(() => _sortBy = val);
      _performSearch(_searchCtrl.text);
    });
  }

  void _showPicker(BuildContext context, String title, List<_PickerItem> items, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            ),
            ...items.map((item) => ListTile(
                  leading: Icon(item.icon, color: current == item.value ? const Color(0xFF14532D) : const Color(0xFF9CA3AF)),
                  title: Text(item.label, style: TextStyle(fontWeight: current == item.value ? FontWeight.w800 : FontWeight.w600, color: current == item.value ? const Color(0xFF14532D) : const Color(0xFF4B5563))),
                  trailing: current == item.value ? const Icon(Icons.check_circle_rounded, color: Color(0xFF14532D)) : null,
                  onTap: () {
                    onSelect(item.value);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onBack;

  const _SearchHeader({required this.controller, required this.onChanged, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          InteractiveCard(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                decoration: InputDecoration(
                  hintText: 'Search FarmFlow...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF14532D), size: 20),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Color(0xFF9CA3AF), size: 20),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFilterStrip extends StatelessWidget {
  final String selectedCategory;
  final String selectedLocation;
  final String sortBy;
  final VoidCallback onCategoryTap;
  final VoidCallback onLocationTap;
  final VoidCallback onSortTap;

  const _SearchFilterStrip({
    required this.selectedCategory,
    required this.selectedLocation,
    required this.sortBy,
    required this.onCategoryTap,
    required this.onLocationTap,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _CompactFilterChip(label: selectedCategory == 'all' ? 'All Produce' : selectedCategory, onTap: onCategoryTap),
          const SizedBox(width: 10),
          _CompactFilterChip(label: selectedLocation == 'all' ? 'All Regions' : selectedLocation, onTap: onLocationTap),
          const SizedBox(width: 10),
          _CompactFilterChip(label: 'Sort: $sortBy', onTap: onSortTap, isPrimary: true),
        ],
      ),
    );
  }
}

class _CompactFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  const _CompactFilterChip({required this.label, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF14532D) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isPrimary ? Colors.transparent : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isPrimary ? Colors.white : const Color(0xFF4B5563), letterSpacing: 0.5)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: isPrimary ? Colors.white : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  const _RecentSearchTile({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history_rounded, color: Color(0xFF9CA3AF), size: 20),
      title: Text(query, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
      trailing: const Icon(Icons.north_west_rounded, size: 16, color: Color(0xFFD1D5DB)),
      onTap: onTap,
    );
  }
}

class _CategorySearchChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CategorySearchChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  final ProductModel product;
  const _ProductSearchCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover)
                    : Icon(CategoryUtils.getIcon(product.category), size: 28, color: const Color(0xFFD1D5DB)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  Text('FROM ${product.farmerName.toUpperCase()}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF14532D), letterSpacing: 0.5)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${product.price.toStringAsFixed(0)}/${product.unit}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      if (product.organic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6)),
                          child: const Text('ORGANIC', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF166534))),
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
  }
}

class _SearchNoResults extends StatelessWidget {
  const _SearchNoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Color(0xFFF9FAFB), shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 24),
          const Text('No Premium Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or search terms.', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _PickerItem {
  final String label;
  final String value;
  final IconData icon;
  _PickerItem({required this.label, required this.value, required this.icon});
}
