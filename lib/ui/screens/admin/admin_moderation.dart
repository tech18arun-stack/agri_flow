import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../providers/providers.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingProducts();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = adaptivePadding(context);
    final web = isWeb(context);
    final adminProv = context.watch<AdminProvider>();
    final products = adminProv.pendingProducts;

    if (adminProv.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: C.primary));
    }

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: pad,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, adminProv, web),
            const SizedBox(height: 24),

            // Summary Bento
            _buildSummaryBento(adminProv, web),
            const SizedBox(height: 32),

            Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                const Text('Awaiting Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: C.onSurface)),
              ],
            ),
            const SizedBox(height: 16),

            if (products.isEmpty)
              const EmptyStateWidget(icon: Icons.verified_user_rounded, title: 'Compliance Complete', subtitle: 'All recently submitted listings have been audited.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final delay = i * 0.1;
                      final ani = CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(delay.clamp(0, 1), (delay + 0.4).clamp(0, 1), curve: Curves.easeOutQuart),
                      );
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - ani.value)),
                        child: Opacity(opacity: ani.value, child: child),
                      );
                    },
                    child: _buildModerationCard(context, adminProv, p),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminProvider adminProv, bool web) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BiLabel(
              en: L.productModeration,
              ta: L.productModerationTa,
              enSize: web ? 28 : 20,
              enWeight: FontWeight.w900,
            ),
            const SizedBox(height: 4),
            Text(
              'Enforcing ecosystem standards and quality assurance',
              style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ),
        _buildRefreshButton(adminProv),
      ],
    );
  }

  Widget _buildRefreshButton(AdminProvider adminProv) {
    return Container(
      decoration: BoxDecoration(
        color: C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.primary.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: C.primary, size: 20),
        onPressed: () => adminProv.loadPendingProducts(),
      ),
    );
  }

  Widget _buildSummaryBento(AdminProvider adminProv, bool web) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cols = web ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: web ? 2.8 : 3.8,
          children: [
            _PremiumSummaryCard(
              value: adminProv.moderationQueue.toString(),
              label: 'In Verification',
              icon: Icons.safety_check_rounded,
              color: C.primary,
            ),
            _PremiumSummaryCard(
              value: 'Active',
              label: 'Guard AI Status',
              icon: Icons.security_rounded,
              color: C.tertiary,
              trend: 'Optimal',
            ),
            _PremiumSummaryCard(
              value: '0',
              label: 'Reported Items',
              icon: Icons.gpp_maybe_rounded,
              color: Colors.orange,
              trend: 'Safe',
            ),
          ],
        );
      },
    );
  }

  Widget _buildModerationCard(BuildContext context, AdminProvider adminProv, dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: C.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.primary.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: C.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiLabel(en: p.name, ta: p.nameTa, enSize: 16, enWeight: FontWeight.w800),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted by ${p.farmerName}',
                      style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 8),
                    _buildMetaTag(p.category.toUpperCase(), C.primary),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${p.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -0.5)),
                  Text('per ${p.unit}', style: TextStyle(fontSize: 10, color: C.onSurfaceVariant.withValues(alpha: 0.5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModerationButton(
                  label: 'Deny Submission',
                  color: Colors.red,
                  icon: Icons.block_rounded,
                  onPressed: () => adminProv.updateProductStatus(p.id, 'rejected'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildModerationButton(
                  label: 'Approve & Release',
                  color: C.primary,
                  icon: Icons.verified_rounded,
                  isFilled: true,
                  onPressed: () => adminProv.updateProductStatus(p.id, 'active'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildModerationButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    bool isFilled = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isFilled ? color : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: isFilled ? 0 : 0.2)),
        boxShadow: isFilled ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isFilled ? Colors.white : color, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isFilled ? Colors.white : color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSummaryCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final String? trend;
  const _PremiumSummaryCard({required this.value, required this.label, required this.icon, required this.color, this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: color),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(trend!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }
}

