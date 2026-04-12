import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  final List<_SellableItem> _inventory = [
    const _SellableItem(
      productName: 'Organic Tomatoes',
      category: 'vegetables',
      quantity: 500,
      unit: 'kg',
      purchasePrice: 20,
      location: 'Coimbatore',
    ),
    const _SellableItem(
      productName: 'Fresh Mangoes',
      category: 'fruits',
      quantity: 200,
      unit: 'kg',
      purchasePrice: 80,
      location: 'Salem',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.background,
      child: CustomScrollView(
        slivers: [
          // Smart Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [C.primary, C.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
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
                        'RETAIL OPERATIONS',
                        style: TextStyle(
                            color: C.tertiaryFixed,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SALES TERMINAL',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Optimize your listings and reach thousands of consumers.',
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('ACTIVE STOCK',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('${_inventory.length} SKUs',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: C.onSurface)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('MARKET TREND',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('BULLISH',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: C.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Inventory List
          if (_inventory.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Nothing to list',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _SellableItemCardModern(
                      key: ValueKey(_inventory[index].productName),
                      item: _inventory[index],
                    ),
                  ),
                  childCount: _inventory.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _SellableItemCardModern extends StatefulWidget {
  final _SellableItem item;
  const _SellableItemCardModern({super.key, required this.item});

  @override
  State<_SellableItemCardModern> createState() =>
      _SellableItemCardModernState();
}

class _SellableItemCardModernState extends State<_SellableItemCardModern> {
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
        text: (widget.item.purchasePrice * 1.3).toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final sellingPrice = double.tryParse(_priceCtrl.text) ?? 0;
    final margin = sellingPrice > 0
        ? ((sellingPrice - widget.item.purchasePrice) / sellingPrice * 100)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: C.primary.withValues(alpha: 0.02),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: C.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: C.primary, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.productName.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: C.onSurface,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'STOCK: ${widget.item.quantity.toInt()} ${widget.item.unit} • COST: ₹${widget.item.purchasePrice.toInt()}',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TARGET LISTING PRICE',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  letterSpacing: 1)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceCtrl,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: C.onSurface,
                                letterSpacing: -1),
                            decoration: const InputDecoration(
                                prefixText: '₹ ',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: (margin >= 20 ? C.primary : Colors.orange)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('MARGIN',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  letterSpacing: 1)),
                          Text('${margin.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: margin >= 20
                                      ? C.primary
                                      : Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                InteractiveCard(
                  onTap: () => _publishListing(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: C.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Center(
                      child: Text('PUBLISH TO MARKETPLAY',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _publishListing(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: C.primary, size: 64),
              const SizedBox(height: 16),
              const Text('Listing Published!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface)),
              const SizedBox(height: 8),
              Text(
                  '${widget.item.productName} is now live at ₹${_priceCtrl.text}/${widget.item.unit}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              InteractiveCard(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Center(
                      child: Text('DONE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellableItem {
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double purchasePrice;
  final String location;

  const _SellableItem({
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    required this.location,
  });
}
