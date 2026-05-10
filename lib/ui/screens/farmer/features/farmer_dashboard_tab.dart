import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../widgets/glass_container.dart';
import './market_prices_screen.dart';
import './analytics_hub_screen.dart';

import './farmer_profile_screen.dart';

class FarmerDashboardTab extends StatelessWidget {
  final String userName;
  final Function(int)? onNavigate;
  final VoidCallback? onAddProduct;

  const FarmerDashboardTab({
    super.key,
    required this.userName,
    this.onNavigate,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final loading = context.watch<ProductProvider>().loading;

    return Container(
      color: const Color(0xFFF6F7F2),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Dashboard Header
          _buildSliverHeader(context),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(products),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('QUICK ACTIONS', 'Streamlined farm management'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  
                  const SizedBox(height: 32),
                  _buildWeatherIntelligence(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('ACTIVE INVENTORY', 'Recent market listings'),
                  const SizedBox(height: 16),
                  _buildInventoryGrid(products, loading),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF064E3B),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.eco_rounded, size: 180, color: Colors.white),
                ),
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hello, $userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Monitoring your agricultural empire',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
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

  Widget _buildQuickStats(List products) {
    final totalValue = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final totalQty = products.fold<double>(0, (sum, p) => sum + p.quantity);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _StatCard(
            title: 'VALUATION',
            value: '₹${totalValue.toStringAsFixed(0)}',
            subtitle: 'Total market value',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF064E3B),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'STOCK',
            value: '${totalQty.toStringAsFixed(0)}',
            subtitle: 'Units',
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _ActionIcon(
            icon: Icons.add_business_rounded,
            label: 'List Crop',
            color: const Color(0xFF064E3B),
            onTap: () => onAddProduct?.call(),
          ),
          _ActionIcon(
            icon: Icons.trending_up_rounded,
            label: 'Live Prices',
            color: const Color(0xFF059669),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
            ),
          ),
          _ActionIcon(
            icon: Icons.analytics_rounded,
            label: 'Analytics',
            color: const Color(0xFF1E40AF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsHubScreen()),
            ),
          ),
          _ActionIcon(
            icon: Icons.shopping_cart_rounded,
            label: 'Orders',
            color: const Color(0xFFD97706),
            onTap: () => onNavigate?.call(2),
          ),
          _ActionIcon(
            icon: Icons.description_rounded,
            label: 'Contracts',
            color: const Color(0xFF7C3AED),
            onTap: () => onNavigate?.call(4),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIntelligence() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFFCD34D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFCD34D).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather Intelligence',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF92400E), letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              const Text(
                'Optimal for Harvest',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
              ),
              const SizedBox(height: 4),
              Text(
                'Clear Skies • 28°C • 64% Humidity',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF92400E).withValues(alpha: 0.7)),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.wb_sunny_rounded, size: 48, color: Color(0xFF92400E)),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(List products, bool loading) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF059669)));
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const Text('🌾', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('No Listings Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B))),
            const SizedBox(height: 4),
            Text('Start listing your crops in the market', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length > 4 ? 4 : products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _InventoryCard(product: product);
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B), letterSpacing: 1),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
            ),
          ],
        ),
        TextButton(
          onPressed: () => onNavigate?.call(1),
          child: const Text('VIEW ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? color : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isPrimary ? Colors.white : color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white : const Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white.withValues(alpha: 0.6) : Colors.grey.shade400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InteractiveCard(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final dynamic product;
  const _InventoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: product.imageUrl != null && product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : const Center(child: Icon(Icons.eco_rounded, size: 32, color: Color(0xFF059669))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}/${product.unit}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.quantity.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
