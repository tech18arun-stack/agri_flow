import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import 'features/customer_home_screen.dart';
import 'features/all_products_screen.dart';
import 'features/trending_best_sellers_screen.dart';
import 'features/cart_screen.dart';
import '../../../widgets/floating_glass_nav_bar.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _currentIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  void _onProductTap(ProductModel product) {
    Navigator.pushNamed(context, '/product_detail', arguments: product);
  }

  void _onTabChange(int index) {
    HapticFeedback.lightImpact();

    // Double-tap same tab → could trigger scroll-to-top later
    if (_currentIndex == index) {
      // Feature requested: Add scroll-to-top via ScrollController in each screen
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          _onTabChange(0);
        }
      },
      child: Scaffold(
        body: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              CustomerHomeScreen(onProductTap: _onProductTap),
              const AllProductsScreen(),
              const TrendingAndBestSellersScreen(),
              const CartScreen(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: FloatingGlassNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabChange,
          items: [
            FloatingGlassNavItem(icon: Icons.home_rounded, label: 'Home'),
            FloatingGlassNavItem(icon: Icons.search_rounded, label: 'Explore'),
            FloatingGlassNavItem(icon: Icons.trending_up_rounded, label: 'Hot'),
            FloatingGlassNavItem(
                icon: Icons.shopping_cart_rounded,
                label: 'Cart',
                badge: context.watch<CartProvider>().itemCount),
          ],
        ),
        extendBody: true,
        extendBodyBehindAppBar: false,
      ),
    );
  }
}
