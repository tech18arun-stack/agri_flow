import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';

// ==================== PROFIT LOSS TRACKING SCREEN ====================

class ProfitLossTrackingScreen extends StatefulWidget {
  const ProfitLossTrackingScreen({super.key});

  @override
  State<ProfitLossTrackingScreen> createState() =>
      _ProfitLossTrackingScreenState();
}

class _ProfitLossTrackingScreenState extends State<ProfitLossTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<TransactionProvider>().loadTransactions(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProv, child) {
        final report = transactionProv.report;
        final totalPurchases = report.totalPurchases;
        final totalSales = report.totalSales;
        final totalProfit = report.netProfit;

        return Container(
          color: C.background,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        color: C.background,
                      ),
                    ),
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [C.primary.withValues(alpha: 0.15), Colors.transparent],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FINANCIAL INTELLIGENCE',
                            style: TextStyle(
                                color: C.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PROFIT & LOSS',
                            style: TextStyle(
                                color: C.onSurface,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: C.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color:
                                            C.primary.withValues(alpha: 0.2))),
                                child: Text(
                                    'NET GAIN: ₹${totalProfit.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: C.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _BentoStatCard(
                      title: 'REVENUE',
                      value: '₹${totalSales.toStringAsFixed(0)}',
                      icon: Icons.payments_rounded,
                      color: C.primary,
                      trend: '+12.5%',
                      isPositive: true,
                    ),
                    _BentoStatCard(
                      title: 'PROCUREMENT',
                      value: '₹${totalPurchases.toStringAsFixed(0)}',
                      icon: Icons.shopping_basket_rounded,
                      color: C.tertiary,
                      trend: '-5.2%',
                      isPositive: false,
                    ),
                    _BentoStatCard(
                      title: 'OPEX',
                      value: '₹0',
                      icon: Icons.receipt_long_rounded,
                      color: C.secondary,
                      trend: 'Stable',
                      isPositive: true,
                    ),
                    _BentoStatCard(
                      title: 'NET MARGIN',
                      value: totalSales > 0
                          ? '${((totalProfit / totalSales) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.insights_rounded,
                      color: C.primary,
                      trend: '+2.1%',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRANSACTION LEDGER',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: C.onSurface,
                            letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (transactionProv.transactions.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: _EmptyTransactionsState()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = transactionProv.transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransactionCardModern(transaction: tx),
                        );
                      },
                      childCount: transactionProv.transactions.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

class _BentoStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _BentoStatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      scaleFactor: 0.98,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: (isPositive ? C.primary : Colors.orange)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(trend,
                      style: TextStyle(
                          color: isPositive ? C.primary : Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: C.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: C.onSurface,
                        letterSpacing: -0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCardModern extends StatelessWidget {
  final dynamic transaction;
  const _TransactionCardModern({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'sale';
    return InteractiveCard(
      scaleFactor: 0.99,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: (isCredit ? C.primary : Colors.blue)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(isCredit ? Icons.add_rounded : Icons.remove_rounded,
                  color: isCredit ? C.primary : Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: C.onSurface,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(transaction.date.toString().split(' ')[0],
                      style:
                          TextStyle(color: C.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(
              '${isCredit ? "+" : "-"}₹${transaction.amount.toInt()}',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isCredit ? C.primary : Colors.orange,
                  letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined,
            size: 64, color: C.onSurfaceVariant.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        const Text('No Transaction data',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey)),
      ],
    );
  }
}
