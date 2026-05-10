import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/models.dart';
import '../../../widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with SingleTickerProviderStateMixin {
  List<OrderModel> _allOrders = [];
  bool _loading = false;
  String _filterStatus = 'all';
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (!mounted) return;
      final provider = context.read<OrderProvider>();
      await provider.loadFarmerOrders('all');

      if (!mounted) return;
      final products = context.read<ProductProvider>().all;
      final farmerIds = products.map((p) => p.farmerId).toSet();

      List<OrderModel> allOrders = [];
      for (final farmerId in farmerIds) {
        if (!mounted) return;
        await provider.loadFarmerOrders(farmerId);
        if (!mounted) return;
        allOrders.addAll(provider.orders);
      }
      
      final seen = <String>{};
      _allOrders = allOrders.where((o) => seen.add(o.id)).toList();
      _allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _animationController.forward(from: 0);
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<OrderModel> get _filteredOrders {
    var orders = _allOrders;
    if (_filterStatus != 'all') {
      orders = orders.where((o) => o.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      orders = orders.where((o) =>
        o.customerName.toLowerCase().contains(query) ||
        o.farmerName.toLowerCase().contains(query) ||
        o.id.toLowerCase().contains(query)
      ).toList();
    }
    return orders;
  }

  Map<String, int> get _statusCounts {
    final counts = {'pending': 0, 'confirmed': 0, 'shipped': 0, 'delivered': 0, 'cancelled': 0};
    for (final order in _allOrders) {
      if (counts.containsKey(order.status)) {
        counts[order.status] = counts[order.status]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);
    
    return Scaffold(
      backgroundColor: C.background,
      body: Column(
        children: [
          _buildTopPanel(context, web),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: C.primary))
                : _buildOrderList(web),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel(BuildContext context, bool web) {
    final revenue = _allOrders
        .where((o) => o.status != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.total);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: C.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BiLabel(
                en: L.orders,
                ta: L.ordersTa,
                enSize: web ? 28 : 20,
                enWeight: FontWeight.w900,
              ),
              _buildRefreshButton(),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsRow(revenue, web),
          const SizedBox(height: 20),
          _buildSearchAndFilter(web),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary, size: 20),
        onPressed: _loadOrders,
        tooltip: 'Refresh Orders',
      ),
    );
  }

  Widget _buildStatsRow(double revenue, bool web) {
    return Row(
      children: [
        Expanded(
          child: _HeaderStatCard(
            label: 'Active Pipeline',
            value: '${_allOrders.where((o) => !['delivered', 'cancelled'].contains(o.status)).length}',
            icon: Icons.inventory_2_rounded,
            color: C.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HeaderStatCard(
            label: 'Total Realized',
            value: '₹${(revenue/1000).toStringAsFixed(1)}k',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(bool web) {
    return Column(
      children: [
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search operations...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: C.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _StatusChip(label: 'All Operations', count: _allOrders.length, isSelected: _filterStatus == 'all', color: C.primary, onTap: () => setState(() => _filterStatus = 'all')),
              const SizedBox(width: 10),
              _StatusChip(label: 'Pending', count: _statusCounts['pending']!, isSelected: _filterStatus == 'pending', color: Colors.orange, onTap: () => setState(() => _filterStatus = 'pending')),
              const SizedBox(width: 10),
              _StatusChip(label: 'Confirmed', count: _statusCounts['confirmed']!, isSelected: _filterStatus == 'confirmed', color: Colors.blue, onTap: () => setState(() => _filterStatus = 'confirmed')),
              const SizedBox(width: 10),
              _StatusChip(label: 'Shipped', count: _statusCounts['shipped']!, isSelected: _filterStatus == 'shipped', color: Colors.purple, onTap: () => setState(() => _filterStatus = 'shipped')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList(bool web) {
    final orders = _filteredOrders;
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: C.surfaceContainerLow, shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded, size: 48, color: C.onSurfaceVariant.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 16),
            const Text('Zero operations found', style: TextStyle(fontWeight: FontWeight.w700, color: C.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final order = orders[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.05;
            final anim = CurvedAnimation(
              parent: _animationController,
              curve: Interval(delay.clamp(0.0, 1.0), (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
            );
            return Transform.translate(
              offset: Offset(0, 20 * (1 - anim.value)),
              child: Opacity(opacity: anim.value, child: child),
            );
          },
          child: _OrderControlCard(
            order: order,
            onStatusUpdate: _loadOrders,
          ),
        );
      },
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _HeaderStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.onSurfaceVariant.withValues(alpha: 0.7))),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _StatusChip({required this.label, required this.count, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : color)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isSelected ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('$count', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderControlCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusUpdate;
  const _OrderControlCard({required this.order, required this.onStatusUpdate});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
              ),
              Text(DateFormat('MMM dd • HH:mm').format(order.createdAt), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.onSurfaceVariant.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Text('ID: ${order.id.toUpperCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.onSurface)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_rounded, 'Source', order.customerName),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.agriculture_rounded, 'Provider', order.farmerName),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: -1)),
              _buildUpdateAction(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: C.onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.onSurface)),
      ],
    );
  }

  Widget _buildUpdateAction(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Modify Status',
      onSelected: (status) async {
        final provider = context.read<OrderProvider>();
        await provider.updateOrderStatus(order.id, status, order.customerId);
        onStatusUpdate();
        
        if (!context.mounted) return;
        context.read<NotificationProvider>().sendOrderNotification(
          userId: order.customerId,
          role: 'customer',
          orderId: order.id,
          status: status,
        );
      },
      itemBuilder: (context) => [
        _buildPopupItem('pending', 'Set Pending', Icons.hourglass_empty_rounded, Colors.orange),
        _buildPopupItem('confirmed', 'Confirm Order', Icons.check_circle_rounded, Colors.blue),
        _buildPopupItem('shipped', 'Mark Shipped', Icons.local_shipping_rounded, Colors.purple),
        _buildPopupItem('delivered', 'Finish Order', Icons.verified_rounded, Colors.green),
        _buildPopupItem('cancelled', 'Void Order', Icons.cancel_rounded, Colors.red),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: C.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: C.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_road_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String text, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
