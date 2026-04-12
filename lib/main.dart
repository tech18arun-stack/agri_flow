import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models.dart';
import 'providers/providers.dart';
import 'services/appwrite_service.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/auth/admin_login_screen.dart';
import 'ui/screens/farmer/farmer_screen.dart';
import 'ui/screens/merchant/merchant_screen.dart';
import 'ui/screens/customer/customer_screen.dart';
import 'ui/screens/customer/features/wishlist_screen.dart';
import 'ui/screens/customer/features/search_screen.dart';
import 'ui/screens/customer/features/checkout_screen.dart';
import 'ui/screens/customer/features/order_confirmation_screen.dart';
import 'ui/screens/profile/universal_profile_screen.dart';
import 'ui/screens/product_detail_screen.dart';
import 'ui/screens/profile/profile_edit_screen.dart';
import 'ui/screens/map/product_map_screen.dart';
import 'ui/screens/notifications/notification_center_screen.dart';
import 'ui/screens/customer/features/customer_orders_screen.dart';
import 'ui/screens/customer/features/all_products_screen.dart';
import 'ui/screens/customer/features/trending_best_sellers_screen.dart';
import 'ui/screens/customer/features/cart_screen.dart';
import 'ui/screens/merchant/features/wholesale_buying_screen.dart';
import 'ui/screens/merchant/features/margin_calculator_screen.dart';
import 'ui/screens/merchant/features/selling_screen.dart';
import 'ui/screens/merchant/features/profit_loss_screen.dart';
import 'ui/web_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await AppwriteService.instance.init();
  runApp(const AgriFlowApp());
}

class AgriFlowApp extends StatefulWidget {
  const AgriFlowApp({super.key});
  @override
  State<AgriFlowApp> createState() => _AgriFlowAppState();
}

class _AgriFlowAppState extends State<AgriFlowApp> {
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.init();
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
      ],
      child: MaterialApp(
        title: 'Agri Flow | அக்ரி ப்ளோ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) {
          return ResponsiveWrapper(child: child!);
        },
        home: const _Router(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => LoginScreen(),
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
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product_detail' && settings.arguments is ProductModel) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: settings.arguments as ProductModel),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Routes: Web = Admin ONLY, Mobile = Customer/Merchant/Farmer ONLY
class _Router extends StatefulWidget {
  const _Router();
  @override
  State<_Router> createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Show loading while auth is initializing
    if (auth.loading && !auth.isLoggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ============ WEB: Admin ONLY ============
    if (kIsWeb) {
      if (auth.isLoggedIn) {
        if (auth.role == UserRole.admin) {
          return const AdminPortalScaffold();
        }
        // Non-admin trying to access web: block
        return const _WebBlockedScreen();
      }
      // Not logged in on web: show admin login
      return const AdminLoginScreen();
    }

    // ============ MOBILE: Customer, Merchant, Farmer ONLY ============
    if (!auth.isLoggedIn) {
      // Not logged in: show splash to check onboarding
      return const SplashScreen();
    }

    // Admin trying to access mobile: block
    if (auth.role == UserRole.admin) {
      return const _MobileBlockedScreen();
    }

    // Valid mobile roles: show role-based dashboard
    return const _HomeShell();
  }
}

/// Shows the correct screen based on user role (mobile only)
class _HomeShell extends StatelessWidget {
  const _HomeShell();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;

    switch (role) {
      case UserRole.farmer:
        return const FarmerScreen();
      case UserRole.merchant:
        return const MerchantScreen();
      case UserRole.customer:
        return const CustomerScreen();
      default:
        return const LoginScreen();
    }
  }
}

/// Block non-admin users from accessing web
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
