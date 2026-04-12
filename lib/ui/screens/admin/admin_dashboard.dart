import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/shared_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<AdminProvider>().loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AdminProvider>();
    final pad = adaptivePadding(context);
    final web = isWeb(context);

    if (stats.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiLabel(
                        en: L.executiveSummary,
                        ta: L.executiveSummaryTa,
                        enSize: web ? 24 : 18,
                        enWeight: FontWeight.w800),
                    Text('Real-time performance metrics',
                        style:
                            TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => stats.loadStats(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Bento Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                width: Responsive.pctW(context, web ? 0.3 : 1.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: C.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: C.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.people_outlined,
                                color: C.primary, size: 24)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: C.tertiaryFixed.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('LIVE',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: C.onTertiaryFixed))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('${stats.totalFarmers}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: C.primary)),
                    Text(L.totalFarmersTa,
                        style:
                            TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                width: Responsive.pctW(context, web ? 0.2 : 0.47),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: C.secondaryContainer,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: C.onSecondaryContainer
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.storefront_outlined,
                                color: C.onSecondaryContainer, size: 20))),
                    const SizedBox(height: 12),
                    Text('${stats.totalMerchants}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: C.onSecondaryContainer)),
                    Text(L.activeMerchantsTa,
                        style: const TextStyle(
                            fontSize: 9, color: C.onSecondaryContainer)),
                  ],
                ),
              ),
              Container(
                width: Responsive.pctW(context, web ? 0.2 : 0.47),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: C.primary, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: C.onPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.warning_amber_outlined,
                                color: C.onPrimary, size: 20))),
                    const SizedBox(height: 12),
                    Text('${stats.moderationQueue}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: C.onPrimary)),
                    Text(L.moderationQueueTa,
                        style:
                            const TextStyle(fontSize: 9, color: C.onPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Monthly Sales Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: C.silkGradient,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: C.onPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.payments_outlined,
                            color: C.onPrimary, size: 20)),
                    const SizedBox(width: 12),
                    Text(L.monthlySalesTa,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: C.onPrimary.withValues(alpha: 0.8))),
                  ],
                ),
                const SizedBox(height: 12),
                Text('₹${(stats.monthlySales / 1000).toStringAsFixed(1)}K',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: C.onPrimary)),
                Text(
                    'Total from ${stats.totalFarmers + stats.totalMerchants} users',
                    style: TextStyle(
                        fontSize: 11,
                        color: C.onPrimary.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
