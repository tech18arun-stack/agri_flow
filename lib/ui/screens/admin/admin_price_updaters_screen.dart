import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models.dart';
import '../../../data/flower_models.dart';
import '../../../services/appwrite_service.dart';
import '../../../services/appwrite_config.dart';
import 'package:appwrite/appwrite.dart';

const _kFlowerPink = Color(0xFFdb2777);

class AdminPriceUpdatersScreen extends StatefulWidget {
  const AdminPriceUpdatersScreen({super.key});

  @override
  State<AdminPriceUpdatersScreen> createState() =>
      _AdminPriceUpdatersScreenState();
}

class _AdminPriceUpdatersScreenState
    extends State<AdminPriceUpdatersScreen> {
  List<UserModel> _updaters = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = AppwriteService.instance;
      if (!svc.isInitialized) await svc.init();
      final res = await svc.db.listDocuments(
        databaseId: svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('role', 'price_updater'),
          Query.orderDesc(r'$createdAt'),
          Query.limit(100),
        ],
      );
      _updaters = res.documents.map((doc) {
        return UserModel(
          id: doc.$id,
          name: doc.data['name'] ?? '',
          email: doc.data['email'] ?? '',
          role: UserRole.priceUpdater,
          district: doc.data['district'] ?? '',
          status: doc.data['status'] ?? 'active',
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to load price updaters: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: _kFlowerPink,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Price Updater',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _kFlowerPink))
          : Column(
              children: [
                _buildHeader(),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: C.errorContainer,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!,
                        style: const TextStyle(color: C.error)),
                  ),
                Expanded(
                  child: _updaters.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kFlowerPink, Color(0xFF7c3aed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.manage_accounts,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Updater Accounts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                Text(
                  '${_updaters.length} accounts · Only admin can create these',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kFlowerPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🌸', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Price Updaters Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create accounts for your price handling team.\nThey will log in at farmer.websitescorp.com\nand land directly on the Flower Price Dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Create First Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kFlowerPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final active = _updaters.where((u) => u.status == 'active').length;
    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: _kFlowerPink.withValues(alpha: 0.05),
          child: Row(
            children: [
              _StatChip(label: 'Total', value: '${_updaters.length}', color: _kFlowerPink),
              const SizedBox(width: 12),
              _StatChip(label: 'Active', value: '$active', color: Colors.green),
              const SizedBox(width: 12),
              _StatChip(label: 'Inactive', value: '${_updaters.length - active}', color: Colors.grey),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: _updaters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _UpdaterCard(
                user: _updaters[index],
                onToggleStatus: (user) => _toggleStatus(user),
                onDelete: (user) => _confirmDelete(context, user),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _toggleStatus(UserModel user) async {
    final newStatus = user.status == 'active' ? 'inactive' : 'active';
    try {
      final svc = AppwriteService.instance;
      await svc.db.updateDocument(
        databaseId: svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.id,
        data: {'status': newStatus},
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update status: $e'),
              backgroundColor: C.error),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
            'Delete price updater account for ${user.name}?\nThis cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: C.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final svc = AppwriteService.instance;
        await svc.db.deleteDocument(
          databaseId: svc.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: user.id,
        );
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreatePriceUpdaterDialog(onCreated: _load),
    );
  }
}

// ==================== CREATE DIALOG ====================

class _CreatePriceUpdaterDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreatePriceUpdaterDialog({required this.onCreated});

  @override
  State<_CreatePriceUpdaterDialog> createState() =>
      _CreatePriceUpdaterDialogState();
}

class _CreatePriceUpdaterDialogState
    extends State<_CreatePriceUpdaterDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedDistrict = 'Madurai';
  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.length < 8) {
      setState(() => _error =
          'Name, email, and a minimum 8-character password are required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = AppwriteService.instance;
      if (!svc.isInitialized) await svc.init();

      // 1. Create Appwrite auth account (doesn't create a session)
      final account = await svc.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // 2. Create users collection document
      await svc.db.createDocument(
        databaseId: svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: account.$id,
        data: {
          'userId': account.$id,
          'name': name,
          'email': email,
          'role': 'price_updater',
          'district': _selectedDistrict,
          'taluk': '',
          'municipality': '',
          'profileImage': '',
          'status': 'active',
        },
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Price updater account created for $name'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().contains('user_already_exists')
            ? 'An account with this email already exists'
            : 'Failed to create account: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Text('🌸', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Text('Create Price Updater',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This account will have access ONLY to the Flower Price Dashboard. They cannot access the admin panel or mobile app.',
                style: TextStyle(fontSize: 13, color: C.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password * (min 8 characters)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'Assigned District',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: TamilNaduDistricts.names
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedDistrict = v ?? 'Madurai'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: C.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: C.error, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _loading ? null : _create,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.person_add, size: 16),
          label: const Text('Create Account'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kFlowerPink,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ==================== UPDATER CARD ====================

class _UpdaterCard extends StatelessWidget {
  final UserModel user;
  final ValueChanged<UserModel> onToggleStatus;
  final ValueChanged<UserModel> onDelete;

  const _UpdaterCard({
    required this.user,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? _kFlowerPink.withValues(alpha: 0.2)
              : C.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: isActive
                ? _kFlowerPink.withValues(alpha: 0.15)
                : C.surfaceContainerHighest,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
              style: TextStyle(
                  color: isActive ? _kFlowerPink : C.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                Text(user.email,
                    style: const TextStyle(
                        fontSize: 12, color: C.onSurfaceVariant)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (user.district.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kFlowerPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(user.district,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _kFlowerPink)),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Switch(
                value: isActive,
                activeColor: _kFlowerPink,
                onChanged: (_) => onToggleStatus(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: C.error, size: 20),
                tooltip: 'Delete account',
                onPressed: () => onDelete(user),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: color, fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: C.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
