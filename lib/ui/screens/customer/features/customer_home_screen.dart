import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../widgets/premium_product_cards.dart';
import 'all_products_screen.dart';
import '../../../../widgets/interactive_card.dart';
import 'flower_prices_public_screen.dart';

class _ResponsiveBreakpoints {
  static int gridCrossAxisCount(double width) {
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 5;
    return 6;
  }
}

// ==================== CUSTOMER HOME SCREEN ====================

class CustomerHomeScreen extends StatefulWidget {
  final Function(ProductModel)? onProductTap;
  const CustomerHomeScreen({super.key, this.onProductTap});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with AutomaticKeepAliveClientMixin {
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentBanner = 0;
  Timer? _bannerTimer;
  String _selectedLocation = 'Madurai';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startBannerAutoplay();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startBannerAutoplay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % 3;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onBannerChanged(int index) {
    setState(() => _currentBanner = index);
  }

  void _onProductTap(ProductModel product) {
    widget.onProductTap?.call(product);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final products = context.watch<ProductProvider>().all;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount =
        _ResponsiveBreakpoints.gridCrossAxisCount(screenWidth);

    // Filter products by categories
    final trendingProducts =
        products.where((p) => p.rating > 4.0).take(6).toList();
    final freshProducts = products
        .where((p) {
          if (p.harvestedDate == null) return false;
          final daysDiff = DateTime.now().difference(p.harvestedDate!).inDays;
          return daysDiff <= 3;
        })
        .take(6)
        .toList();
    final organicProducts = products.where((p) => p.organic).take(6).toList();

    return Stack(
      children: [
        Container(
          color: C.background,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern Glassmorphism Sliver Header
              _ModernSliverHeader(
                location: _selectedLocation,
                onLocationTap: _showLocationPicker,
              ),

              // Banner Carousel
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PageView(
                        controller: _bannerController,
                        onPageChanged: _onBannerChanged,
                        children: const [
                          _BannerCard(
                            title: "HARVEST DIRECT",
                            subtitle:
                                'Up to 50% discount on fresh morning harvests.',
                            gradient: [Color(0xFF065f46), Color(0xFF059669)],
                            icon: Icons.eco_rounded,
                            cta: 'GET OFFER',
                          ),
                          _BannerCard(
                            title: 'ORGANIC POWER',
                            subtitle:
                                '100% Pesticide free certified organic crops.',
                            gradient: [Color(0xFF4338ca), Color(0xFF6366f1)],
                            icon: Icons.spa_rounded,
                            cta: 'BROWSE',
                          ),
                          _BannerCard(
                            title: 'FLASH PRICES',
                            subtitle: 'Lowest market price guarantee today.',
                            gradient: [Color(0xFFb91c1c), Color(0xFFef4444)],
                            icon: Icons.bolt_rounded,
                            cta: 'VIEW NOW',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentBanner == i ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentBanner == i
                                ? const Color(0xFF065f46)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Flower Prices Banner
              SliverToBoxAdapter(
                child: _FlowerPricesBanner(
                  district: _selectedLocation,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FlowerPricesPublicScreen()),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Categories Horizontal Strip (Swiggy Style)
              const _CategoryStrip(),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Trending Products Section
              if (trendingProducts.isNotEmpty) ...[
                _SectionHeader(
                  title: '🔥 Trending Near You',
                  action: 'See All',
                  onActionTap: () => Navigator.pushNamed(context, '/trending'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: trendingProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return HorizontalProductCard(
                          product: trendingProducts[index],
                          onTap: _onProductTap,
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],

              // Fresh Near You Section
              if (freshProducts.isNotEmpty) ...[
                _SectionHeader(
                  title: '🌿 Fresh Near You',
                  subtitle: 'Harvested within 3 days',
                  action: 'See All',
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AllProductsScreen(initialCategory: 'fresh'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: freshProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return HorizontalProductCard(
                          product: freshProducts[index],
                          onTap: _onProductTap,
                          showFreshBadge: true,
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],

              // Organic Products Section
              if (organicProducts.isNotEmpty) ...[
                _SectionHeader(
                  title: '🌱 Organic Picks',
                  subtitle: '100% certified organic',
                  action: 'See All',
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AllProductsScreen(initialCategory: 'organic'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: organicProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return HorizontalProductCard(
                          product: organicProducts[index],
                          onTap: _onProductTap,
                          showOrganicBadge: true,
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],

              // Best Sellers Section
              _SectionHeader(
                title: '⭐ Best Sellers',
                action: 'See All',
                onActionTap: () => Navigator.pushNamed(context, '/products'),
              ),
              if (products.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No products yet',
                    subtitle: 'Fresh produce is on the way!\nCheck back soon.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= products.length) return null;
                        return PremiumProductCard(
                          product: products[index],
                          onTap: _onProductTap,
                        );
                      },
                      childCount: products.length.clamp(0, 12),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Delivery Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...['Madurai', 'Chennai', 'Coimbatore', 'Trichy', 'Salem']
                .map((loc) {
              return ListTile(
                leading: Icon(Icons.location_on,
                    color: _selectedLocation == loc ? C.primary : Colors.grey),
                title: Text(loc),
                trailing: _selectedLocation == loc
                    ? const Icon(Icons.check_circle, color: C.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLocation = loc);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

// removed _onSearch
}

// ==================== MODERN SLIVER HEADER ====================

class _ModernSliverHeader extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;

  const _ModernSliverHeader({
    required this.location,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 140.0,
      backgroundColor: C.primary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [C.primary, C.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: onLocationTap,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DELIVERING TO',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white54, size: 18),
              ],
            ),
          ),
          const Spacer(),
          // Actions
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Consumer<NotificationProvider>(
                      builder: (context, provider, _) {
                        return Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none,
                                  color: Colors.white, size: 20),
                            ),
                            if (provider.hasUnread)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 4)
                                    ],
                                  ),
                                  child: Text(
                                    provider.unreadCount > 9
                                        ? '9+'
                                        : '${provider.unreadCount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          auth.user?.name.isNotEmpty == true
                              ? auth.user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: InteractiveCard(
              scaleFactor: 0.98,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF065f46), size: 20),
                    const SizedBox(width: 14),
                    Text(
                      'Search farm products...',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.tune_rounded,
                        color: Color(0xFF065f46), size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== BANNER CARD ====================

class _BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String cta;

  const _BannerCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.cta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background blur shapes
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                icon,
                size: 150,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InteractiveCard(
                    scaleFactor: 0.94,
                    onTap: () {}, // Handled by outer or specific routing
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cta,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: gradient.first,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: gradient.first),
                        ],
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
}

// ==================== CATEGORY STRIP (SWIGGY STYLE) ====================

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.grass,
        'label': 'Vegetables',
        'color': const Color(0xFF4CAF50)
      },
      {
        'icon': Icons.apple,
        'label': 'Fruits',
        'color': const Color(0xFFFF5722)
      },
      {
        'icon': Icons.grain,
        'label': 'Grains',
        'color': const Color(0xFFFFC107)
      },
      {
        'icon': Icons.water_drop,
        'label': 'Spices',
        'color': const Color(0xFFE91E63)
      },
      {
        'icon': Icons.local_florist,
        'label': 'Flowers',
        'color': const Color(0xFF9C27B0)
      },
      {'icon': Icons.eco, 'label': 'Organic', 'color': const Color(0xFF009688)},
      {
        'icon': Icons.shopping_basket,
        'label': 'Staples',
        'color': const Color(0xFF795548)
      },
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _CategoryItem(
              icon: cat['icon'] as IconData,
              label: cat['label'] as String,
              color: cat['color'] as Color,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllProductsScreen(
                    initialCategory: (cat['label'] as String).toLowerCase(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      scaleFactor: 0.9,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(bottom: 12), // space for shadow
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border:
                    Border.all(color: color.withValues(alpha: 0.1), width: 1),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: Color(0xFF1b1d0e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SECTION HEADER ====================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String action;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.action = 'See All',
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: C.onSurface),
                  ),
                ),
                TextButton(
                  onPressed: onActionTap,
                  child: Text(
                    action,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: C.primary),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== FLOWER PRICES BANNER ====================

class _FlowerPricesBanner extends StatefulWidget {
  final String district;
  final VoidCallback onTap;

  const _FlowerPricesBanner({required this.district, required this.onTap});

  @override
  State<_FlowerPricesBanner> createState() => _FlowerPricesBannerState();
}

class _FlowerPricesBannerState extends State<_FlowerPricesBanner> {
  static const _kFlowerPink = Color(0xFFdb2777);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flowerPrices = context.read<FlowerPriceProvider>();
      flowerPrices.loadPrices(widget.district);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prices = context.watch<FlowerPriceProvider>();
    final published =
        prices.todayPrices.where((p) => p.isPublished).take(3).toList();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kFlowerPink, Color(0xFF7c3aed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kFlowerPink.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: icon and heading
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌸 Today\'s Flower Prices',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    widget.district,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  if (published.isNotEmpty)
                    ...published.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text('🌸',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(p.flowerName,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              '₹${p.priceMin.toStringAsFixed(0)}–₹${p.priceMax.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Text(
                      'Tap to see all district prices',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right: arrow
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
