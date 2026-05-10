import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models.dart';
import '../../../data/flower_models.dart';
import '../../../services/appwrite_service.dart';
import '../../../services/appwrite_config.dart';
import '../../../widgets/shared_widgets.dart';
import 'package:appwrite/appwrite.dart';

const _kFlowerPink = Color(0xFFdb2777);

class AdminPriceUpdatersScreen extends StatefulWidget {
  const AdminPriceUpdatersScreen({super.key});

  @override
  State<AdminPriceUpdatersScreen> createState() =>
      _AdminPriceUpdatersScreenState();
}

class _AdminPriceUpdatersScreenState
    extends State<AdminPriceUpdatersScreen> with SingleTickerProviderStateMixin {
  List<UserModel> _updaters = [];
  bool _loading = false;
  String? _error;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
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
      _listController.reset();
      _listController.forward();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to load price updaters: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);
    final pad = adaptivePadding(context);

    return Scaffold(
      backgroundColor: C.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: _kFlowerPink,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('New Price Updater', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
      ),
      body: _loading && _updaters.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _kFlowerPink))
          : SingleChildScrollView(
              padding: pad,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(web),
                   const SizedBox(height: 32),
                   if (_error != null) _buildErrorMessage(),
                   if (_updaters.isEmpty && !_loading) 
                     _buildEmptyState()
                   else 
                     _buildList(web),
                   const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.errorContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: C.error.withValues(alpha: 0.2))),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: C.error),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: C.error, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildHeader(bool web) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personnel Registry',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Text(
              'Managing specialized price update accounts for market monitoring',
              style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: _kFlowerPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kFlowerPink.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: _kFlowerPink, size: 20),
        onPressed: _load,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: _kFlowerPink.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: const Icon(Icons.manage_accounts_rounded, size: 64, color: _kFlowerPink),
            ),
            const SizedBox(height: 24),
            const Text('Registry Vacant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'No specialized update accounts have been registered yet.\nCreate an account to delegate market pricing tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.onSurfaceVariant.withValues(alpha: 0.6), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool web) {
    final activeCount = _updaters.where((u) => u.status == 'active').length;
    return Column(
      children: [
        Row(
          children: [
            _PremiumStatChip(label: 'Total Roster', value: '${_updaters.length}', color: _kFlowerPink),
            const SizedBox(width: 12),
            _PremiumStatChip(label: 'Active Duty', value: '$activeCount', color: C.primary),
          ],
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _updaters.length,
          itemBuilder: (context, index) {
            final u = _updaters[index];
            return AnimatedBuilder(
              animation: _listController,
              builder: (context, child) {
                final delay = index * 0.05;
                final ani = CurvedAnimation(
                  parent: _listController,
                  curve: Interval(delay.clamp(0, 1), (delay + 0.4).clamp(0, 1), curve: Curves.easeOutQuart),
                );
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - ani.value)),
                  child: Opacity(opacity: ani.value, child: child),
                );
              },
              child: _PremiumUpdaterCard(
                user: u,
                onToggleStatus: (u) => _toggleStatus(u),
                onDelete: (u) => _confirmDelete(context, u),
              ),
            );
          },
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status update failed: $e'), backgroundColor: C.error));
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: C.surfaceContainerLowest,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Revoke Credentials?', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text('Are you certain you wish to permanently remove ${user.name} from the roster? This action is irreversible.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: C.onSurfaceVariant, fontWeight: FontWeight.w700))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: C.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Revoke Permanently'),
            ),
          ],
        ),
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
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Decommission failed: $e')));
      }
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: _CreatePriceUpdaterDialog(onCreated: _load),
      ),
    );
  }
}

class _PremiumStatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PremiumStatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.onSurfaceVariant.withValues(alpha: 0.6), letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _CreatePriceUpdaterDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreatePriceUpdaterDialog({required this.onCreated});

  @override
  State<_CreatePriceUpdaterDialog> createState() => _CreatePriceUpdaterDialogState();
}

class _CreatePriceUpdaterDialogState extends State<_CreatePriceUpdaterDialog> {
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
      setState(() => _error = 'Please provide full name, valid email, and 8+ char password');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final svc = AppwriteService.instance;
      final account = await svc.account.create(userId: ID.unique(), email: email, password: password, name: name);
      await svc.db.createDocument(
        databaseId: svc.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: account.$id,
        data: {'userId': account.$id, 'name': name, 'email': email, 'role': 'price_updater', 'district': _selectedDistrict, 'status': 'active'},
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credentials provisioned successfully'), backgroundColor: C.primary, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString().contains('user_already_exists') ? 'Identity already exists in system' : 'Failed to provision credentials: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: C.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: const Text('Provision Personnel', style: TextStyle(fontWeight: FontWeight.w900)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialized market monitoring account for authorized personnel only.', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6), height: 1.5)),
              const SizedBox(height: 24),
              _buildLabel('FULL NAME'),
              _buildField(_nameCtrl, 'e.g. Arumugam Nadar', Icons.person_outline_rounded),
              _buildLabel('ENTERPRISE EMAIL'),
              _buildField(_emailCtrl, 'personnel@Farm Flow.com', Icons.alternate_email_rounded, type: TextInputType.emailAddress),
              _buildLabel('SECURITY CREDENTIAL (PASSWORD)'),
              _buildField(_passwordCtrl, '••••••••', Icons.lock_outline_rounded, obscure: !_showPassword, suffix: IconButton(icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20), onPressed: () => setState(() => _showPassword = !_showPassword))),
              _buildLabel('ASSIGNED JURISDICTION'),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                decoration: InputDecoration(filled: true, fillColor: C.surfaceContainerLow, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
                items: TamilNaduDistricts.names.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                onChanged: (v) => setState(() => _selectedDistrict = v ?? 'Madurai'),
              ),
              if (_error != null) _buildErrorMessage(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Abort', style: TextStyle(color: C.onSurfaceVariant, fontWeight: FontWeight.w800))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _kFlowerPink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: _loading ? null : _create,
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Provision Account'),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
     return Padding(padding: const EdgeInsets.only(bottom: 8, left: 4, top: 12), child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1)));
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false, Widget? suffix, TextInputType? type}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: C.onSurfaceVariant.withValues(alpha: 0.5)),
        suffixIcon: suffix,
        filled: true,
        fillColor: C.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.error.withValues(alpha: 0.2))),
      child: Text(_error!, style: const TextStyle(color: C.error, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _PremiumUpdaterCard extends StatelessWidget {
  final UserModel user;
  final ValueChanged<UserModel> onToggleStatus;
  final ValueChanged<UserModel> onDelete;
  const _PremiumUpdaterCard({required this.user, required this.onToggleStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final active = user.status == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: active ? _kFlowerPink.withValues(alpha: 0.1) : C.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: active ? _kFlowerPink.withValues(alpha: 0.05) : C.surfaceContainerLow,
            child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: TextStyle(color: active ? _kFlowerPink : C.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                Text(user.email, style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _IconInfoPill(icon: Icons.location_on_rounded, label: user.district, color: _kFlowerPink),
                    const SizedBox(width: 8),
                    _StatusPill(active: active),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(value: active, activeThumbColor: _kFlowerPink, onChanged: (_) => onToggleStatus(user)),
              IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: C.error, size: 20), onPressed: () => onDelete(user)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _IconInfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;
  const _StatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? C.primary : C.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(active ? 'ACTIVE' : 'STANDBY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
