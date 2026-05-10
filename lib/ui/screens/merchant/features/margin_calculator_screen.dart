import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';

// ==================== PRICE MARGIN CALCULATOR ====================

class PriceMarginCalculator extends StatefulWidget {
  const PriceMarginCalculator({super.key});

  @override
  State<PriceMarginCalculator> createState() => _PriceMarginCalculatorState();
}

class _PriceMarginCalculatorState extends State<PriceMarginCalculator> {
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _transportCostCtrl = TextEditingController();
  final _otherCostsCtrl = TextEditingController();

  double? _calculatedProfit;
  double? _calculatedMargin;
  double? _breakEvenPrice;

  @override
  void dispose() {
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _quantityCtrl.dispose();
    _transportCostCtrl.dispose();
    _otherCostsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final purchasePrice = double.tryParse(_purchasePriceCtrl.text) ?? 0;
    final sellingPrice = double.tryParse(_sellingPriceCtrl.text) ?? 0;
    final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
    final transportCost = double.tryParse(_transportCostCtrl.text) ?? 0;
    final otherCosts = double.tryParse(_otherCostsCtrl.text) ?? 0;

    if (purchasePrice > 0 && sellingPrice > 0 && quantity > 0) {
      final totalCost = (purchasePrice * quantity) + transportCost + otherCosts;
      final totalRevenue = sellingPrice * quantity;
      final profit = totalRevenue - totalCost;
      final margin = totalRevenue > 0 ? (profit / totalRevenue * 100) : 0;
      final breakEven = quantity > 0 ? totalCost / quantity : 0;

      setState(() {
        _calculatedProfit = profit.toDouble();
        _calculatedMargin = margin.toDouble();
        _breakEvenPrice = breakEven.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1e293b), Color(0xFF334155)],
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
                        color: const Color(0xFF6366f1).withValues(alpha: 0.1)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRADE SIMULATION',
                        style: TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'MARGIN CALCULATOR',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validate deal profitability before committing to operations.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, -35, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InputFieldModern(
                  controller: _purchasePriceCtrl,
                  label: 'PROCUREMENT COST',
                  hint: '0.00',
                  icon: Icons.shopping_bag_rounded,
                  onChanged: _calculate,
                ),
                const SizedBox(height: 12),
                _InputFieldModern(
                  controller: _sellingPriceCtrl,
                  label: 'TARGET SELLING PRICE',
                  hint: '0.00',
                  icon: Icons.sell_rounded,
                  onChanged: _calculate,
                ),
                const SizedBox(height: 12),
                _InputFieldModern(
                  controller: _quantityCtrl,
                  label: 'DEAL VOLUME (UNITS)',
                  hint: '0',
                  icon: Icons.inventory_2_rounded,
                  onChanged: _calculate,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InputFieldModern(
                        controller: _transportCostCtrl,
                        label: 'LOGISTICS',
                        hint: '0.00',
                        icon: Icons.local_shipping_rounded,
                        onChanged: _calculate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputFieldModern(
                        controller: _otherCostsCtrl,
                        label: 'OVERHEADS',
                        hint: '0.00',
                        icon: Icons.receipt_long_rounded,
                        onChanged: _calculate,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Results Preview
          if (_calculatedProfit != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _MarginResultCard(
                      profit: _calculatedProfit!,
                      margin: _calculatedMargin!,
                      breakEven: _breakEvenPrice!,
                      unitProfit: _calculatedProfit! /
                          (double.tryParse(_quantityCtrl.text) ?? 1),
                    ),
                    const SizedBox(height: 20),
                    _RecommendationCard(profit: _calculatedProfit!),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _InputFieldModern extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onChanged;

  const _InputFieldModern({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF1e1b4b)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 16),
              prefixIcon: Icon(icon, color: const Color(0xFF4338ca), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarginResultCard extends StatelessWidget {
  final double profit;
  final double margin;
  final double breakEven;
  final double unitProfit;

  const _MarginResultCard({
    required this.profit,
    required this.margin,
    required this.breakEven,
    required this.unitProfit,
  });

  @override
  Widget build(BuildContext context) {
    final isProfitable = profit >= 0;
    final color = isProfitable ? const Color(0xFF059669) : Colors.red.shade600;

    return InteractiveCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isProfitable
                ? [const Color(0xFF059669), const Color(0xFF047857)]
                : [Colors.red.shade700, Colors.red.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SIMULATED OUTCOME',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                            letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(
                      '${isProfitable ? '+' : ''}₹${profit.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${margin.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _MiniResult(
                    label: 'UNIT PROFIT',
                    value: '₹${unitProfit.toStringAsFixed(1)}'),
                const SizedBox(width: 12),
                _MiniResult(
                    label: 'BREAK-EVEN',
                    value: '₹${breakEven.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniResult extends StatelessWidget {
  final String label;
  final String value;
  const _MiniResult({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final double profit;
  const _RecommendationCard({required this.profit});

  @override
  Widget build(BuildContext context) {
    final isProfitable = profit >= 0;
    final color = isProfitable ? const Color(0xFF059669) : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(isProfitable ? Icons.verified_rounded : Icons.warning_rounded,
              color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfitable ? 'STRATEGIC APPROVAL' : 'RISK DETECTED',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  isProfitable
                      ? 'This trade meets the 2026 profitability threshold.'
                      : 'Margins are below safe levels. Re-evaluate deal terms.',
                  style: TextStyle(
                      fontSize: 13,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
