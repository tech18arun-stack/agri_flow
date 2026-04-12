import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  String _selectedTab = 'all';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final merchantId = auth.user?.id ?? '';
      if (merchantId.isNotEmpty) {
        context.read<InventoryProvider>().loadInventory(merchantId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventory, child) {
        final items = inventory.items;
        final totalValue =
            items.fold(0.0, (sum, item) => sum + item.totalValue);

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
                            'STRATEGIC RESERVES',
                            style: TextStyle(
                                color: C.tertiaryFixed,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'INVENTORY',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  '₹${totalValue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Section (Floating Cards)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: [
                    _SummaryCard(
                      label: 'TOTAL ITEMS',
                      value: items.length.toString(),
                      icon: Icons.inventory_2_rounded,
                      color: C.primary,
                    ),
                    _SummaryCard(
                      label: 'OUT OF STOCK',
                      value:
                          items.where((i) => i.quantity <= 0).length.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: C.tertiary,
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _FilterTab(
                          label: 'All Assets',
                          isActive: _selectedTab == 'all',
                          onTap: () => setState(() => _selectedTab = 'all')),
                      _FilterTab(
                          label: 'Low Stock',
                          isActive: _selectedTab == 'low',
                          onTap: () => setState(() => _selectedTab = 'low')),
                    ],
                  ),
                ),
              ),

              // Inventory Items
              if (items.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No inventory items found',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _InventoryCardModern(
                            key: ValueKey(items[index].id),
                            item: items[index],
                          ),
                        );
                      },
                      childCount: items.length,
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

// ==================== SUMMARY CARD ====================

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FILTER TAB ====================

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: isActive ? C.primary : Colors.grey.shade200),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: C.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _InventoryCardModern extends StatelessWidget {
  final InventoryItem item;
  const _InventoryCardModern({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final daysSincePurchase =
        DateTime.now().difference(item.purchasedAt).inDays;
    final isFresh = daysSincePurchase <= 3;
    final freshnessColor = isFresh ? C.primary : C.tertiary;

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
                      color: C.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(_getCategoryIcon(item.category),
                      color: C.onSurface, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: C.onSurface,
                            letterSpacing: -0.5),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded,
                              size: 10, color: freshnessColor),
                          const SizedBox(width: 4),
                          Text(
                            '$daysSincePurchase DAYS IN STOCK',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: freshnessColor,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                    isInStock: item.isInStock,
                    quantity: item.quantity,
                    unit: item.unit),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatTile(
                        label: 'PROCUREMENT COST',
                        value: '₹${item.purchasePrice.toInt()}'),
                    const SizedBox(width: 12),
                    _StatTile(
                        label: 'ASSET VALUE',
                        value: '₹${item.totalValue.toInt()}',
                        highlight: true),
                  ],
                ),
                const SizedBox(height: 24),
                InteractiveCard(
                  onTap: () => _showSellDialog(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'EXECUTE SETTLEMENT',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5),
                      ),
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

  void _showSellDialog(BuildContext context) {
    final controller = TextEditingController(
        text: item.sellingPrice?.toStringAsFixed(0) ?? '');
    final inventory = context.read<InventoryProvider>();
    final transaction = context.read<TransactionProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('TRANSACTION',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: C.tertiary,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('Sell ${item.productName}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price per unit',
                    prefixText: '₹ ',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InteractiveCard(
                      onTap: () async {
                        final price = double.tryParse(controller.text) ?? 0;
                        if (price > 0) {
                          await transaction.recordSale(
                            userId: item.merchantId,
                            userName: item.merchantName,
                            productId: item.productId,
                            productName: item.productName,
                            quantity: item.quantity,
                            unit: item.unit,
                            pricePerUnit: price,
                            notes: 'Sold from inventory',
                          );
                          await inventory.markAsSold(item.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.tertiary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('CONFIRM SALE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.water_drop;
      case 'flowers':
        return Icons.local_florist;
      default:
        return Icons.eco;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isInStock;
  final double quantity;
  final String unit;
  const _StatusBadge(
      {required this.isInStock, required this.quantity, required this.unit});

  @override
  Widget build(BuildContext context) {
    final color = isInStock ? C.primary : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(isInStock ? 'STOCK' : 'SOLD',
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1)),
          Text(quantity.toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _StatTile(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? C.primary : C.onSurface;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              highlight ? color.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: highlight ? color : Colors.grey.shade500,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }
}
