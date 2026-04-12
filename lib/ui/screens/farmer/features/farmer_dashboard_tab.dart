import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';

class FarmerDashboardTab extends StatelessWidget {
  final String userName;
  const FarmerDashboardTab({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    final loading = context.watch<ProductProvider>().loading;

    return Container(
      color: const Color(0xFFfafaf3),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('Welcome back,\n$userName.',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0d631b),
                                height: 1.1)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Your harvests are reaching ${products.length} markets today.',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Bento Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Revenue Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: isNarrow ? 130 : 140,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0d631b),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.trending_up,
                                          color: Color(0xFFc8f17a), size: 20),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFc8f17a)
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8)),
                                      child: const Text('LIVE',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFc8f17a))),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text('₹${_calculateTotalRevenue(products)}',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ),
                                    const Text('Total Value',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Right side cards
                        Expanded(
                          child: Column(
                            children: [
                              // Active Listings
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFfddab2),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.inventory_2,
                                            color: Color(0xFF735a3a), size: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('${products.length}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF735a3a))),
                                      ),
                                      const Text('Active',
                                          style: TextStyle(fontSize: 9)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Total Quantity
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF2b3f00),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.scale,
                                            color: Color(0xFFc8f17a), size: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(_calculateTotalQuantity(products),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFc8f17a))),
                                      ),
                                      const Text('Quantity',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFc8f17a))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Weather Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0xFFfddab2), const Color(0xFFe2c19b)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.wb_sunny,
                        color: Color(0xFF735a3a), size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clear Skies',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF735a3a))),
                        Text('28°C • Ideal for harvesting',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // My Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Products',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0d631b))),
                    Text('Managing your active inventory',
                        style:
                            TextStyle(fontSize: 11, color: C.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Products Grid or Empty State
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                    color: const Color(0xFFf5f4ed),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Icon(Icons.eco_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('No products listed yet',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Tap "Add Product" to list your harvest',
                        style: TextStyle(fontSize: 11)),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 140,
                ),
                itemCount: products.length > 4 ? 4 : products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  final inStock = p.quantity > 100;
                  final lowStock = p.quantity > 0 && p.quantity <= 100;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: C.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                  child: Icon(Icons.eco,
                                      size: 32, color: Color(0xFF0d631b))),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: inStock
                                        ? const Color(0xFFc8f17a)
                                        : lowStock
                                            ? const Color(0xFFffddb6)
                                            : const Color(0xFFffdad6),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(16)),
                                  ),
                                  child: Text(
                                    inStock
                                        ? 'In Stock'
                                        : lowStock
                                            ? 'Low'
                                            : 'Out',
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF002b02)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('₹${p.price}/${p.unit}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002b02))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalRevenue(List products) {
    final total = products.fold<double>(
        0, (sum, p) => sum + (p.price * p.quantity));
    return total.toStringAsFixed(0);
  }

  String _calculateTotalQuantity(List products) {
    final total = products.fold<double>(
        0, (sum, p) => sum + p.quantity);
    return '${total.toStringAsFixed(0)} kg';
  }
}
