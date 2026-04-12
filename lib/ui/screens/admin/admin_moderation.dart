import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../providers/providers.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = adaptivePadding(context);
    final web = isWeb(context);
    final adminProv = context.watch<AdminProvider>();
    final products = adminProv.pendingProducts;

    if (adminProv.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiLabel(en: L.productModeration, ta: L.productModerationTa, enSize: web ? 22 : 18, enWeight: FontWeight.w800),
                    Text(L.modDescTa, style: const TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => adminProv.loadPendingProducts(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary cards
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cols = web ? 3 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: web ? 2.5 : 3.5,
                children: [
                  _SummaryCard(value: adminProv.moderationQueue.toString(), label: L.pendingReviews, labelTa: L.pendingReviewsTa, icon: Icons.pending_outlined, color: C.primary),
                  _SummaryCard(value: 'Live', label: 'System Status', labelTa: 'கணினி நிலை', icon: Icons.check_circle_outline, color: C.tertiary, trend: 'Online'),
                  _SummaryCard(value: '0', label: L.flaggedListings, labelTa: L.flaggedListingsTa, icon: Icons.warning_amber_outlined, color: C.error, trend: 'Safe'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          if (products.isEmpty)
            const EmptyStateWidget(icon: Icons.verified_outlined, title: 'No products pending review', subtitle: 'நிலுவையில் உள்ள பொருட்கள் இல்லை')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.eco, color: C.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BiLabel(en: p.name, ta: p.nameTa, enSize: 15, enWeight: FontWeight.w700),
                                  const SizedBox(height: 2),
                                  Text('${p.farmerName} • ${p.category.toUpperCase()}', style: const TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                                  Text('Price: ₹${p.price}/${p.unit} • Qty: ${p.quantity} ${p.unit}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const StatusBadge(status: 'PENDING', color: Colors.orange),
                                const SizedBox(height: 4),
                                Text(p.location, style: const TextStyle(fontSize: 10, color: C.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => adminProv.updateProductStatus(p.id, 'rejected'),
                                icon: const Icon(Icons.close, size: 16),
                                label: Text(L.rejectTa, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(foregroundColor: C.error, side: const BorderSide(color: C.error), padding: const EdgeInsets.symmetric(vertical: 12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () => adminProv.updateProductStatus(p.id, 'active'),
                                icon: const Icon(Icons.check, size: 16),
                                label: Text(L.approveTa, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value, label, labelTa;
  final IconData icon;
  final Color color;
  final String? trend;
  const _SummaryCard({required this.value, required this.label, required this.labelTa, required this.icon, required this.color, this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22, color: color), 
              if (trend != null) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(trend!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color))
                )
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          Text(labelTa, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.onSurfaceVariant)),
        ],
      ),
    );
  }
}

