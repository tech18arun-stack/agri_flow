import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../data/models.dart';
import '../widgets/shared_widgets.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users.dart';
import 'screens/admin/admin_moderation.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_push_notifications_screen.dart';
import 'screens/admin/admin_catalog_screen.dart';
import 'screens/admin/admin_flower_prices_screen.dart';
import 'screens/admin/admin_price_updaters_screen.dart';
import 'screens/admin/admin_products_screen.dart';

class AdminPortalScaffold extends StatefulWidget {
  const AdminPortalScaffold({super.key});
  @override
  State<AdminPortalScaffold> createState() => _AdminPortalScaffoldState();
}

class _AdminPortalScaffoldState extends State<AdminPortalScaffold> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  late AnimationController _revealController;

  final List<(IconData, String, String, Widget)> _navItems = [
    (Icons.grid_view_rounded, 'Dashboard', 'டேஷ்போர்டு', const AdminDashboard()),
    (Icons.group_rounded, 'Registry', 'பயனர்கள்', const AdminUsersScreen()),
    (Icons.shield_rounded, 'Moderation', 'மிதமான', const AdminModerationScreen()),
    (Icons.local_shipping_rounded, 'Logistics', 'ஆர்டர்கள்', const AdminOrdersScreen()),
    (Icons.inventory_2_rounded, 'Inventory', 'தயாரிப்புகள்', const AdminProductsScreen()),
    (Icons.analytics_rounded, 'Analytics', 'பகுப்பாய்வு', const AdminAnalyticsScreen()),
    (Icons.layers_rounded, 'Catalog', 'பட்டியல்', const AdminCatalogScreen()),
    (Icons.trending_up_rounded, 'Trending', 'ஃப்ரெண்டிங்', const _TrendingProductsScreen()),
    (Icons.podcasts_rounded, 'Broadcast', 'புஷ்', const AdminPushNotificationScreen()),
    (Icons.local_florist_rounded, 'Market Price', 'பூ விலைகள்', const AdminFlowerPricesScreen()),
    (Icons.manage_accounts_rounded, 'Personnel', 'விலை குழு', const AdminPriceUpdatersScreen()),
    (Icons.settings_rounded, 'Settings', 'அமைப்புகள்', const _SettingsPlaceholder()),
  ];

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: C.background,
      drawerEnableOpenDragGesture: isMobile,
      drawer: isMobile ? _buildSidebar(auth, isDrawer: true) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(auth),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(auth, isMobile),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: C.background,
                      borderRadius: isMobile ? BorderRadius.zero : const BorderRadius.only(topLeft: Radius.circular(32)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _navItems.map((item) => HeroMode(enabled: false, child: item.$4)).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AuthProvider auth, bool isMobile) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: C.background,
        border: Border(bottom: BorderSide(color: C.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          if (isMobile) 
            Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer()))
          else
            IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded, color: C.onSurfaceVariant),
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_navItems[_selectedIndex].$2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: C.onSurface, letterSpacing: -0.5)),
                Text(_navItems[_selectedIndex].$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 0.5)),
              ],
            ),
          ),
          _buildActionIcons(auth, isMobile),
        ],
      ),
    );
  }

  Widget _buildActionIcons(AuthProvider auth, bool isMobile) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: () => _refreshCurrentTab(),
          tooltip: 'Refresh Intelligence',
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 24, color: C.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(width: 16),
        _buildUserAvatar(auth),
      ],
    );
  }

  Widget _buildUserAvatar(AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: C.primary.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: C.primary,
        child: Text(
          auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : 'A',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ),
    );
  }

  void _refreshCurrentTab() {
    final admin = context.read<AdminProvider>();
    switch (_selectedIndex) {
      case 0: admin.loadStats(); break;
      case 1: admin.loadUsers(); break;
      case 2: admin.loadPendingProducts(); break;
      case 4: admin.loadAllProducts(); break;
      case 6: admin.loadProductTemplates(); break;
    }
  }

  void _logout(AuthProvider auth) async {
    await auth.logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildSidebar(AuthProvider auth, {bool isDrawer = false}) {
    final width = isDrawer ? 280.0 : (_isSidebarCollapsed ? 82.0 : 280.0);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutQuart,
      width: width,
      decoration: BoxDecoration(
        color: C.surfaceContainerLow,
        border: Border(right: BorderSide(color: C.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildSidebarHeader(isDrawer),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _navItems.length,
              itemBuilder: (context, index) => _buildNavItem(index, isDrawer),
            ),
          ),
          _buildSidebarFooter(auth, isDrawer),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(bool isDrawer) {
    final collapsed = !isDrawer && _isSidebarCollapsed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.primary, Color(0xFF10b981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: C.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(L.appName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: C.onSurface, letterSpacing: -1, height: 1)),
                  Text('ADMIN COMMAND', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 1.5, height: 1.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDrawer) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    final collapsed = !isDrawer && _isSidebarCollapsed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            if (isDrawer) Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? C.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? C.primary.withValues(alpha: 0.1) : Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(item.$1, color: isSelected ? C.primary : C.onSurfaceVariant, size: 22),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Text(item.$2, style: TextStyle(color: isSelected ? C.onSurface : C.onSurfaceVariant, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(AuthProvider auth, bool isDrawer) {
    final collapsed = !isDrawer && _isSidebarCollapsed;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!collapsed) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: C.surfaceContainerLowest, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.outlineVariant.withValues(alpha: 0.2))),
              child: Row(
                children: [
                  _buildUserAvatar(auth),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Administrator', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: C.onSurface)),
                        Text('Active Session', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _logout(auth),
              icon: const Icon(Icons.logout_rounded, size: 18, color: C.error),
              label: collapsed ? const SizedBox.shrink() : const Text('Terminate Session', style: TextStyle(color: C.error, fontSize: 12, fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: C.error.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: C.surfaceContainerLow, shape: BoxShape.circle),
              child: const Icon(Icons.settings_suggest_rounded, size: 64, color: C.primary),
            ),
            const SizedBox(height: 24),
            const Text('System Configuration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Advanced platform parameters and API integrations\nare being provisioned for the executive layer.', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: C.onSurfaceVariant.withValues(alpha: 0.6), height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _TrendingProductsScreen extends StatelessWidget {
  const _TrendingProductsScreen();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final trending = List<ProductModel>.from(products)..sort((a, b) => (b.rating * 10 + b.reviews).compareTo(a.rating * 10 + a.reviews));
    final pad = adaptivePadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: pad,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Market Intelligence', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text('Evaluating product performance based on rating velocity and engagement', style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
            const SizedBox(height: 32),
            if (trending.isEmpty) 
               const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 100), child: Text('No trending markers identified')))
            else 
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trending.length.take(15).length,
                itemBuilder: (context, index) => _TrendingCard(product: trending[index], rank: index + 1),
              ),
          ],
        ),
      ),
    );
  }
}

extension TakeExtension on int {
  List<int> take(int n) => List.generate(this < n ? this : n, (i) => i);
}

class _TrendingCard extends StatelessWidget {
  final ProductModel product;
  final int rank;
  const _TrendingCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    final topThree = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: topThree ? C.primary.withValues(alpha: 0.2) : C.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: topThree ? C.primary : C.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('#$rank', style: TextStyle(color: topThree ? Colors.white : C.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text('Distributed by ${product.farmerName}', style: TextStyle(fontSize: 11, color: C.onSurfaceVariant.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              Text('${product.reviews} interactions', style: TextStyle(fontSize: 10, color: C.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(width: 24),
          Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: -0.5)),
        ],
      ),
    );
  }
}
