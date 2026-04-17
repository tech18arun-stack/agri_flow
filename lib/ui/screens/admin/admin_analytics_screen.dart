import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../core/constants/strings.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> with SingleTickerProviderStateMixin {
  bool _loading = false;
  Map<String, dynamic> _analytics = {};
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadAnalytics();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final products = context.read<ProductProvider>().all;
      final orders = context.read<OrderProvider>().orders;
      final users = context.read<AdminProvider>().users;

      final totalProducts = products.length;
      final totalOrders = orders.length;
      final totalRevenue = orders.where((o) => o.status != 'cancelled').fold(0.0, (sum, o) => sum + o.total);
      final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
      
      final productOrderCount = <String, int>{};
      for (final order in orders) {
        productOrderCount[order.farmerName] = (productOrderCount[order.farmerName] ?? 0) + 1;
      }
      final topFarmers = productOrderCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      final categoryCount = <String, int>{};
      for (final product in products) {
        categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
      }

      _analytics = {
        'totalProducts': totalProducts,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'avgOrderValue': avgOrderValue,
        'topFarmers': topFarmers.take(5).toList(),
        'categoryDistribution': categoryCount,
        'totalUsers': users.length,
      };
      _fadeController.forward();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: C.primary));
    }

    final web = isWeb(context);
    final pad = adaptivePadding(context);

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: pad,
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(web),
              const SizedBox(height: 24),
              
              // Bento Stats Grid
              _buildBentoStats(web),
              
              const SizedBox(height: 32),
              
              if (web)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildTopFarmers()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildCategoryDistribution()),
                  ],
                )
              else ...[
                _buildTopFarmers(),
                const SizedBox(height: 32),
                _buildCategoryDistribution(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool web) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BiLabel(
              en: L.analytics,
              ta: L.analyticsTa,
              enSize: web ? 28 : 20,
              enWeight: FontWeight.w900,
            ),
            const SizedBox(height: 4),
            Text(
              'Deep insights into platform economics',
              style: TextStyle(
                fontSize: 13,
                color: C.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary, size: 20),
        onPressed: _loadAnalytics,
      ),
    );
  }

  Widget _buildBentoStats(bool web) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: web ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: web ? 1.5 : 1.2,
      children: [
        _ModernMetricCard(
          label: 'Total Orders',
          value: '${_analytics['totalOrders'] ?? 0}',
          icon: Icons.shopping_bag_rounded,
          color: Colors.blue,
        ),
        _ModernMetricCard(
          label: 'Revenue',
          value: '₹${(_analytics['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
          icon: Icons.payments_rounded,
          color: Colors.green,
        ),
        _ModernMetricCard(
          label: 'AOV',
          value: '₹${(_analytics['avgOrderValue'] ?? 0.0).toStringAsFixed(0)}',
          icon: Icons.data_saver_off_rounded,
          color: Colors.orange,
        ),
        _ModernMetricCard(
          label: 'Ecosystem',
          value: '${_analytics['totalUsers'] ?? 0}',
          icon: Icons.hub_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTopFarmers() {
    final top = (_analytics['topFarmers'] as List<dynamic>? ?? []);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('🏆 Top Providers', 'By volume of successful operations'),
          const SizedBox(height: 24),
          if (top.isEmpty)
            _buildEmptyState()
          else
            ...top.map((entry) => _buildFarmerRankItem(entry)),
        ],
      ),
    );
  }

  Widget _buildFarmerRankItem(dynamic entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.agriculture_rounded, color: C.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(20)),
            child: Text('${entry.value} ops', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    final dist = (_analytics['categoryDistribution'] as Map<String, int>? ?? {});
    final total = _analytics['totalProducts'] as int? ?? 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('📊 Categories', 'Stock distribution analysis'),
          const SizedBox(height: 24),
          if (dist.isEmpty)
            _buildEmptyState()
          else
            ...dist.entries.map((e) => _buildCategoryProgress(e.key, e.value, total)),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, int count, int total) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: C.onSurfaceVariant)),
              Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: C.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: C.surfaceContainerLow,
              color: C.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: C.onSurface)),
        Text(sub, style: TextStyle(fontSize: 11, color: C.onSurfaceVariant.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text('Insufficient data for visualization', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
      ),
    );
  }
}

class _ModernMetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ModernMetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -1)),
        ],
      ),
    );
  }
}
