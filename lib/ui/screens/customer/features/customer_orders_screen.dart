import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/order_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<OrderProvider>().loadCustomerOrders(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().customerOrders;
    final loading = context.watch<OrderProvider>().loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          _SliverOrderHeader(),
          if (loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF14532D))),
            )
          else if (orders.isEmpty)
            SliverFillRemaining(child: _EmptyOrders())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent >= 900 ? 2 : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 240,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _PremiumOrderCard(order: orders[index]),
                      childCount: orders.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverOrderHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 76,
      leading: Center(
        child: InteractiveCard(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 76, bottom: 16),
        centerTitle: false,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            Text('TRACK YOUR PREMIUM PURCHASES', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF6B7280))),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
      ),
    );
  }
}

class _PremiumOrderCard extends StatelessWidget {
  final OrderModel order;
  const _PremiumOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _OrderThumb(order: order),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORDER #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                      Text(_formatDate(order.createdAt).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SOURCE FARM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(order.farmerName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL PAID', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('₹${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TrackBtn(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int m) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[m - 1];
  }
}

class _OrderThumb extends StatelessWidget {
  final OrderModel order;
  const _OrderThumb({required this.order});

  @override
  Widget build(BuildContext context) {
    final hasImg = order.items.isNotEmpty && order.items.first.productImageUrl.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: hasImg
            ? CachedNetworkImage(imageUrl: order.items.first.productImageUrl, fit: BoxFit.cover)
            : const Icon(Icons.receipt_long_rounded, color: Color(0xFFD1D5DB), size: 20),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _TrackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('VIEW DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF4B5563), letterSpacing: 0.5)),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF4B5563)),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 80, color: Color(0xFF14532D)),
          ),
          const SizedBox(height: 32),
          const Text('No Orders Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 12),
          const Text('Your farm-to-table journey hasn\'t started yet.', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('EXPLORE MARKET', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
