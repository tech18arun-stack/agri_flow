import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';
import '../../../widgets/floating_glass_nav_bar.dart';
import '../../../widgets/premium_stat_card.dart';
import '../../../widgets/premium_section.dart';
import '../../../data/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/image_url_utils.dart';
import '../../widgets/premium_product_cards.dart';
import 'features/wholesale_buying_screen.dart';
import 'features/inventory_management_screen.dart';
import 'features/selling_screen.dart';
import 'features/profit_loss_screen.dart';

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F2),
        body: _buildPage(_currentIndex),
        bottomNavigationBar: FloatingGlassNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            FloatingGlassNavItem(icon: Icons.grid_view_rounded, label: 'Dash'),
            FloatingGlassNavItem(icon: Icons.shopping_bag_rounded, label: 'Buy'),
            FloatingGlassNavItem(icon: Icons.inventory_rounded, label: 'Stock'),
            FloatingGlassNavItem(
                icon: Icons.rocket_launch_rounded, label: 'Sell'),
            FloatingGlassNavItem(icon: Icons.analytics_rounded, label: 'P&L'),
          ],
        ),
        extendBody: true,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _MerchantDashboard(
            key: PageStorageKey('merchant_dashboard'));
      case 1:
        return const WholesaleBuyingScreen(
            key: PageStorageKey('wholesale_buying'));
      case 2:
        return const InventoryManagementScreen(
            key: PageStorageKey('inventory_management'));
      case 3:
        return const SellingScreen(key: PageStorageKey('selling'));
      case 4:
        return const ProfitLossTrackingScreen(
            key: PageStorageKey('profit_loss'));
      default:
        return const _MerchantDashboard();
    }
  }
}

// ==================== MERCHANT DASHBOARD ====================

class _MerchantDashboard extends StatefulWidget {
  const _MerchantDashboard({super.key});

  @override
  State<_MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<_MerchantDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HarvestProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProductProvider, LOIProvider, AuthProvider,
        HarvestProvider>(
      builder: (context, productProv, loiProv, auth, harvestProv, child) {
        var products = productProv.all;
        final lois = loiProv.merchantRequests;
        final harvests = harvestProv.all;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          products = products
              .where((p) =>
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.category
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  p.farmerName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
              .toList();
        }

        final totalProducts = products.length;
        final pendingLOIs = lois.where((l) => l.status == 'pending').length;
        final avgPrice = products.isNotEmpty
            ? products.fold(0.0, (sum, p) => sum + p.price) / products.length
            : 0.0;

        return RefreshIndicator(
          onRefresh: () async {
            await productProv.loadAll();
            await loiProv.fetchMerchantRequests(auth.user?.id ?? '');
            await harvestProv.loadAll();
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: CustomScrollView(
                slivers: [
                  // Hero Header
                  SliverToBoxAdapter(
                      child:
                          _buildHeader(context, auth.user?.name ?? 'Merchant')),

                  // Search Bar
                  SliverToBoxAdapter(child: _buildSearchBar(context)),

                  // Key Metrics (Bento Style)
                  SliverToBoxAdapter(
                      child: _buildMetricsGrid(
                          context, totalProducts, pendingLOIs, avgPrice)),

                  // Quick Actions Grid
                  SliverToBoxAdapter(child: _buildQuickActions(context)),

                  // Market Intelligence (Ticker)
                  SliverToBoxAdapter(child: _buildMarketTicker(context)),

                  // Live Harvest Previews (Opportunity for Merchants)
                  SliverToBoxAdapter(
                    child: PremiumSection(
                      title: 'அறுவடை வாய்ப்புகள் | Harvest Opportunities',
                      child: _buildHarvestOpportunities(context, harvests),
                    ),
                  ),

                  // Recent Listings
                  SliverToBoxAdapter(
                    child: PremiumSection(
                      title: '📦 மொத்த விற்பனை பட்டியல்கள் | Bulk Listings',
                      onViewAll: () => Navigator.pushNamed(context, '/wholesale'),
                      child: _buildProductsPreview(context, products),
                    ),
                  ),

                  SliverToBoxAdapter(
                      child: SizedBox(height: Responsive.sp(context, 120))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            Responsive.sp(context, 20),
            Responsive.sp(context, 12),
            Responsive.sp(context, 20),
            Responsive.sp(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.sp(context, 32),
                      height: Responsive.sp(context, 32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D6A35), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(Responsive.radius(context, 10)),
                      ),
                      child: Center(
                          child: Text('💼',
                              style:
                                  TextStyle(fontSize: Responsive.fs(context, 16)))),
                    ),
                    SizedBox(width: Responsive.sp(context, 10)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farm Flow',
                            style: TextStyle(
                                fontFamily: 'DM Serif Display',
                                fontSize: Responsive.fs(context, 16),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1A1A1A),
                                height: 1)),
                        Text('MERCHANT CORE',
                            style: TextStyle(
                                fontSize: Responsive.fs(context, 10),
                                color: const Color(0xFF8B8680),
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ],
                ),
                InteractiveCard(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    width: Responsive.sp(context, 36),
                    height: Responsive.sp(context, 36),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A35),
                      borderRadius:
                          BorderRadius.circular(Responsive.radius(context, 10)),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.fs(context, 15)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.sp(context, 24)),
            Text('வணக்கம் | Good morning',
                style: TextStyle(
                    color: const Color(0xFF8B8680),
                    fontSize: Responsive.fs(context, 13),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('$userName 👋',
                style: TextStyle(
                    fontFamily: 'DM Serif Display',
                    color: const Color(0xFF1A1A1A),
                    fontSize: Responsive.fs(context, 28),
                    fontWeight: FontWeight.w400,
                    height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: Responsive.padH(context, 20).copyWith(top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 14)),
          border: Border.all(color: const Color(0xFFE8E5DE), width: 1.5),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(
              fontSize: Responsive.fs(context, 14),
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search products, farmers or categories...',
            hintStyle: TextStyle(
                color: const Color(0xFF8B8680),
                fontSize: Responsive.fs(context, 13)),
            prefixIcon: Icon(Icons.search_rounded,
                color: const Color(0xFF2D6A35), size: Responsive.fs(context, 20)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, int totalProducts,
      int pendingLOIs, double avgPrice) {
    return Padding(
      padding: Responsive.padH(context, 20).copyWith(top: 8, bottom: 8),
      child: LayoutBuilder(builder: (context, constraints) {
        final crossAxisCount = Responsive.isPhone(context) ? 2 : 4;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: Responsive.sp(context, 12),
          crossAxisSpacing: Responsive.sp(context, 12),
          childAspectRatio: Responsive.isPhone(context) ? 1.4 : 1.6,
          children: [
            PremiumStatCard(
              icon: Icons.inventory_2_rounded,
              label: 'TOTAL SKU',
              value: '$totalProducts',
              trend: '+12%',
              color: C.primary,
            ),
            PremiumStatCard(
              icon: Icons.description_rounded,
              label: 'PENDING LOI',
              value: '$pendingLOIs',
              trend: 'URGENT',
              color: const Color(0xFF92400E),
            ),
            PremiumStatCard(
              icon: Icons.speed_rounded,
              label: 'SUCCESS RATE',
              value: '84%',
              trend: '+5.2%',
              color: const Color(0xFF166534),
            ),
            PremiumStatCard(
              icon: Icons.payments_rounded,
              label: 'AVG PRICE',
              value: '₹${avgPrice.toStringAsFixed(0)}',
              trend: 'STABLE',
              color: const Color(0xFF1E3A8A),
            ),
          ],
        );
      }),
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.shopping_cart_rounded,
        'label': 'Wholesale',
        'color': const Color(0xFF4338ca),
        'route': '/wholesale'
      },
      {
        'icon': Icons.sell_rounded,
        'label': 'Selling',
        'color': const Color(0xFF059669),
        'route': '/selling'
      },
      {
        'icon': Icons.analytics_rounded,
        'label': 'P&L',
        'color': const Color(0xFF7c3aed),
        'route': '/profit-loss'
      },
      {
        'icon': Icons.calculate_rounded,
        'label': 'Margin',
        'color': const Color(0xFFdb2777),
        'route': '/margin'
      },
      {
        'icon': Icons.inventory_rounded,
        'label': 'Stock',
        'color': const Color(0xFFd97706),
        'route': '/inventory'
      },
    ];

    return Padding(
      padding: Responsive.padH(context, 20).copyWith(top: 8, bottom: 8),
      child: LayoutBuilder(builder: (context, constraints) {
        final crossAxisCount = Responsive.isPhone(context) ? 3 : 5;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: Responsive.sp(context, 12),
            crossAxisSpacing: Responsive.sp(context, 12),
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, i) {
            final a = actions[i];
            return _QuickAction(
              icon: a['icon'] as IconData,
              label: a['label'] as String,
              color: a['color'] as Color,
              onTap: () => Navigator.pushNamed(context, a['route'] as String),
            );
          },
        );
      }),
    );
  }

  Widget _buildMarketTicker(BuildContext context) {
    return Consumer<PriceEngineProvider>(
      builder: (context, priceProv, _) {
        final market = priceProv.all;
        if (market.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: Responsive.padH(context, 20).copyWith(top: 12, bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🔴 நேரலை சந்தை | Live market',
                      style: TextStyle(
                          fontSize: Responsive.fs(context, 11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: const Color(0xFF8B8680))),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/wholesale'),
                    child: Text('View all →',
                        style: TextStyle(
                            fontSize: Responsive.fs(context, 11),
                            color: const Color(0xFF2D6A35),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: Responsive.sp(context, 10)),
              SizedBox(
                height: Responsive.sp(context, 54),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: market.length > 5 ? 5 : market.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: Responsive.sp(context, 8)),
                  itemBuilder: (context, i) {
                    final m = market[i];
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.sp(context, 14),
                          vertical: Responsive.sp(context, 8)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            Responsive.radius(context, 10)),
                        border: Border.all(
                            color: const Color(0xFFECE9E2), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(m.productName,
                                  style: TextStyle(
                                      fontSize: Responsive.fs(context, 12),
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  '₹${m.avgPrice.toStringAsFixed(0)}/${m.unit}',
                                  style: TextStyle(
                                      fontSize: Responsive.fs(context, 11),
                                      color: const Color(0xFF8B8680))),
                            ],
                          ),
                          SizedBox(width: Responsive.sp(context, 8)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '▲ 2%',
                              style: TextStyle(
                                  fontSize: Responsive.fs(context, 11),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHarvestOpportunities(
      BuildContext context, List<HarvestPreviewModel> harvests) {
    if (harvests.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECE9E2)),
        ),
        child: const Center(
          child: Text('No upcoming harvest opportunities',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      );
    }
    return Column(
      children: harvests.map((h) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE9E2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🌾', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.cropName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('अறுவடை: ${h.expectedDate.day} ${_getMonth(h.expectedDate)} · ${h.expectedYield.toInt()} ${h.unit}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await context.read<HarvestProvider>().addInterest(h.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Interest registered for ${h.cropName}'),
                          behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A35),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Interest',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  String _getMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
  // _buildSection removed

  Widget _buildProductsPreview(BuildContext context, List products) {
    if (products.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE9E2))),
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length > 5 ? 5 : products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        return _BulkProductCard(product: products[i]);
      },
    );
  }
}


// ==================== QUICK ACTION ====================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      scaleFactor: 0.9,
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BULK PRODUCT CARD ====================

class _BulkProductCard extends StatelessWidget {
  final ProductModel product;

  const _BulkProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: () => _showLOIDialog(context, product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0E8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image / Category Icon
              Stack(
                children: [
                  Container(
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9F9F4),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                      child: _buildImage(context),
                    ),
                  ),
                  if (product.organic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '🌿 ORGANIC',
                          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF2D6A35)),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (product.nameTa.isNotEmpty)
                                  Text(
                                    product.nameTa,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D6A35),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _StockBadge(quantity: product.quantity, unit: product.unit),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            product.location,
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          const Icon(Icons.person_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.farmerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'per ${product.unit}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4338CA),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4338CA).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Send LOI',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return Center(
        child: Icon(
          CategoryUtils.getIcon(product.category),
          size: 40,
          color: const Color(0xFF2D6A35).withValues(alpha: 0.1),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
      errorWidget: (context, url, error) => Center(
        child: Icon(
          CategoryUtils.getIcon(product.category),
          size: 40,
          color: const Color(0xFF2D6A35).withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final double quantity;
  final String unit;

  const _StockBadge({required this.quantity, required this.unit});

  @override
  Widget build(BuildContext context) {
    final bool isLow = quantity < 100; // Bulk threshold
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '${quantity.toStringAsFixed(0)} $unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isLow ? const Color(0xFFE65100) : const Color(0xFF1565C0),
            ),
          ),
          Text(
            'AVAILABLE',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: (isLow ? const Color(0xFFE65100) : const Color(0xFF1565C0)).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

void _showLOIDialog(BuildContext context, ProductModel product) {
    final priceCtrl = TextEditingController(text: product.price.toString());
    final qtyCtrl = TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4338ca).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_rounded,
                    color: Color(0xFF4338ca), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Intent for ${product.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1e1b4b),
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Offer (₹/${product.unit})',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity (${product.unit})',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InteractiveCard(
                      onTap: () async {
                        final auth = context.read<AuthProvider>();
                        final loip = context.read<LOIProvider>();
                        final success = await loip.sendLOI(LOIRequestModel(
                          id: '',
                          merchantId: auth.user!.id,
                          merchantName: auth.user!.name,
                          farmerId: product.farmerId,
                          farmerName: product.farmerName,
                          productId: product.id,
                          productName: product.name,
                          quantity: double.tryParse(qtyCtrl.text) ?? 0,
                          priceOffer: double.tryParse(priceCtrl.text) ?? 0,
                          status: 'pending',
                          createdAt: DateTime.now(),
                        ));
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('LOI sent successfully!')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338ca),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('SUBMIT',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

