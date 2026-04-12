import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _loading = false;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
    try {
      final products = context.read<ProductProvider>().all;
      final orders = context.read<OrderProvider>().orders;
      final users = context.read<AdminProvider>().users;

      // Calculate metrics
      final totalProducts = products.length;
      final totalOrders = orders.length;
      final totalRevenue = orders.where((o) => o.status != 'cancelled').fold(0.0, (sum, o) => sum + o.total);
      final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
      
      // Top products by orders
      final productOrderCount = <String, int>{};
      for (final order in orders) {
        productOrderCount[order.farmerName] = (productOrderCount[order.farmerName] ?? 0) + 1;
      }
      final topFarmers = productOrderCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      // Category distribution
      final categoryCount = <String, int>{};
      for (final product in products) {
        categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
      }

      // User growth (last 7 days)
      final now = DateTime.now();
      final userGrowth = List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        final count = users.where((u) {
          // Approximate - in real app would use createdAt field
          return true;
        }).length;
        return {'date': DateFormat('MMM dd').format(date), 'count': count};
      });

      _analytics = {
        'totalProducts': totalProducts,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'avgOrderValue': avgOrderValue,
        'topFarmers': topFarmers.take(5).toList(),
        'categoryDistribution': categoryCount,
        'userGrowth': userGrowth,
        'totalUsers': users.length,
      };
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics
            const Text('Key Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  icon: Icons.shopping_bag,
                  label: 'Total Orders',
                  value: '${_analytics['totalOrders'] ?? 0}',
                  color: Colors.blue,
                ),
                _MetricCard(
                  icon: Icons.currency_rupee,
                  label: 'Total Revenue',
                  value: '₹${(_analytics['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
                  color: Colors.green,
                ),
                _MetricCard(
                  icon: Icons.receipt_long,
                  label: 'Avg Order Value',
                  value: '₹${(_analytics['avgOrderValue'] ?? 0.0).toStringAsFixed(0)}',
                  color: Colors.orange,
                ),
                _MetricCard(
                  icon: Icons.people,
                  label: 'Total Users',
                  value: '${_analytics['totalUsers'] ?? 0}',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Farmers
            const Text('🏆 Top Farmers by Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...(_analytics['topFarmers'] as List<dynamic>? ?? []).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: C.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.agriculture, color: C.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${entry.value} orders',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Category Distribution
            const Text('📊 Category Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...(_analytics['categoryDistribution'] as Map<String, int>? ?? {}).entries.map((entry) {
              final percentage = (_analytics['totalProducts'] as int? ?? 1) > 0
                  ? (entry.value / (_analytics['totalProducts'] as int)) * 100
                  : 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('${entry.value} (${percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(C.primary),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
