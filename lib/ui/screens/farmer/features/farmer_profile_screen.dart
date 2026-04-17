import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../core/utils/url_utils.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: C.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 2026 Premium Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF0d631b),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  // If we can't pop, we are likely in a tab. 
                  // In which case the PopScope on FarmerScreen will handle system back,
                  // but for a UI button we can't easily reach FarmerScreen state without a provider.
                  // However, clicking back should at least try to go back.
                  Navigator.of(context).maybePop();
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0d631b), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Abstract glass shapes
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'profile_pic',
                          child: InteractiveCard(
                            scaleFactor: 0.9,
                            onTap: () {},
                            child: GlassContainer(
                              width: 110,
                              height: 110,
                              borderRadius: BorderRadius.circular(55),
                              blur: 15,
                              opacity: 0.2,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2),
                              child: Center(
                                child: Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0].toUpperCase()
                                      : 'F',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'Farmer',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          borderRadius: BorderRadius.circular(20),
                          opacity: 0.15,
                          child: Text(
                            'PRO FARMER • ${user?.district ?? 'AGRIFLOW'}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (user?.isDeletionPending ?? false)
            SliverToBoxAdapter(
              child: _DeletionPendingBanner(
                hoursRemaining: user!.deletionHoursRemaining,
                onRevoke: () =>
                    context.read<AuthProvider>().cancelAccountDeletion(),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Grid
                  Row(
                    children: [
                      Expanded(
                        child: InteractiveCard(
                          scaleFactor: 0.95,
                          onTap: () =>
                              Navigator.pushNamed(context, '/profile_edit'),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white,
                            opacity: 0.8,
                            child: const Column(
                              children: [
                                Icon(Icons.edit_note_rounded,
                                    color: Color(0xFF0d631b), size: 32),
                                SizedBox(height: 8),
                                Text('Edit Profile',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFF0d631b))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InteractiveCard(
                          scaleFactor: 0.95,
                          onTap: () => _showLogoutDialog(context),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFFFEF2F2),
                            opacity: 0.8,
                            child: const Column(
                              children: [
                                Icon(Icons.power_settings_new_rounded,
                                    color: Colors.redAccent, size: 32),
                                SizedBox(height: 8),
                                Text('Logout',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Personal Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 16),

                  // Bento Grid Info
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    children: [
                      _BentoCard(
                          icon: Icons.alternate_email_rounded,
                          label: 'Email',
                          value: user?.email ?? '',
                          color: const Color(0xFF0d631b)),
                      _BentoCard(
                          icon: Icons.phone_android_rounded,
                          label: 'Phone',
                          value: user?.phone ?? 'Not set',
                          color: const Color(0xFF8b5cf6)),
                      _BentoCard(
                          icon: Icons.location_city_rounded,
                          label: 'District',
                          value: user?.district ?? '',
                          color: const Color(0xFF06b6d4)),
                      _BentoCard(
                          icon: Icons.landscape_rounded,
                          label: 'Taluk',
                          value: user?.taluk ?? 'Not set',
                          color: const Color(0xFFf59e0b)),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _FullWidthBentoCard(
                      icon: Icons.place_rounded,
                      label: 'Municipality',
                      value: user?.municipality ?? 'Not set',
                      color: const Color(0xFF10b981)),
                  const SizedBox(height: 12),
                  if (user?.address != null && user!.address!.isNotEmpty)
                    _FullWidthBentoCard(
                        icon: Icons.home_work_rounded,
                        label: 'Postal Address',
                        value: user.address!,
                        color: const Color(0xFF6366f1)),

                  const SizedBox(height: 32),
                  const Text('Help & Support',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _FullWidthBentoCard(
                    icon: Icons.support_agent_rounded,
                    label: 'Official Support Email',
                    value: 'ceo@websitescorp.com',
                    color: const Color(0xFF4338CA),
                    onTap: () => launchAppURL('mailto:ceo@websitescorp.com'),
                  ),
                  const SizedBox(height: 12),
                  _FullWidthBentoCard(
                    icon: Icons.star_rate_rounded,
                    label: 'Rate Agri-Flow',
                    value: 'Support our mission',
                    color: const Color(0xFFF59E0B),
                    onTap: () => launchAppURL('https://play.google.com/store/apps/details?id=com.agriflow'),
                  ),
                  const SizedBox(height: 12),
                  _FullWidthBentoCard(
                    icon: Icons.description_rounded,
                    label: 'Terms & Privacy',
                    value: 'Legal transparency',
                    color: const Color(0xFF64748B),
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                  ),

                  const SizedBox(height: 32),
                  const Text('Danger Zone',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: C.error,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _DangerZoneCard(
                    onTap: () => _showDeleteAccountDialog(context),
                  ),

                  const SizedBox(
                      height: 100), // Bottom padding for floating nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w900, color: C.error)),
        content: const Text(
          'Your account and all related data (products, orders, profile) will be permanently deleted after 48 hours. You can revoke this request anytime before the deadline.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context
                  .read<AuthProvider>()
                  .requestAccountDeletion();
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Account deletion scheduled in 48 hours.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request Deletion',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0d631b),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DangerZoneCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.error.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: C.error, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete Account',
                      style: TextStyle(
                          color: C.error,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Request permanent account removal',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DeletionPendingBanner extends StatelessWidget {
  final int hoursRemaining;
  final VoidCallback onRevoke;

  const _DeletionPendingBanner(
      {required this.hoursRemaining, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: C.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Account Deletion Pending (~$hoursRemaining hours left)',
                  style: const TextStyle(
                      color: C.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRevoke,
              style: ElevatedButton.styleFrom(
                backgroundColor: C.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('REVOKE REQUEST',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _BentoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: C.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _FullWidthBentoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _FullWidthBentoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: C.onSurface)),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}
