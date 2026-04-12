import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/interactive_card.dart';

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
              backgroundColor: Colors.redAccent,
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

  const _FullWidthBentoCard(
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
    );
  }
}
