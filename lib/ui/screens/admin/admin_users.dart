import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = adaptivePadding(context);
    final web = isWeb(context);
    final adminProv = context.watch<AdminProvider>();
    final users = adminProv.users;
    
    final statusColors = {'active': C.primary, 'pending': Colors.orange, 'suspended': Colors.red};

    if (adminProv.loading && users.isEmpty) {
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
            _buildHeader(adminProv, users.length, web),
            const SizedBox(height: 24),

            // Directory Filters
            _buildFilters(web),
            const SizedBox(height: 24),

            if (users.isEmpty)
               const EmptyStateWidget(icon: Icons.group_off_rounded, title: 'Registry Empty', subtitle: 'No users match your current directory filters.')
            else
               AnimatedBuilder(
                 animation: _listController,
                 builder: (context, child) => FadeTransition(opacity: _listController, child: child),
                 child: web 
                   ? _WebRegistryTable(users: users, statusColors: statusColors) 
                   : _MobileRegistryList(users: users, statusColors: statusColors),
               ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdminProvider adminProv, int count, bool web) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BiLabel(en: L.userManagement, ta: L.userManagementTa, enSize: web ? 28 : 20, enWeight: FontWeight.w900),
            const SizedBox(height: 4),
            Text('$count verified entities in registry', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
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
        onPressed: () => adminProv.loadUsers(),
      ),
    );
  }

  Widget _buildFilters(bool web) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search directory...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: C.surfaceContainerLowest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterTag(label: 'All Roles', isSelected: true, icon: Icons.filter_list_rounded),
              const SizedBox(width: 8),
              _FilterTag(label: 'Farmers', isSelected: false),
              const SizedBox(width: 8),
              _FilterTag(label: 'Merchants', isSelected: false),
              const SizedBox(width: 8),
              _FilterTag(label: 'Suspended', isSelected: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _WebRegistryTable extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, Color> statusColors;
  const _WebRegistryTable({required this.users, required this.statusColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(C.surfaceContainerLow.withValues(alpha: 0.5)),
        dataRowMinHeight: 70,
        dataRowMaxHeight: 90,
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('IDENTIFIER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
          DataColumn(label: Text('CLASSIFICATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
          DataColumn(label: Text('REGION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
          DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
          DataColumn(label: Text('OPERATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1))),
        ],
        rows: users.map((u) {
          final color = statusColors[u.status.toLowerCase()] ?? C.onSurfaceVariant;
          return DataRow(
            cells: [
              DataCell(Row(
                children: [
                  CircleAvatar(
                    radius: 18, 
                    backgroundColor: C.primary.withValues(alpha: 0.1), 
                    child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: 13))
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), 
                      Text(u.email, style: TextStyle(fontSize: 11, color: C.onSurfaceVariant.withValues(alpha: 0.6)))
                    ]
                  ),
                ],
              )),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                child: Text(u.role.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 0.5)),
              )),
              DataCell(Text(u.district, style: const TextStyle(fontSize: 13))),
              DataCell(_StatusPill(status: u.status, color: color)),
              DataCell(
                PopupMenuButton<String>(
                  onSelected: (val) => context.read<AdminProvider>().updateUserStatus(u.id, val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'active', child: Text('Grant Access', style: TextStyle(fontSize: 13))),
                    const PopupMenuItem(value: 'suspended', child: Text('Revoke Access', style: TextStyle(fontSize: 13, color: Colors.red))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.more_vert_rounded, size: 18),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MobileRegistryList extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, Color> statusColors;
  const _MobileRegistryList({required this.users, required this.statusColors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        final color = statusColors[u.status.toLowerCase()] ?? C.onSurfaceVariant;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: C.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: C.primary.withValues(alpha: 0.1),
              child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800)),
            ),
            title: Text(u.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.role.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 0.5)),
                Text(u.district, style: TextStyle(fontSize: 11, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
              ],
            ),
            trailing: _StatusPill(status: u.status, color: color),
            onTap: () => _showUserActions(context, u),
          ),
        );
      },
    );
  }

  void _showUserActions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Manage ${user.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            _ActionButton(
              label: 'Activate Account',
              icon: Icons.check_circle_rounded,
              color: C.primary,
              onTap: () {
                context.read<AdminProvider>().updateUserStatus(user.id, 'active');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Suspend Access',
              icon: Icons.block_rounded,
              color: Colors.red,
              onTap: () {
                context.read<AdminProvider>().updateUserStatus(user.id, 'suspended');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  const _FilterTag({required this.label, required this.isSelected, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? C.primary : C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? C.primary : C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: isSelected ? Colors.white : C.primary), const SizedBox(width: 8)],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : C.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

