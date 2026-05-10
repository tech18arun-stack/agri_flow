import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';
import '../../../data/models.dart';

class RolePreviewScreen extends StatefulWidget {
  const RolePreviewScreen({super.key});

  @override
  State<RolePreviewScreen> createState() => _RolePreviewScreenState();
}

class _RolePreviewScreenState extends State<RolePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with overlay
          Image.asset(
            'assets/images/agri_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Logo & Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Farm Flow',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose Your Path to Begin',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Role Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildRoleCard(
                        context,
                        title: 'I want to Buy',
                        subtitle: 'Fresh vegetables & fruits directly from farms.',
                        icon: Icons.shopping_basket_rounded,
                        color: Colors.greenAccent,
                        role: UserRole.customer,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        title: 'I want to Sell',
                        subtitle: 'List your harvest and connect with bulk buyers.',
                        icon: Icons.agriculture_outlined,
                        color: Colors.orangeAccent,
                        role: UserRole.farmer,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        title: 'I want to Bulk Buy',
                        subtitle: 'Wholesale sourcing for stores & businesses.',
                        icon: Icons.storefront_rounded,
                        color: Colors.blueAccent,
                        role: UserRole.merchant,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Bottom Login Link
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required UserRole role,
  }) {
    return InteractiveCard(
      onTap: () {
        if (role == UserRole.customer) {
           Navigator.pushNamed(context, '/customer_onboarding');
        } else if (role == UserRole.farmer) {
           Navigator.pushNamed(context, '/farmer_onboarding');
        } else if (role == UserRole.merchant) {
           Navigator.pushNamed(context, '/merchant_onboarding');
        }
      },
      child: GlassContainer(
        opacity: 0.1,
        blur: 15,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
