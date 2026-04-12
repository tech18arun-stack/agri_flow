import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../core/utils/category_utils.dart';

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
        setState(() => _recentSearches.clear());
        setState(() => _recentSearches.addAll(decoded.cast<String>()));
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final searchState = context.findAncestorStateOfType<_SearchScreenState>();

    return Container(
      color: C.background,
      child: Column(
        children: [
          // Search Header
          Container(
            color: C.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: _performSearch,
                        decoration: InputDecoration(
                          hintText: 'Search products, farmers, locations...',
                          prefixIcon: const Icon(Icons.search, color: C.onSurfaceVariant),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _performSearch('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: C.surfaceContainerHigh,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters Row (only when searching)
          if (hasQuery)
            Container(
              color: C.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: _selectedCategory == 'all' ? 'All Categories' : _selectedCategory,
                      onPressed: () => _showCategoryPicker(context, categories),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedLocation == 'all' ? 'All Locations' : _selectedLocation,
                      onPressed: () => _showLocationPicker(context, locations),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Sort: $_sortBy',
                      onPressed: () => _showSortPicker(context),
                    ),
                  ],
                ),
              ),
            ),

          // Results or Recent Searches
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Try different keywords or filters', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _ProductSearchCard(product: product);
      },
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (_recentSearches.isNotEmpty)
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentSearches.isEmpty)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No recent searches', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          )
        else
          ..._recentSearches.map((query) => ListTile(
                leading: const Icon(Icons.history, color: C.onSurfaceVariant),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west, size: 18),
                  onPressed: () {
                    _searchCtrl.text = query;
                    _performSearch(query);
                  },
                ),
                onTap: () {
                  _searchCtrl.text = query;
                  _performSearch(query);
                },
              )),
        const SizedBox(height: 24),
        const Text('Popular Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _CategoryChip(icon: Icons.grass, label: 'Vegetables', color: const Color(0xFF4CAF50)),
            _CategoryChip(icon: Icons.apple, label: 'Fruits', color: const Color(0xFFFF9800)),
            _CategoryChip(icon: Icons.grain, label: 'Grains', color: const Color(0xFF795548)),
            _CategoryChip(icon: Icons.water_drop, label: 'Spices', color: const Color(0xFFE91E63)),
            _CategoryChip(icon: Icons.local_florist, label: 'Flowers', color: const Color(0xFF9C27B0)),
            _CategoryChip(icon: Icons.eco, label: 'Organic', color: const Color(0xFF009688)),
          ],
        ),
      ],
    );
  }

  void _showCategoryPicker(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('All Categories'),
              trailing: _selectedCategory == 'all' ? const Icon(Icons.check, color: C.primary) : null,
              onTap: () {
                setState(() => _selectedCategory = 'all');
                Navigator.pop(context);
                _performSearch(_searchCtrl.text);
              },
            ),
            ...categories.map((cat) => ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(cat[0].toUpperCase() + cat.substring(1)),
                  trailing: _selectedCategory == cat ? const Icon(Icons.check, color: C.primary) : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(context);
                    _performSearch(_searchCtrl.text);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, List<String> locations) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('All Locations'),
              trailing: _selectedLocation == 'all' ? const Icon(Icons.check, color: C.primary) : null,
              onTap: () {
                setState(() => _selectedLocation = 'all');
                Navigator.pop(context);
                _performSearch(_searchCtrl.text);
              },
            ),
            ...locations.map((loc) => ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(loc),
                  trailing: _selectedLocation == loc ? const Icon(Icons.check, color: C.primary) : null,
                  onTap: () {
                    setState(() => _selectedLocation = loc);
                    Navigator.pop(context);
                    _performSearch(_searchCtrl.text);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context) {
    final sorts = [
      ('popularity', 'Popularity'),
      ('price_low', 'Price: Low to High'),
      ('price_high', 'Price: High to Low'),
      ('rating', 'Highest Rated'),
      ('name', 'Name A-Z'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ...sorts.map((s) => ListTile(
                  title: Text(s.$2),
                  trailing: _sortBy == s.$1 ? const Icon(Icons.check, color: C.primary) : null,
                  onTap: () {
                    setState(() => _sortBy = s.$1);
                    Navigator.pop(context);
                    _performSearch(_searchCtrl.text);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _FilterChip({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final searchScreen = context.findAncestorStateOfType<_SearchScreenState>();
        if (searchScreen != null) {
          searchScreen.setState(() => searchScreen._selectedCategory = label.toLowerCase());
          searchScreen._performSearch(searchScreen._searchCtrl.text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
    final wishlist = context.watch<WishlistProvider>();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: C.softShadow,
        ),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: C.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(product.category),
                size: 32,
                color: C.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.farmerName} • ${product.location}',
                    style: const TextStyle(fontSize: 11, color: C.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}/${product.unit}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.primary),
                      ),
                      if (product.organic)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFc8f17a).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Organic', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF2b3f00))),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Wishlist button
            IconButton(
              onPressed: () => wishlist.toggleWishlist(product.id),
              icon: Icon(
                wishlist.isInWishlist(product.id) ? Icons.favorite : Icons.favorite_border,
                color: wishlist.isInWishlist(product.id) ? Colors.red : C.onSurfaceVariant,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) => categoryIcon(category);
}
