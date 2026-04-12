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

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = adaptivePadding(context);
    final web = isWeb(context);
    final adminProv = context.watch<AdminProvider>();
    final users = adminProv.users;
    
    final statusColors = {'active': C.primary, 'pending': Colors.orange, 'suspended': C.error};

    if (adminProv.loading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiLabel(en: L.userManagement, ta: L.userManagementTa, enSize: web ? 22 : 18, enWeight: FontWeight.w800),
                    Text('${users.length} users found', style: const TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => adminProv.loadUsers(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters - Placeholder for now
          if (web)
            Wrap(
              spacing: 12,
              children: [
                _FilterDropdown(label: 'All Roles', items: ['All Roles', 'Farmer', 'Merchant', 'Customer']),
                _FilterDropdown(label: 'All Statuses', items: ['All Statuses', 'Active', 'Pending', 'Suspended']),
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterDropdown(label: 'All Roles', items: ['All Roles', 'Farmer', 'Merchant', 'Customer']),
                  const SizedBox(width: 8),
                  _FilterDropdown(label: 'All Statuses', items: ['All Statuses', 'Active', 'Pending', 'Suspended']),
                ],
              ),
            ),
          const SizedBox(height: 16),

          if (users.isEmpty)
            const EmptyStateWidget(icon: Icons.people_outline, title: 'No users found', subtitle: 'பயனர்கள் இல்லை')
          else
            web ? _WebTable(users: users, statusColors: statusColors) : _MobileList(users: users, statusColors: statusColors),
        ],
      ),
    );
  }
}

class _WebTable extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, Color> statusColors;
  const _WebTable({required this.users, required this.statusColors});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(C.surfaceContainerLow),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          columns: const [
            DataColumn(label: Text('User / பயனர்', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Role / பங்கு', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('District', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Status / நிலை', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
          ],
          rows: users.map((u) {
            final color = statusColors[u.status.toLowerCase()] ?? C.onSurfaceVariant;
            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: C.primary.withOpacity(0.1), child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 14))),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)), 
                        Text(u.email, style: const TextStyle(fontSize: 11, color: C.onSurfaceVariant))
                      ]
                    ),
                  ],
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: C.primaryFixedDim.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(u.role.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.primary)),
                )),
                DataCell(Text(u.district)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), 
                    const SizedBox(width: 4), 
                    Text(u.status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11))
                  ],
                )),
                DataCell(
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      context.read<AdminProvider>().updateUserStatus(u.id, val);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'active', child: Text('Set Active')),
                      const PopupMenuItem(value: 'suspended', child: Text('Suspend')),
                    ],
                    child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.primary)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, Color> statusColors;
  const _MobileList({required this.users, required this.statusColors});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = users[i];
        final color = statusColors[u.status.toLowerCase()] ?? C.onSurfaceVariant;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: C.primary.withOpacity(0.1),
              child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
            ),
            title: Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            subtitle: Text(u.email, style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: C.primaryFixedDim.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(u.role.name.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.primary)),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: u.status.toUpperCase(), color: color),
              ],
            ),
            onTap: () {
               // Show action sheet for mobile
               _showUserActions(context, u);
            },
          ),
        );
      },
    );
  }

  void _showUserActions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.green),
            title: const Text('Mark Active'),
            onTap: () {
              context.read<AdminProvider>().updateUserStatus(user.id, 'active');
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Suspend User'),
            onTap: () {
              context.read<AdminProvider>().updateUserStatus(user.id, 'suspended');
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  const _FilterDropdown({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        initialValue: label,
        isExpanded: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          filled: true,
          fillColor: C.surfaceContainerHighest,
        ),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 11)))).toList(),
        onChanged: (_) {},
      ),
    );
  }
}

