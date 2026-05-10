import 'package:flutter/material.dart';
import 'package:farm_flow/data/models.dart';
import 'package:farm_flow/core/constants/colors.dart';
import 'package:farm_flow/widgets/interactive_card.dart';
import 'package:farm_flow/ui/screens/auth/login_screen.dart';
import 'package:farm_flow/ui/screens/auth/register_screen.dart';

class RoleOnboardingScreen extends StatelessWidget {
  final UserRole role;
  const RoleOnboardingScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Determine content based on role
    String title = '';
    String subtitle = '';
    IconData icon = Icons.help_outline;
    Color color = C.primary;

    switch (role) {
      case UserRole.farmer:
        title = 'Grow Your Business';
        subtitle = 'Join 10,000+ farmers selling directly to merchants and consumers.';
        icon = Icons.agriculture_rounded;
        color = const Color(0xFF2e7d32);
        break;
      case UserRole.merchant:
        title = 'Source Fresh Produce';
        subtitle = 'Access wholesale prices and secure direct supplies from reliable farms.';
        icon = Icons.storefront_rounded;
        color = const Color(0xFF1565c0);
        break;
      case UserRole.customer:
        title = 'Farm Fresh Delivery';
        subtitle = 'Get the best quality produce delivered directly to your doorstep.';
        icon = Icons.shopping_basket_rounded;
        color = const Color(0xFFd84315);
        break;
      default:
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 80, color: color),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const Spacer(),
                  // Action buttons
                  InteractiveCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(initialRole: role),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InteractiveCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(initialRole: role),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'BACK TO MARKETPLACE',
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
