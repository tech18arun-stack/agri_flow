import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> _allOrders = [];
  bool _loading = false;
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (!context.mounted) return;
      final provider = context.read<OrderProvider>();
      // Load all orders by fetching without filters
      await provider.loadFarmerOrders('all');

      // Get orders from multiple farmers (admin view)
      if (!context.mounted) return;
      final products = context.read<ProductProvider>().all;
      final farmerIds = products.map((p) => p.farmerId).toSet();

      List<OrderModel> allOrders = [];
      for (final farmerId in farmerIds) {
        await provider.loadFarmerOrders(farmerId);
        allOrders.addAll(provider.orders);
      }
      
      // Remove duplicates
      final seen = <String>{};
      _allOrders = allOrders.where((o) => seen.add(o.id)).toList();
      
      _allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<OrderModel> get _filteredOrders {
    var orders = _allOrders;
    
    if (_filterStatus != 'all') {
      orders = orders.where((o) => o.status == _filterStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
        o.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        o.farmerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        o.id.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return orders;
  }

  Map<String, int> get _statusCounts {
    final counts = <String, int>{
      'pending': 0,
      'confirmed': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0,
    };
    
    for (final order in _allOrders) {
      if (counts.containsKey(order.status)) {
        counts[order.status] = counts[order.status]! + 1;
      }
    }
    
    return counts;
  }

  double get _totalRevenue {
    return _allOrders
        .where((o) => o.status != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: C.surfaceContainerLowest,
            child: Column(
              children: [
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.shopping_bag,
                      label: 'Total Orders',
                      value: _allOrders.length.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.currency_rupee,
                      label: 'Total Revenue',
                      value: '₹${_totalRevenue.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip('All', _filterStatus == 'all', () => setState(() => _filterStatus = 'all')),
                      const SizedBox(width: 8),
                      _FilterChip('Pending (${_statusCounts['pending']})', _filterStatus == 'pending', () => setState(() => _filterStatus = 'pending')),
                      const SizedBox(width: 8),
                      _FilterChip('Confirmed (${_statusCounts['confirmed']})', _filterStatus == 'confirmed', () => setState(() => _filterStatus = 'confirmed')),
                      const SizedBox(width: 8),
                      _FilterChip('Shipped (${_statusCounts['shipped']})', _filterStatus == 'shipped', () => setState(() => _filterStatus = 'shipped')),
                      const SizedBox(width: 8),
                      _FilterChip('Delivered (${_statusCounts['delivered']})', _filterStatus == 'delivered', () => setState(() => _filterStatus = 'delivered')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Search Bar
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by customer, farmer, or order ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: C.surfaceContainerHigh,
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No orders found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _OrderCard(
                            order: _filteredOrders[index],
                            onStatusUpdate: () => _loadOrders(),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? C.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusUpdate;

  const _OrderCard({required this.order, required this.onStatusUpdate});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Customer: ${order.customerName}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const Icon(Icons.agriculture, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Farmer: ${order.farmerName}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: C.primary),
              ),
              PopupMenuButton<String>(
                onSelected: (status) async {
                  final provider = context.read<OrderProvider>();
                  await provider.updateOrderStatus(order.id, status);
                  if (!context.mounted) return;
                  onStatusUpdate();

                  // Send notification
                  final notifService = context.read<NotificationProvider>();
                  await notifService.sendOrderNotification(
                    userId: order.customerId,
                    role: 'customer',
                    orderId: order.id,
                    status: status,
                  );
                },
                itemBuilder: (context) => [
                  if (order.status != 'confirmed')
                    const PopupMenuItem(value: 'confirmed', child: Text('Mark Confirmed')),
                  if (order.status != 'shipped')
                    const PopupMenuItem(value: 'shipped', child: Text('Mark Shipped')),
                  if (order.status != 'delivered')
                    const PopupMenuItem(value: 'delivered', child: Text('Mark Delivered')),
                  if (order.status != 'cancelled')
                    const PopupMenuItem(value: 'cancelled', child: Text('Cancel Order')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
