import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models.dart';
import '../../../../ui/widgets/premium_product_cards.dart';
import 'all_products_screen.dart';
import 'customer_profile_screen.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../widgets/map_location_picker.dart';
import '../../../../widgets/premium_section.dart';
import '../../../../core/constants/colors.dart';

class _ResponsiveBreakpoints {
  static int gridCrossAxisCount(double width) {
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 5;
    return 6;
  }
}

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
  String _selectedLocation = 'Madurai, TN';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startBannerAutoplay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startBannerAutoplay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % 2;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
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

  void _showLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapLocationPicker(),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final products = context.watch<ProductProvider>().all;
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _ResponsiveBreakpoints.gridCrossAxisCount(screenWidth);

    // Filter products
    final trendingProducts = products.where((p) => p.rating >= 4.5).take(6).toList();
    final freshProducts = products.where((p) {
      if (p.harvestedDate == null) return false;
      final daysDiff = DateTime.now().difference(p.harvestedDate!).inDays;
      return daysDiff <= 2;
    }).take(6).toList();

    return RefreshIndicator(
      color: C.primary,
      onRefresh: () async {
        await context.read<ProductProvider>().loadAll();
      },
      child: Container(
        color: const Color(0xFFF8F9F5), // Sophisticated light background
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Luxury Sliver Header
            _LuxurySliverHeader(
              location: _selectedLocation,
              onLocationTap: _showLocationPicker,
              onMapTap: () => Navigator.pushNamed(context, '/product_map'),
              onProfileTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CustomerProfileScreen())
              ),
            ),

            // Welcome & Guest Experience
            if (isGuest)
              SliverToBoxAdapter(
                child: _GuestWelcomeBanner(
                  onLogin: () => Navigator.pushNamed(context, '/login'),
                  onRolePreview: () => Navigator.pushNamed(context, '/role_preview'),
                ),
              ),

            // Premium Category Explorer
            SliverToBoxAdapter(
              child: _buildPremiumCategories(context),
            ),

            // App Live Status / Update
            const SliverToBoxAdapter(
              child: _AppStatusBanner(),
            ),

            // Featured Campaign Carousel
            SliverToBoxAdapter(
              child: _buildCampaignCarousel(),
            ),

            // Intelligence-driven Sections
            if (trendingProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: PremiumSection(
                  title: '🔥 Trending Near You',
                  onViewAll: () => Navigator.pushNamed(context, '/trending'),
                  child: SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: trendingProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return HorizontalProductCard(
                          product: trendingProducts[index],
                          onTap: _onProductTap,
                        );
                      },
                    ),
                  ),
                ),
              ),

            if (freshProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: PremiumSection(
                  title: '🌿 Harvested Today',
                  subtitle: 'Straight from the farm to you',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllProductsScreen(initialCategory: 'fresh'),
                    ),
                  ),
                  child: SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: freshProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
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
              ),

            // Main Catalog Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: PremiumSection(
                  title: '✨ Curated Marketplace',
                  onViewAll: () => Navigator.pushNamed(context, '/products'),
                  child: products.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.eco_outlined,
                          title: 'Connecting to Farms...',
                          subtitle: 'Fresh produce is being listed by local farmers.\nStay tuned!',
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            if (products.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return PremiumProductCard(
                        product: products[index],
                        onTap: _onProductTap,
                      );
                    },
                    childCount: products.length.clamp(0, 20),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCategories(BuildContext context) {
    final categories = [
      {'id': 'all', 'name': 'All', 'icon': '🛍️', 'color': const Color(0xFFF0FDF4)},
      {'id': 'vegetables', 'name': 'Vegetables', 'icon': '🥬', 'color': const Color(0xFFEFF6FF)},
      {'id': 'fruits', 'name': 'Fruits', 'icon': '🍎', 'color': const Color(0xFFFFF7ED)},
      {'id': 'flowers', 'name': 'Flowers', 'icon': '🌸', 'color': const Color(0xFFFDF2F8)},
      {'id': 'seeds', 'name': 'Seeds', 'icon': '🌱', 'color': const Color(0xFFF5F3FF)},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i];
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  InteractiveCard(
                    onTap: () {
                      if (cat['id'] == 'flowers') {
                        Navigator.pushNamed(context, '/flower_prices_public');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllProductsScreen(initialCategory: cat['id'] as String),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                      ),
                      child: Center(
                        child: Text(cat['icon'] as String, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cat['name'] as String,
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCampaignCarousel() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PageView(
              controller: _bannerController,
              onPageChanged: _onBannerChanged,
              physics: const BouncingScrollPhysics(),
              children: const [
                _CampaignBanner(
                  title: "Harvest Direct",
                  titleTa: 'அறுவடை நேரடி',
                  subtitle: 'Save up to 40% on morning harvests from Madurai farmers.',
                  gradient: [Color(0xFF14532D), Color(0xFF166534)],
                  icon: Icons.auto_awesome_rounded,
                  cta: 'SHOP HARVEST',
                ),
                _CampaignBanner(
                  title: 'Organic Pure',
                  titleTa: 'இயற்கை சக்தி',
                  subtitle: 'Certified chemical-free produce delivered within 24 hours.',
                  gradient: [Color(0xFF064E3B), Color(0xFF0F766E)],
                  icon: Icons.eco_rounded,
                  cta: 'GO ORGANIC',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBanner == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBanner == i
                      ? const Color(0xFF14532D)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ==================== LUXURY COMPONENTS ====================

class _LuxurySliverHeader extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;
  final VoidCallback onMapTap;
  final VoidCallback onProfileTap;

  const _LuxurySliverHeader({
    required this.location,
    required this.onLocationTap,
    required this.onMapTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 180,
      collapsedHeight: 80,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final isCollapsed = currentHeight <= (topPadding + 90);
          final opacity = ((currentHeight - 80) / (180 - 80)).clamp(0.0, 1.0);

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9F5).withValues(alpha: isCollapsed ? 1.0 : 0.95),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.white.withValues(alpha: 0.1), BlendMode.srcOver),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand & Profile Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Farm',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF14532D),
                                          letterSpacing: -1.2,
                                        ),
                                      ),
                                      Text(
                                        'Flow',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF14532D).withValues(alpha: 0.7),
                                          letterSpacing: -1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isCollapsed)
                                  Opacity(
                                    opacity: opacity,
                                    child: const Text(
                                      'DIRECT MARKETPLACE',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 8, 
                                        color: Color(0xFF6B7280), 
                                        fontWeight: FontWeight.w800, 
                                        letterSpacing: 1.0
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _HeaderAction(
                              icon: Icons.location_on_rounded,
                              label: location,
                              onTap: onLocationTap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onProfileTap,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF14532D).withValues(alpha: 0.1), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: isCollapsed ? 12 : 14,
                                backgroundColor: const Color(0xFFF0FDF4),
                                child: Icon(Icons.person_rounded, size: isCollapsed ? 14 : 16, color: const Color(0xFF14532D)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (!isCollapsed) ...[
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: opacity,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03), 
                                        blurRadius: 10, 
                                        offset: const Offset(0, 4)
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Search fresh...', 
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600)
                                        ),
                                      ),
                                      Icon(Icons.tune_rounded, size: 18, color: Color(0xFF14532D)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InteractiveCard(
                                onTap: onMapTap,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF14532D), Color(0xFF064E3B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(child: Icon(Icons.map_rounded, color: Colors.white, size: 20)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF14532D)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF374151))
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _AppStatusBanner extends StatelessWidget {
  const _AppStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Systems Optimized',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                Text(
                  'Running latest v2.4.0 with real-time tracking.',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        ],
      ),
    );
  }
}

class _GuestWelcomeBanner extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRolePreview;

  const _GuestWelcomeBanner({required this.onLogin, required this.onRolePreview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The Future of Farming',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock direct prices and support local farmers by creating your account today.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF064E3B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 0,
                ),
                child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onRolePreview,
                child: const Text('Tour App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampaignBanner extends StatelessWidget {
  final String title;
  final String titleTa;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String cta;

  const _CampaignBanner({
    required this.title,
    required this.titleTa,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.cta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 160, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Text(
                      titleTa, 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 220,
                  child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    cta, 
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


