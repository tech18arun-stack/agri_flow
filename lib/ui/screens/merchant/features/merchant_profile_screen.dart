import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../core/utils/url_utils.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: C.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: C.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: C.onSurface),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('Profile', 
              style: TextStyle(color: C.onSurface, fontWeight: FontWeight.w900)),
          ),
          // Deletion Pending Banner
          if (user?.isDeletionPending ?? false)
            SliverToBoxAdapter(
              child: _DeletionPendingBanner(
                hoursRemaining: user!.deletionHoursRemaining,
                onRevoke: () =>
                    context.read<AuthProvider>().cancelAccountDeletion(),
              ),
            ),

          // Glass Profile Header
          SliverToBoxAdapter(
            child: GlassContainer(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              padding: const EdgeInsets.all(32),
              blur: 25,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(32),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: C.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: C.primary.withValues(alpha: 0.2),
                              width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: C.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'M',
                            style: const TextStyle(
                                color: C.primary,
                                fontSize: 44,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color(0xFF0D631B), shape: BoxShape.circle),
                        child: const Icon(Icons.verified_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user?.name ?? 'Merchant',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: C.onSurface,
                        letterSpacing: -0.8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: C.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileQuickStat(
                          label: 'ACCOUNT TYPE',
                          value: user?.role
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase() ??
                              'MERCHANT'),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: C.outlineVariant.withValues(alpha: 0.3),
                      ),
                      _ProfileQuickStat(
                          label: 'REGION', value: user?.district ?? 'KERALA'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Profile Actions & Info
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                InteractiveCard(
                  onTap: () => Navigator.pushNamed(context, '/profile_edit'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: C.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: C.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('EDIT PROFILE DETAILS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text('SECURITY & IDENTITY',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 2)),
                ),
                _ProfileInfoRowModern(
                    icon: Icons.person_outline_rounded,
                    label: 'Full Legal Name',
                    value: user?.name ?? ''),
                _ProfileInfoRowModern(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Contact Number',
                    value: user?.phone ?? 'Not set'),
                _ProfileInfoRowModern(
                    icon: Icons.location_on_outlined,
                    label: 'Primary District',
                    value: user?.district ?? ''),
                _ProfileInfoRowModern(
                    icon: Icons.map_outlined,
                    label: 'Operational Taluk',
                    value: user?.taluk ?? 'Not set'),
                _ProfileInfoRowModern(
                    icon: Icons.home_work_outlined,
                    label: 'Municipality',
                    value: user?.municipality ?? 'Not set'),
                if (user?.address != null && user!.address!.isNotEmpty)
                  _ProfileInfoRowModern(
                      icon: Icons.place_outlined,
                      label: 'Facility Address',
                      value: user.address!),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text('HELP & SUPPORT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: C.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 2)),
                ),
                _ProfileInfoRowModern(
                  icon: Icons.support_agent_rounded,
                  label: 'Official Support Email',
                  value: 'ceo@websitescorp.com',
                  onTap: () => launchAppURL('mailto:ceo@websitescorp.com'),
                ),
                _ProfileInfoRowModern(
                  icon: Icons.star_rate_rounded,
                  label: 'Rate Farm Flow',
                  value: 'Support our mission',
                  onTap: () => launchAppURL('https://play.google.com/store/apps/details?id=com.Farm Flow'),
                ),
                _ProfileInfoRowModern(
                  icon: Icons.description_rounded,
                  label: 'Terms & Privacy',
                  value: 'Legal transparency',
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                const SizedBox(height: 32),
                InteractiveCard(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: C.onSurface.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: C.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 12),
                        Text('TERMINATE SESSION',
                            style: TextStyle(
                                color: C.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InteractiveCard(
                  onTap: () => _showDeleteAccountDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: C.error.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_rounded, color: C.error),
                        SizedBox(width: 12),
                        Text('DELETE ACCOUNT',
                            style: TextStyle(
                                color: C.error,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Height for Bottom Nav Bar
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.logout_rounded, color: C.error, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('TERMINATE SESSION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text('Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: C.onSurface.withValues(alpha: 0.6))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InteractiveCard(
                      onTap: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.error,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: C.error.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text('LOGOUT',
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: C.error, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('ACCOUNT DELETION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text('Process Deletion in 48 Hours?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: C.onSurface)),
              const SizedBox(height: 12),
              Text(
                'Your account and all related data (orders, profile, listings) will be permanently deleted after a 48-hour grace period.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: C.onSurface.withValues(alpha: 0.6),
                    height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: C.onSurface.withValues(alpha: 0.6))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InteractiveCard(
                      onTap: () async {
                        final success = await context
                            .read<AuthProvider>()
                            .requestAccountDeletion();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Account deletion scheduled (48h grace period)')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.error,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: C.error.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text('REQUEST DELETION',
                              textAlign: TextAlign.center,
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
}

class _DeletionPendingBanner extends StatelessWidget {
  final int hoursRemaining;
  final VoidCallback onRevoke;

  const _DeletionPendingBanner(
      {required this.hoursRemaining, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      color: C.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: C.error.withValues(alpha: 0.2)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: C.error, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELETION PENDING',
                        style: TextStyle(
                            color: C.error,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('Auto-deletion in ~$hoursRemaining hours',
                        style: TextStyle(
                            color: C.error.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InteractiveCard(
            onTap: onRevoke,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: C.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('REVOKE DELETION REQUEST',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileQuickStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileQuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: C.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: C.onSurface)),
      ],
    );
  }
}

class _ProfileInfoRowModern extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ProfileInfoRowModern(
      {required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InteractiveCard(
        onTap: onTap ?? () {},
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          opacity: 0.05,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: C.primary, size: 22),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: C.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: C.onSurface)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: C.onSurface.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
