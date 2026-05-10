import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:farm_flow/core/theme/app_theme.dart';
import 'package:farm_flow/data/models.dart';
import 'package:farm_flow/providers/providers.dart';
import 'package:farm_flow/services/appwrite_service.dart';
import 'package:farm_flow/ui/screens/splash/splash_screen.dart';
import 'package:farm_flow/ui/screens/onboarding/onboarding_screen.dart';
import 'package:farm_flow/ui/screens/auth/login_screen.dart';
import 'package:farm_flow/ui/screens/auth/register_screen.dart';
import 'package:farm_flow/ui/screens/auth/admin_login_screen.dart';
import 'package:farm_flow/ui/screens/farmer/farmer_screen.dart';
import 'package:farm_flow/ui/screens/merchant/merchant_screen.dart';
import 'package:farm_flow/ui/screens/customer/customer_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/wishlist_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/search_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/checkout_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/order_confirmation_screen.dart';
import 'package:farm_flow/ui/screens/profile/universal_profile_screen.dart';
import 'package:farm_flow/ui/screens/product_detail_screen.dart';
import 'package:farm_flow/ui/screens/profile/profile_edit_screen.dart';
import 'package:farm_flow/ui/screens/map/product_map_screen.dart';
import 'package:farm_flow/ui/screens/notifications/notification_center_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/customer_orders_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/all_products_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/trending_best_sellers_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/cart_screen.dart';
import 'package:farm_flow/ui/screens/merchant/features/wholesale_buying_screen.dart';
import 'package:farm_flow/ui/screens/merchant/features/margin_calculator_screen.dart';
import 'package:farm_flow/ui/screens/merchant/features/selling_screen.dart';
import 'package:farm_flow/ui/screens/merchant/features/profit_loss_screen.dart';
import 'package:farm_flow/ui/web_admin.dart';
import 'package:farm_flow/ui/screens/flower_price/flower_price_dashboard.dart';
import 'package:farm_flow/ui/screens/onboarding/role_preview_screen.dart';
import 'package:farm_flow/ui/screens/auth/role_onboarding_screen.dart';
import 'package:farm_flow/ui/screens/customer/features/flower_prices_public_screen.dart';
import 'package:farm_flow/services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dynamic config from local/GitHub
  await ConfigService.instance.init();
  
  // High-level UI error catching to prevent grey screens
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(details.exception.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => main(), // Simple reload attempt
                child: const Text('Reload App'),
              ),
            ],
          ),
        ),
      ),
    );
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  try {
    await AppwriteService.instance.init();
  } catch (e) {
    debugPrint('❌ Appwrite init failed: $e');
  }
  
  runApp(const FarmFlowApp());
}

class FarmFlowApp extends StatefulWidget {
  const FarmFlowApp({super.key});
  @override
  State<FarmFlowApp> createState() => _FarmFlowAppState();
}

class _FarmFlowAppState extends State<FarmFlowApp> {
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.init();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await [Permission.location, Permission.notification].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PriceEngineProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LOIProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()..init()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CartPersistenceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FlowerPriceProvider()),
        ChangeNotifierProvider(create: (_) => FlowerCatalogProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
      ],
      child: MaterialApp(
        title: 'Farm Flow | பாம் ப்ளோ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => ResponsiveWrapper(child: child ?? const SizedBox.shrink()),
        home: const _Router(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/role_preview': (_) => const RolePreviewScreen(),
          '/farmer_onboarding': (_) => const RoleOnboardingScreen(role: UserRole.farmer),
          '/merchant_onboarding': (_) => const RoleOnboardingScreen(role: UserRole.merchant),
          '/customer_onboarding': (_) => const RoleOnboardingScreen(role: UserRole.customer),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/admin_login': (_) => const AdminLoginScreen(),
          '/profile': (_) => const UniversalProfileScreen(),
          '/profile_edit': (_) => const ProfileEditScreen(),
          '/product_map': (_) => const ProductMapScreen(),
          '/notifications': (_) => const NotificationCenterScreen(),
          '/orders': (_) => const CustomerOrdersScreen(),
          '/wishlist': (_) => const WishlistScreen(),
          '/search': (_) => const SearchScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/order_confirmation': (_) => const OrderConfirmationScreen(),
          '/cart': (_) => const CartScreen(),
          '/products': (_) => const AllProductsScreen(),
          '/trending': (_) => const TrendingAndBestSellersScreen(),
          '/wholesale': (_) => const WholesaleBuyingScreen(),
          '/margin': (_) => const PriceMarginCalculator(),
          '/selling': (_) => const SellingScreen(),
          '/profit-loss': (_) => const ProfitLossTrackingScreen(),
          '/flowers': (_) => const FlowerPriceDashboard(),
          '/flower_prices_public': (_) => const FlowerPricesPublicScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product_detail' && settings.arguments is ProductModel) {
            return MaterialPageRoute(builder: (_) => ProductDetailScreen(product: settings.arguments as ProductModel));
          }
          return null;
        },
      ),
    );
  }
}

class _Router extends StatelessWidget {
  const _Router();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading && !auth.isLoggedIn) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (kIsWeb) {
      if (auth.isLoggedIn) {
        if (auth.role == UserRole.admin) return const AdminPortalScaffold();
        if (auth.role == UserRole.priceUpdater) return const FlowerPriceDashboard();
        return const _WebBlockedScreen();
      }
      return const AdminLoginScreen();
    }
    if (!auth.isLoggedIn && !auth.isGuest) return const SplashScreen();
    if (auth.role == UserRole.admin || auth.role == UserRole.priceUpdater) return const _MobileBlockedScreen();
    return const _HomeShell();
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.role) {
      case UserRole.farmer: return const FarmerScreen();
      case UserRole.merchant: return const MerchantScreen();
      case UserRole.customer: return const CustomerScreen();
      case UserRole.guest: return const RolePreviewScreen();
      default: return const LoginScreen();
    }
  }
}

class _WebBlockedScreen extends StatelessWidget {
  const _WebBlockedScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.devices, size: 80, color: Colors.orange),
              ),
              const SizedBox(height: 24),
              const Text(
                'Web Access Restricted',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'This platform is for Administrators only.\nPlease use the mobile app for other roles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Switch Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Block admin users from accessing mobile
class _MobileBlockedScreen extends StatelessWidget {
  const _MobileBlockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d631b).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF0d631b)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin Portal is Web Only',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please access the admin dashboard\nfrom a web browser.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d631b),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive wrapper that constrains web layouts
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // On web, constrain max width for readability
    if (kIsWeb && width > 1400) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: child,
        ),
      );
    }
    return child;
  }
}
