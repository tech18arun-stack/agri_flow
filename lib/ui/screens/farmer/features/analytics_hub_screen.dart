import 'package:flutter/material.dart';
import '/../../ui/screens/farmer/features/trending_products_screen.dart';
import '/../../ui/screens/farmer/features/price_comparison_screen.dart';
import '/../../ui/screens/farmer/features/best_sellers_screen.dart';

class AnalyticsHubScreen extends StatefulWidget {
  final int initialIndex;
  const AnalyticsHubScreen({super.key, this.initialIndex = 0});

  @override
  State<AnalyticsHubScreen> createState() => _AnalyticsHubScreenState();
}

class _AnalyticsHubScreenState extends State<AnalyticsHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B1B1B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics Hub',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF059669),
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: const Color(0xFF059669),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'TRENDING'),
            Tab(text: 'COMPARE'),
            Tab(text: 'BEST SELLERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TrendingProductsScreen(),
          PriceComparisonScreen(),
          BestSellersScreen(),
        ],
      ),
    );
  }
}
