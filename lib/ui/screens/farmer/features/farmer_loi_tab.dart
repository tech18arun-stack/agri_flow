import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';

class FarmerLOITab extends StatefulWidget {
  const FarmerLOITab({super.key});

  @override
  State<FarmerLOITab> createState() => _FarmerLOITabState();
}

class _FarmerLOITabState extends State<FarmerLOITab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<LOIProvider>().fetchFarmerRequests(auth.user?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final lois = context.watch<LOIProvider>().farmerRequests;
    final loading = context.watch<LOIProvider>().isLoading;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            C.secondary.withValues(alpha: 0.05),
            Colors.white,
            C.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : lois.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: lois.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _LOICard(loi: lois[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: C.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_outlined,
                  size: 48, color: C.secondary),
            ),
            const SizedBox(height: 24),
            Text(
              'No LOI Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: C.textHeader,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Letters of Intent from wholesale merchants will appear here for your review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: C.textSub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LOICard extends StatelessWidget {
  final LOIRequestModel loi;
  const _LOICard({required this.loi});

  @override
  Widget build(BuildContext context) {
    final isPending = loi.status.toLowerCase() == 'pending';

    return InteractiveCard(
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loi.merchantName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: C.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wholesale Merchant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: C.textSub,
                      ),
                    ),
                  ],
                ),
                _StatusBadge(status: loi.status),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Requested Product',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: C.textSub,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loi.productName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: C.textHeader,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Volume Required',
                    value: '${loi.quantity.toStringAsFixed(0)} ${loi.unit}',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    label: 'Merchant Offer',
                    value: '₹${loi.priceOffer.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                    isPrice: true,
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _respond(context, 'rejected'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: const Text('Decline Request',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: C.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _respond(context, 'accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Accept Offer',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.access_time,
                    size: 12, color: C.textSub.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  'Issued ${_formatDate(loi.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: C.textSub.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _respond(BuildContext context, String status) async {
    try {
      await context.read<LOIProvider>().updateStatus(loi.id, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Contract ${status[0].toUpperCase() + status.substring(1)} Successfully'),
            backgroundColor: status == 'accepted' ? C.primary : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Action Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrice;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: C.textSub),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: C.textSub,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isPrice ? C.primary : C.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
