import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/category_utils.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';
import '../../../widgets/floating_glass_nav_bar.dart';
import '../../../data/models.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, LOIProvider, AuthProvider>(
      builder: (context, productProv, loiProv, auth, child) {
        var products = productProv.all;
        final lois = loiProv.merchantRequests;

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

        // Calculate key metrics
        final totalProducts = products.length;
        final pendingLOIs = lois.where((l) => l.status == 'pending').length;
        final avgPrice = products.isNotEmpty
            ? products.fold(0.0, (sum, p) => sum + p.price) / products.length
            : 0.0;

        return Container(
          color: C.background,
          child: CustomScrollView(
            slivers: [
              // Smart Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 320,
                      decoration: const BoxDecoration(
                        color: C.background,
                      ),
                    ),
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [C.primary.withValues(alpha: 0.15), Colors.transparent],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AGRI-FLOW CORE',
                                      style: TextStyle(
                                          color: C.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      (auth.user?.name ?? 'ELITE MERCHANT')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: C.onSurface,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1),
                                    ),
                                  ],
                                ),
                              ),
                              InteractiveCard(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/profile'),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: C.primary.withValues(alpha: 0.2), width: 2)),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: C.primary,
                                    child: Text(
                                      auth.user?.name != null &&
                                              auth.user!.name.isNotEmpty
                                          ? auth.user!.name[0].toUpperCase()
                                          : 'M',
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
                          const SizedBox(height: 40),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: C.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: C.outlineVariant.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                                ]
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                style: const TextStyle(
                                    color: C.onSurface,
                                    fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Search operations and metrics...',
                                  hintStyle: TextStyle(
                                      color:
                                          C.onSurfaceVariant.withValues(alpha: 0.4),
                                      fontSize: 14),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      color: C.primary, size: 22),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 20),
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

              // Key Metrics Grid (Bento)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _MetricCard(
                      icon: Icons.inventory_2_rounded,
                      label: 'TOTAL SKU',
                      value: totalProducts.toString(),
                      color: C.primary,
                      trend: '+12%',
                    ),
                    _MetricCard(
                      icon: Icons.pending_actions_rounded,
                      label: 'PENDING LOI',
                      value: pendingLOIs.toString(),
                      color: const Color(0xFFf59e0b),
                      trend: 'Urgnet',
                    ),
                    _MetricCard(
                      icon: Icons.show_chart_rounded,
                      label: 'SUCCESS RATE',
                      value: '84%',
                      color: const Color(0xFF10b981),
                      trend: '+5.2%',
                    ),
                    _MetricCard(
                      icon: Icons.currency_rupee_rounded,
                      label: 'AVG PROCUREMENT',
                      value: '₹${avgPrice.toStringAsFixed(0)}',
                      color: C.tertiary,
                      trend: 'Stable',
                    ),
                  ],
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: C.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _QuickAction(
                        icon: Icons.add_shopping_cart,
                        label: 'New Order',
                        color: const Color(0xFF4CAF50),
                        onTap: () => Navigator.pushNamed(context, '/wholesale'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.sell,
                        label: 'Start Selling',
                        color: const Color(0xFF2196F3),
                        onTap: () => Navigator.pushNamed(context, '/selling'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.calculate,
                        label: 'Margin Calc',
                        color: const Color(0xFFFF9800),
                        onTap: () => Navigator.pushNamed(context, '/margin'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.bar_chart,
                        label: 'View P&L',
                        color: const Color(0xFF9C27B0),
                        onTap: () =>
                            Navigator.pushNamed(context, '/profit-loss'),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Recent Bulk Listings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📦 Recent Bulk Listings',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: C.onSurface),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/wholesale'),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: C.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Cards
              if (products.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No bulk listings yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Listings will appear when farmers add products',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= products.length) return null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BulkProductCard(product: products[index]),
                        );
                      },
                      childCount: products.length.clamp(0, 5),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

// ==================== METRIC CARD ====================

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String trend;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      scaleFactor: 0.98,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.05),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                    trend,
                    style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: C.onSurfaceVariant.withValues(alpha: 0.5),
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface,
                      letterSpacing: -1),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return InteractiveCard(
      scaleFactor: 0.98,
      onTap: () => _showLOIDialog(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 110,
                decoration: BoxDecoration(
                  color: C.surfaceContainer,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(24)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 40,
                    color: C.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: C.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (product.organic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFbef264)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFbef264)
                                        .withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'ORGANIC',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF065f46)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${product.location} • ${product.quantity} ${product.unit}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600),
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
                                  color: C.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'per ${product.unit}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          InteractiveCard(
                            scaleFactor: 0.9,
                            onTap: () => _showLOIDialog(context, product),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: C.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: C.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Text(
                                'Send LOI',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white),
                              ),
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

  IconData _getCategoryIcon(String category) => categoryIcon(category);

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
}
