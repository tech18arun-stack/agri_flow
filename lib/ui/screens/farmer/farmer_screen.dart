import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_flow/providers/providers.dart';
import 'package:farm_flow/core/constants/colors.dart';
import 'package:farm_flow/ui/screens/farmer/features/my_products_screen.dart';
import 'package:farm_flow/ui/screens/farmer/features/farmer_orders_tab.dart';
import 'package:farm_flow/ui/screens/farmer/features/farmer_loi_tab.dart';
import 'package:farm_flow/ui/screens/farmer/features/farmer_add_product_tab.dart';
import 'package:farm_flow/ui/screens/farmer/features/harvest_tab.dart';
import 'package:farm_flow/ui/screens/farmer/features/farmer_dashboard_tab.dart';
import 'package:farm_flow/widgets/floating_glass_nav_bar.dart';

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
      context
          .read<HarvestProvider>()
          .loadFarmerHarvests(context.read<AuthProvider>().user?.id ?? '');
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
      FarmerDashboardTab(
        userName: context.watch<AuthProvider>().user?.name ?? 'Farmer',
        onNavigate: (index) => setState(() => _currentIndex = index),
        onAddProduct: () => _navigateTo(const FarmerAddProductTab(), 'Add Product'),
      ),
      MyProductsScreen(onAddProduct: () {
        _navigateTo(const FarmerAddProductTab(), 'Add Product');
      }),
      const FarmerOrdersTab(),
      const HarvestTab(),
      const FarmerLOITab(),
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
        backgroundColor: const Color(0xFFF6F7F2),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: FloatingGlassNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            FloatingGlassNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', labelTa: 'முகப்பு'),
            FloatingGlassNavItem(icon: Icons.inventory_2_rounded, label: 'Stock', labelTa: 'இருப்பு'),
            FloatingGlassNavItem(icon: Icons.shopping_bag_rounded, label: 'Orders', labelTa: 'ஆர்டர்'),
            FloatingGlassNavItem(icon: Icons.grass_rounded, label: 'Harvest', labelTa: 'அறுவடை'),
            FloatingGlassNavItem(icon: Icons.description_rounded, label: 'LOI', labelTa: 'ஒப்பந்தம்'),
          ],
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _currentIndex == 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LayoutBuilder(builder: (context, constraints) {
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
              }))
            : null,
      ),
    );
  }
}

