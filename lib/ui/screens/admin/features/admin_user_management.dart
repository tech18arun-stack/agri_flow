import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../data/models.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    var users = admin.users;

    // Apply filters
    if (_searchQuery.isNotEmpty) {
      users = users.where((u) {
        final name = u.name.toLowerCase();
        final email = u.email.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    if (_roleFilter != 'all') {
      users = users.where((u) => u.role.toString().split('.').last == _roleFilter).toList();
    }

    if (_statusFilter != 'all') {
      users = users.where((u) => u.status == _statusFilter).toList();
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Header & Filters
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _FilterDropdown(
                      value: _roleFilter,
                      items: const [
                        ('all', 'All Roles'),
                        ('farmer', 'Farmers'),
                        ('merchant', 'Merchants'),
                        ('customer', 'Customers'),
                      ],
                      onChanged: (v) => setState(() => _roleFilter = v),
                    ),
                    const SizedBox(width: 12),
                    _FilterDropdown(
                      value: _statusFilter,
                      items: const [
                        ('all', 'All Status'),
                        ('active', 'Active'),
                        ('suspended', 'Suspended'),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${users.length} users found',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserCard(
                  user: user,
                  onStatusChange: (status) {
                    admin.updateUserStatus(user.id, status);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item.$1,
            child: Text(item.$2, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final ValueChanged<String> onStatusChange;

  const _UserCard({required this.user, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';
    final roleStr = user.role.toString().split('.').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(roleStr).withValues(alpha: 0.1),
            child: Icon(
              _getRoleIcon(roleStr),
              color: _getRoleColor(roleStr),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(roleStr).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleStr.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getRoleColor(roleStr),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.district.isNotEmpty ? user.district : 'No district',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onStatusChange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'active',
                child: Text('Activate'),
              ),
              const PopupMenuItem(
                value: 'suspended',
                child: Text('Suspend'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? 'Active' : 'Suspended',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'farmer':
        return const Color(0xFF4CAF50);
      case 'merchant':
        return const Color(0xFFFF9800);
      case 'customer':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'farmer':
        return Icons.agriculture;
      case 'merchant':
        return Icons.store;
      case 'customer':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }
}

