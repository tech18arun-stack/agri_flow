import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../core/utils/url_utils.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _LuxuryProfileAppBar(user: user),
          
          if (user?.isDeletionPending ?? false)
            SliverToBoxAdapter(
              child: _DeletionPendingBanner(
                hoursRemaining: user!.deletionHoursRemaining,
                onRevoke: () => context.read<AuthProvider>().cancelAccountDeletion(),
              ),
            ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? screenWidth * 0.1 : 20,
              vertical: 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileHeaderCard(user: user),
                const SizedBox(height: 32),
                
                _QuickAccessGrid(isDesktop: isDesktop),
                const SizedBox(height: 32),

                const _SectionTitle(title: 'PERSONAL INFORMATION'),
                const SizedBox(height: 16),
                _InfoTile(icon: Icons.person_outline_rounded, label: 'Full Legal Name', value: user?.name ?? 'Customer'),
                _InfoTile(icon: Icons.phone_iphone_rounded, label: 'Contact Number', value: user?.phone ?? 'Not set'),
                _InfoTile(icon: Icons.location_on_outlined, label: 'Primary District', value: user?.district ?? 'Not set'),
                _InfoTile(icon: Icons.home_work_outlined, label: 'Primary Address', value: user?.address ?? 'Not set'),
                
                const SizedBox(height: 32),
                const _SectionTitle(title: 'PREFERENCES & SUPPORT'),
                const SizedBox(height: 16),
                _InfoTile(
                  icon: Icons.support_agent_rounded, 
                  label: 'Official Support', 
                  value: 'ceo@websitescorp.com',
                  onTap: () => launchAppURL('mailto:ceo@websitescorp.com'),
                ),
                _InfoTile(
                  icon: Icons.description_rounded, 
                  label: 'Terms & Privacy', 
                  value: 'View Legal Documentation',
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                
                const SizedBox(height: 48),
                _DangerZone(
                  onLogout: () => _showLogoutDialog(context),
                  onDelete: () => _showDeleteAccountDialog(context),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LuxuryConfirmDialog(
        title: 'TERMINATE SESSION',
        message: 'Are you sure you want to logout from FarmFlow?',
        confirmLabel: 'LOGOUT',
        isDanger: true,
        onConfirm: () {
          context.read<AuthProvider>().logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LuxuryConfirmDialog(
        title: 'ACCOUNT DELETION',
        message: 'Your account and all related data will be permanently deleted after a 48-hour grace period.',
        confirmLabel: 'REQUEST DELETION',
        isDanger: true,
        onConfirm: () async {
          final success = await context.read<AuthProvider>().requestAccountDeletion();
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deletion scheduled (48h grace period)')),
            );
          }
        },
      ),
    );
  }
}

class _LuxuryProfileAppBar extends StatelessWidget {
  final dynamic user;
  const _LuxuryProfileAppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF14532D), size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text('FARMFLOW PROFILE', 
        style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.white.withValues(alpha: 0.2), BlendMode.srcOver),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final dynamic user;
  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)]),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: const Color(0xFF14532D).withValues(alpha: 0.1), blurRadius: 20)],
                ),
                child: Center(
                  child: Text(
                    user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : 'F',
                    style: const TextStyle(color: Color(0xFF14532D), fontSize: 40, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF14532D), shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user?.name ?? 'Valued Customer',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.8),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Connect your email',
            style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          _ProfileQuickAction(
            label: 'EDIT ACCOUNT',
            icon: Icons.edit_note_rounded,
            onTap: () => Navigator.pushNamed(context, '/profile_edit'),
          ),
        ],
      ),
    );
  }
}

class _ProfileQuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ProfileQuickAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF14532D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF14532D).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  final bool isDesktop;
  const _QuickAccessGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _QuickCard(icon: Icons.shopping_bag_rounded, label: 'My Orders', onTap: () => Navigator.pushNamed(context, '/orders'), color: const Color(0xFF14532D)),
        _QuickCard(icon: Icons.favorite_rounded, label: 'Wishlist', onTap: () => Navigator.pushNamed(context, '/wishlist'), color: const Color(0xFFEF4444)),
        _QuickCard(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () => Navigator.pushNamed(context, '/notifications'), color: const Color(0xFFF59E0B)),
        _QuickCard(icon: Icons.support_agent_rounded, label: 'Help Center', onTap: () => launchAppURL('mailto:support@farmflow.com'), color: const Color(0xFF3B82F6)),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _QuickCard({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF4B5563))),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF), letterSpacing: 1.5)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoTile({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InteractiveCard(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: const Color(0xFF14532D), size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD1D5DB), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDelete;
  const _DangerZone({required this.onLogout, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InteractiveCard(
          onTap: onLogout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('LOGOUT FROM SESSION', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        InteractiveCard(
          onTap: onDelete,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('TERMINATE PERMANENTLY', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LuxuryConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDanger;

  const _LuxuryConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDanger ? Colors.red : Colors.green).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isDanger ? Icons.warning_rounded : Icons.info_rounded, color: isDanger ? Colors.red : Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InteractiveCard(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDanger ? Colors.red : const Color(0xFF14532D),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: (isDanger ? Colors.red : const Color(0xFF14532D)).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletionPendingBanner extends StatelessWidget {
  final int hoursRemaining;
  final VoidCallback onRevoke;

  const _DeletionPendingBanner({required this.hoursRemaining, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.red, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELETION PENDING', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('Permanent deletion in ~$hoursRemaining hours', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InteractiveCard(
            onTap: onRevoke,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('REVOKE REQUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
