import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../data/models.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users.dart';
import 'screens/admin/admin_moderation.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_push_notifications_screen.dart';
import 'screens/admin/admin_catalog_screen.dart';
import 'screens/admin/admin_flower_prices_screen.dart';
import 'screens/admin/admin_price_updaters_screen.dart';

class AdminPortalScaffold extends StatefulWidget {
  const AdminPortalScaffold({super.key});
  @override
  State<AdminPortalScaffold> createState() => _AdminPortalScaffoldState();
}

class _AdminPortalScaffoldState extends State<AdminPortalScaffold> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<(IconData, String, String, Widget)> _navItems = [
    (
      Icons.dashboard_outlined,
      'Dashboard',
      'டேஷ்போர்டு',
      const AdminDashboard()
    ),
    (Icons.people_outline, 'Users', 'பயனர்கள்', const AdminUsersScreen()),
    (
      Icons.verified_outlined,
      'Moderation',
      'மிதமான',
      const AdminModerationScreen()
    ),
    (
      Icons.shopping_bag_outlined,
      'Orders',
      'ஆர்டர்கள்',
      const AdminOrdersScreen()
    ),
    (
      Icons.analytics_outlined,
      'Analytics',
      'பகுப்பாய்வு',
      const AdminAnalyticsScreen()
    ),
    (
      Icons.category_outlined,
      'Catalog',
      'பட்டியல்',
      const AdminCatalogScreen()
    ),
    (
      Icons.trending_up,
      'Trending',
      'ஃப்ரெண்டிங்',
      const _TrendingProductsScreen()
    ),
    (
      Icons.notifications_active_outlined,
      'Push',
      'புஷ்',
      const AdminPushNotificationScreen()
    ),
    (
      Icons.local_florist_outlined,
      'Flower Prices',
      'பூ விலைகள்',
      const AdminFlowerPricesScreen()
    ),
    (
      Icons.manage_accounts_outlined,
      'Price Updaters',
      'விலை குழு',
      const AdminPriceUpdatersScreen()
    ),
    (
      Icons.settings_outlined,
      'Settings',
      'அமைப்புகள்',
      const _SettingsPlaceholder()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: C.surface,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(auth),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(auth, isMobile),
              body: IndexedStack(
                index: _selectedIndex,
                children: _navItems.map((item) => item.$4).toList(),
              ),
              bottomNavigationBar: isMobile ? _buildBottomNav() : null,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider auth, bool isMobile) {
    return AppBar(
      backgroundColor: C.surface,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _navItems[_selectedIndex].$2,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 18, color: C.onSurface),
          ),
          Text(
            _navItems[_selectedIndex].$3,
            style: const TextStyle(fontSize: 10, color: C.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => _refreshCurrentTab()),
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: C.onSurfaceVariant),
            onPressed: () => _logout(auth),
          )
        else ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: C.primaryContainer,
            child: Text(
                auth.user?.name.isNotEmpty == true ? auth.user!.name[0] : 'A',
                style: const TextStyle(
                    color: C.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  void _refreshCurrentTab() {
    if (_selectedIndex == 0) context.read<AdminProvider>().loadStats();
    if (_selectedIndex == 1) context.read<AdminProvider>().loadUsers();
    if (_selectedIndex == 2)
      context.read<AdminProvider>().loadPendingProducts();
    if (_selectedIndex == 3) _refreshOrders();
    if (_selectedIndex == 4) _refreshAnalytics();
    if (_selectedIndex == 5)
      context.read<AdminProvider>().loadProductTemplates();
  }

  void _refreshOrders() {
    // Orders screen handles its own refresh
  }

  void _refreshAnalytics() {
    // Analytics screen handles its own refresh
  }

  void _logout(AuthProvider auth) async {
    await auth.logout();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildSidebar(AuthProvider auth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarCollapsed ? 80 : 260,
      color: C.surfaceContainerLow,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: C.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.eco, color: C.onPrimary, size: 24),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L.appName,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: C.onSurface,
                              letterSpacing: -0.5)),
                      Text('ADMIN PANEL',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: C.primary,
                              letterSpacing: 1.2)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSelected ? C.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(
                            horizontal: _isSidebarCollapsed ? 0 : 16),
                        child: Row(
                          mainAxisAlignment: _isSidebarCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            Icon(item.$1,
                                color: isSelected
                                    ? C.onPrimary
                                    : C.onSurfaceVariant,
                                size: 22),
                            if (!_isSidebarCollapsed) ...[
                              const SizedBox(width: 12),
                              Text(item.$2,
                                  style: TextStyle(
                                      color: isSelected
                                          ? C.onPrimary
                                          : C.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 14)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isSidebarCollapsed
                ? IconButton(
                    icon: const Icon(Icons.logout, color: C.error),
                    onPressed: () => _logout(auth))
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: C.outlineVariant.withValues(alpha: 0.5))),
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 16,
                            backgroundColor: C.secondaryContainer,
                            child: Text(
                                auth.user?.name.isNotEmpty == true
                                    ? auth.user!.name[0]
                                    : 'A',
                                style: const TextStyle(
                                    color: C.onSecondaryContainer,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(auth.user?.name ?? 'Admin',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: C.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const Text('Administrator',
                                  style: TextStyle(
                                      fontSize: 10, color: C.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.logout,
                                size: 18, color: C.onSurfaceVariant),
                            onPressed: () => _logout(auth)),
                      ],
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(
                _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: C.onSurfaceVariant),
            onPressed: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: C.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: C.primary,
        unselectedItemColor: C.onSurfaceVariant,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.$1),
                  activeIcon: Icon(item.$1, color: C.primary),
                  label: item.$2,
                ))
            .toList(),
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: C.outlineVariant),
          SizedBox(height: 16),
          Text('System Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Configuration options coming soon',
              style: TextStyle(color: C.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TrendingProductsScreen extends StatelessWidget {
  const _TrendingProductsScreen();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;

    // Sort by rating and reviews to find trending
    final trending = List<ProductModel>.from(products)
      ..sort((a, b) {
        final scoreA = a.rating * 10 + a.reviews;
        final scoreB = b.rating * 10 + b.reviews;
        return scoreB.compareTo(scoreA);
      });

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Trending Products',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (trending.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.trending_flat, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No trending data yet',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trending.length.clamp(0, 20),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = trending[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: index < 3
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey
                                    : Colors.brown,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.farmerName} • ${product.location}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${product.reviews} reviews',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: C.primary),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
