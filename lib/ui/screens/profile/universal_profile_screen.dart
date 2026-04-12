import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../customer/features/customer_profile_screen.dart';
import '../farmer/features/farmer_profile_screen.dart';
import '../merchant/features/merchant_profile_screen.dart';

/// Universal profile screen that shows the correct profile based on user role
class UniversalProfileScreen extends StatelessWidget {
  const UniversalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;

    Widget getProfileScreen() {
      switch (role) {
        case UserRole.farmer:
          return FarmerProfileScreen();
        case UserRole.merchant:
          return MerchantProfileScreen();
        case UserRole.customer:
          return CustomerProfileScreen();
        default:
          return CustomerProfileScreen();
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey<UserRole?>(role),
        child: getProfileScreen(),
      ),
    );
  }
}
