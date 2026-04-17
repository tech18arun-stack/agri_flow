import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/category_utils.dart';
import 'features/my_products_screen.dart';
import 'features/market_prices_screen.dart';
import 'features/trending_products_screen.dart';
import 'features/best_sellers_screen.dart';
import 'features/price_comparison_screen.dart';
import 'features/farmer_orders_tab.dart';
import 'features/farmer_loi_tab.dart';
import 'features/farmer_add_product_tab.dart';
import 'features/farmer_profile_screen.dart';
import '../../../widgets/interactive_card.dart';
import '../../../widgets/floating_glass_nav_bar.dart';
import '../map/product_map_screen.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
      context
          .read<OrderProvider>()
          .loadFarmerOrders(context.read<AuthProvider>().user?.id ?? '');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: C.surfaceContainerLowest,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: C.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: C.onSurface)),
          ),
          body: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _FarmerDashboard(
        scrollController: _scrollController,
        onNavigate: _navigateTo,
      ),
      MyProductsScreen(onAddProduct: () {
        _navigateTo(const FarmerAddProductTab(), 'Add Product');
      }),
      const FarmerOrdersTab(),
      const FarmerLOITab(),
      const FarmerProfileScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: C.background,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _currentIndex == 4
            ? null
            : FloatingGlassNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: [
                  FloatingGlassNavItem(icon: Icons.dashboard_rounded, label: 'முகப்பு | Dash'),
                  FloatingGlassNavItem(icon: Icons.inventory_2_rounded, label: 'இருப்பு | Stock'),
                  FloatingGlassNavItem(icon: Icons.shopping_bag_rounded, label: 'ஆர்டர் | Orders'),
                  FloatingGlassNavItem(icon: Icons.description_rounded, label: 'ஒப்பந்தம் | LOI'),
                  FloatingGlassNavItem(icon: Icons.person_rounded, label: 'சுயவிவரம் | Profile'),
                ],
              ),
        extendBody: true,
        floatingActionButton: _currentIndex == 0
            ? LayoutBuilder(builder: (context, constraints) {
                final isSmall = MediaQuery.of(context).size.width < 400;
                return isSmall 
                  ? FloatingActionButton(
                      onPressed: () => _navigateTo(const FarmerAddProductTab(), 'Add Product'),
                      backgroundColor: C.primary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.add),
                    )
                  : FloatingActionButton.extended(
                      onPressed: () => _navigateTo(const FarmerAddProductTab(), 'Add Product'),
                      backgroundColor: C.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add),
                      label: const Text('சேர் | Add Product', style: TextStyle(fontWeight: FontWeight.w700)),
                      elevation: 4,
                    );
              })
            : null,
      ),
    );
  }
}

class _FarmerDashboard extends StatelessWidget {
  final ScrollController scrollController;
  final Function(Widget, String) onNavigate;

  const _FarmerDashboard({
    required this.scrollController,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'Farmer';
    final district = auth.user?.district ?? 'Tamil Nadu';
    final products = context.watch<ProductProvider>().all;
    final farmerId = auth.user?.id ?? '';
    final farmerProducts =
        products.where((p) => p.farmerId == farmerId).toList();
    final orders = context.watch<OrderProvider>().orders;
    final farmerOrders = orders.where((o) => o.farmerId == farmerId).toList();

    final totalRevenue = farmerOrders
        .where((o) =>
            o.status.toLowerCase() == 'delivered' ||
            o.status.toLowerCase() == 'completed')
        .fold<double>(0, (sum, o) => sum + o.total);
    final pendingOrders =
        farmerOrders.where((o) => o.status == 'pending').length;

    return RefreshIndicator(
      onRefresh: () async {
        final prodProv = context.read<ProductProvider>();
        final orderProv = context.read<OrderProvider>();
        await prodProv.loadAll();
        await orderProv.loadFarmerOrders(farmerId);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Hero Header
              SliverToBoxAdapter(
                  child: _buildHeader(context, userName, district, auth)),
    
              // Quick Stats
              SliverToBoxAdapter(
                  child: _buildStatsCards(
                      context, totalRevenue, farmerProducts.length, pendingOrders)),
    
              // Quick Actions Grid
              SliverToBoxAdapter(child: _buildQuickActions(context)),
    
              // My Products Preview
              SliverToBoxAdapter(
                  child: _buildSection(
                      'எனது தயாரிப்புகள் | My Products', _buildProductsPreview(context, farmerProducts),
                      () {
                onNavigate(
                  MyProductsScreen(onAddProduct: () {
                    Navigator.pop(context);
                    onNavigate(const FarmerAddProductTab(), 'Add Product');
                  }),
                  'My Products',
                );
              })),
    
              // Market Prices Preview
              SliverToBoxAdapter(
                  child: _buildSection(
                      'சந்தை விலை | Market Prices', _buildMarketPricesPreview(context), () {
                onNavigate(const MarketPricesScreen(), 'Market Prices');
              })),
    
              // Trending
              SliverToBoxAdapter(
                  child:
                      _buildSection('முன்னணி | Trending', _buildTrendingPreview(context), () {
                onNavigate(const TrendingProductsScreen(), 'Trending Products');
              })),
    
              // Orders Preview
              SliverToBoxAdapter(
                  child: _buildSection(
                      'சமீபத்திய ஆர்டர்கள் | Recent Orders', _buildOrdersPreview(context, farmerOrders),
                      () {
                onNavigate(const FarmerOrdersTab(), 'Orders');
              })),
    
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String district,
      AuthProvider auth) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 24, 16, 32),
      decoration: const BoxDecoration(
        color: C.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('தகவல் பலகை | Dashboard',
                        style: TextStyle(
                            color: C.onSurfaceVariant,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('வணக்கம், $userName 👋',
                          style: const TextStyle(
                              color: C.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5)),
                    ),
                  ],
                ),
              ),
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.map_rounded,
                        color: Color(0xFF0d631b), size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InteractiveCard(
                scaleFactor: 0.9,
                onTap: () {
                  onNavigate(const FarmerProfileScreen(), 'Profile');
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0d631b), Color(0xFF16A34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: C.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: C.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: C.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  district,
                  style: const TextStyle(
                      color: C.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
      BuildContext context, double revenue, int products, int orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;
        
        final revenueCard = InteractiveCard(
          scaleFactor: 0.96,
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF0d631b), Color(0xFF16A34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0d631b).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 28),
                ),
                SizedBox(height: isNarrow ? 16 : 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('மொத்த வருவாய் | Total Revenue',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('₹${revenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final statsColumn = Column(
          children: [
            Expanded(
              flex: isNarrow ? 0 : 1,
              child: InteractiveCard(
                scaleFactor: 0.92,
                onTap: () => onNavigate(
                    MyProductsScreen(onAddProduct: () {}), 'Products'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFFDE68A), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2,
                          color: Color(0xFFD97706), size: 24),
                      const SizedBox(height: 12),
                      Text('$products',
                          style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const Text('தயாரிப்புகள் | Products',
                          style: TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: isNarrow ? 0 : 1,
              child: InteractiveCard(
                scaleFactor: 0.92,
                onTap: () =>
                    onNavigate(const FarmerOrdersTab(), 'Orders'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping,
                          color: Color(0xFF2563EB), size: 24),
                      const SizedBox(height: 12),
                      Text('$orders',
                          style: const TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const Text('ஆர்டர்கள் | Orders',
                          style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               revenueCard,
               const SizedBox(height: 12),
               SizedBox(height: 320, child: statsColumn),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: revenueCard),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: statsColumn),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle,
        'label': 'சேர் | Add',
        'color': const Color(0xFF0d631b)
      },
      {
        'icon': Icons.inventory_2,
        'label': 'இருப்பு | Stock',
        'color': const Color(0xFF8b5cf6)
      },
      {
        'icon': Icons.price_check,
        'label': 'விலைகள் | Prices',
        'color': const Color(0xFF06b6d4)
      },
      {
        'icon': Icons.trending_up,
        'label': 'முன்னணி | Hot',
        'color': const Color(0xFFf59e0b)
      },
      {
        'icon': Icons.compare_arrows,
        'label': 'ஒப்பிடு | Compare',
        'color': const Color(0xFFec4899)
      },
      {
        'icon': Icons.shopping_bag,
        'label': 'ஆர்டர் | Orders',
        'color': const Color(0xFF10b981)
      },
      {
        'icon': Icons.description,
        'label': 'ஒப்பந்தம் | LOI',
        'color': const Color(0xFF6366f1)
      },
      {
        'icon': Icons.bar_chart,
        'label': 'புள்ளிவிவரம் | Stats',
        'color': const Color(0xFFef4444)
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth > 800) {
          crossAxisCount = 8;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 6;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: actions.map((action) {
            return SizedBox(
              width: (constraints.maxWidth - (12 * (crossAxisCount - 1)) - 32) / crossAxisCount,
              child: GestureDetector(
                onTap: () => _handleAction(context, action['label'] as String),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Icon(action['icon'] as IconData,
                          color: action['color'] as Color, size: 22),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        action['label'] as String,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1b1d0e)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  void _handleAction(BuildContext context, String label) {
    switch (label) {
      case 'சேர் | Add':
      case 'Add Product':
        onNavigate(const FarmerAddProductTab(), 'Add Product');
        break;
      case 'இருப்பு | Stock':
      case 'My Stock':
        onNavigate(
          MyProductsScreen(onAddProduct: () {
            Navigator.pop(context);
            onNavigate(const FarmerAddProductTab(), 'Add Product');
          }),
          'My Stock',
        );
        break;
      case 'விலைகள் | Prices':
      case 'Prices':
        onNavigate(const MarketPricesScreen(), 'Market Prices');
        break;
      case 'முன்னணி | Hot':
      case 'Trending':
        onNavigate(const TrendingProductsScreen(), 'Trending Products');
        break;
      case 'ஒப்பிடு | Compare':
      case 'Compare':
        onNavigate(const PriceComparisonScreen(), 'Price Comparison');
        break;
      case 'ஆர்டர் | Orders':
      case 'Orders':
        onNavigate(const FarmerOrdersTab(), 'Orders');
        break;
      case 'ஒப்பந்தம் | LOI':
      case 'LOI':
        onNavigate(const FarmerLOITab(), 'LOI Requests');
        break;
      case 'புள்ளிவிவரம் | Stats':
      case 'Analytics':
        onNavigate(const BestSellersScreen(), 'Analytics');
        break;
    }
  }

  Widget _buildSection(String title, Widget child, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1b1d0e))),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('அனைத்தும் | View All',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0d631b))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildProductsPreview(BuildContext context, List products) {
    if (products.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_outlined, size: 32, color: Colors.grey),
              SizedBox(height: 8),
              Text('No products yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length > 5 ? 5 : products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = products[i];
          return GestureDetector(
            onTap: () => onNavigate(
              MyProductsScreen(onAddProduct: () {
                Navigator.pop(context);
                onNavigate(const FarmerAddProductTab(), 'Add Product');
              }),
              'My Products',
            ),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: C.softShadow),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: p.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFFc8f17a)
                                    .withValues(alpha: 0.2),
                                child: const Center(
                                    child: Icon(Icons.image,
                                        color: Colors.grey, size: 24)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: const Color(0xFFc8f17a)
                                    .withValues(alpha: 0.2),
                                child: Center(
                                  child: Icon(_getCategoryIcon(p.category),
                                      color: const Color(0xFF0d631b), size: 28),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFc8f17a)
                                  .withValues(alpha: 0.2),
                              child: Center(
                                child: Icon(_getCategoryIcon(p.category),
                                    color: const Color(0xFF0d631b), size: 28),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('₹${p.price}/${p.unit}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0d631b))),
                      ],
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

  Widget _buildMarketPricesPreview(BuildContext context) {
    return GestureDetector(
      onTap: () => onNavigate(const MarketPricesScreen(), 'Market Prices'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: C.softShadow),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF06b6d4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.price_check,
                    color: Color(0xFF06b6d4), size: 24)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('நேரலை சந்தை விலை | Live Prices',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 2),
                  const Text('உங்கள் மாவட்டத்தின் விலைகளைக் கண்காணிக்கவும்',
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                ])),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingPreview(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          onNavigate(const TrendingProductsScreen(), 'Trending Products'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: C.softShadow),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFf59e0b).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.trending_up,
                    color: Color(0xFFf59e0b), size: 24)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('முன்னணி தயாரிப்புகள் | Trending',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 2),
                  const Text('எது நன்றாக விற்பனை ஆகிறது என்று பாருங்கள்',
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                ])),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersPreview(BuildContext context, List orders) {
    if (orders.isEmpty) {
      return GestureDetector(
        onTap: () => onNavigate(const FarmerOrdersTab(), 'Orders'),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Center(
              child: Text('இன்னும் ஆர்டர்கள் எதுவும் இல்லை | No orders yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey))),
        ),
      );
    }
    return GestureDetector(
      onTap: () => onNavigate(const FarmerOrdersTab(), 'Orders'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: C.softShadow),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF10b981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shopping_bag,
                    color: Color(0xFF10b981), size: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${orders.length} ஆர்டர்கள் | Orders',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 2),
                  const Text('அனைத்து ஆர்டர்களையும் பார்க்க தட்டவும்',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) => categoryIcon(category);
}

// Old _StatCard removed
