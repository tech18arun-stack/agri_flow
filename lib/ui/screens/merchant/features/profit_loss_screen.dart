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
                        gradient: LinearGradient(
                          colors: [C.primary, C.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -60,
                      right: -60,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: C.onPrimary.withValues(alpha: 0.1)),
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
                                color: C.tertiaryFixed,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PROFIT & LOSS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: C.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            C.primary.withValues(alpha: 0.3))),
                                child: Text(
                                    'NET GAIN: ₹${totalProfit.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: C.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900)),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(trend,
                      style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: C.onSurface)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                color: (isCredit ? Colors.green : Colors.blue)
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
                        fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                const SizedBox(height: 4),
                Text(transaction.date.toString().split(' ')[0],
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? "+" : "-"}₹${transaction.amount.toInt()}',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isCredit ? C.primary : Colors.red),
          ),
        ],
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
            size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No Transaction data',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey)),
      ],
    );
  }
}
