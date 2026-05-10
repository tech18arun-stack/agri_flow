import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/shared_widgets.dart';

class AdminPushNotificationScreen extends StatefulWidget {
  const AdminPushNotificationScreen({super.key});

  @override
  State<AdminPushNotificationScreen> createState() => _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState extends State<AdminPushNotificationScreen> with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _selectedType = 'system';
  String _selectedRole = 'all';
  bool _sending = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please define both title and core message'), backgroundColor: C.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final users = context.read<AdminProvider>().users;
      final notifProvider = context.read<NotificationProvider>();
      
      final targetUsers = _selectedRole == 'all'
          ? users
          : users.where((u) => u.role.toString().split('.').last == _selectedRole).toList();

      if (targetUsers.isEmpty) {
        throw 'No recipients found for the selected audience';
      }

      int sent = 0;
      for (final user in targetUsers) {
        final success = await notifProvider.create(
          userId: user.id,
          role: user.role.toString().split('.').last,
          title: _titleCtrl.text,
          message: _messageCtrl.text,
          type: _selectedType,
        );
        if (success) sent++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broadcast completed: $sent signals transmitted'),
            backgroundColor: C.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _titleCtrl.clear();
        _messageCtrl.clear();
        setState(() {
          _selectedType = 'system';
          _selectedRole = 'all';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transmission failed: $e'), backgroundColor: C.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);
    final pad = adaptivePadding(context);

    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: pad,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildComposerGrid(web),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Broadcasting Center',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: C.onSurface, letterSpacing: -1),
                ),
                const SizedBox(width: 12),
                ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: C.primary, blurRadius: 10)])),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Transmit critical system updates and platform announcements',
              style: TextStyle(fontSize: 13, color: C.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposerGrid(bool web) {
    return Column(
      children: [
        if (web)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildFormPanel()),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildPreviewPanel()),
            ],
          )
        else
          Column(
            children: [
              _buildFormPanel(),
              const SizedBox(height: 24),
              _buildPreviewPanel(),
            ],
          ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('SIGNAL TYPE'),
          const SizedBox(height: 12),
          _buildTypeSelector(),
          const SizedBox(height: 32),
          _buildLabel('TARGET AUDIENCE'),
          const SizedBox(height: 12),
          _buildAudienceSelector(),
          const SizedBox(height: 32),
          _buildLabel('MESSAGE PAYLOAD'),
          const SizedBox(height: 12),
          _buildTextField(_titleCtrl, 'Broadcast Title', Icons.title_rounded, max: 100),
          const SizedBox(height: 16),
          _buildTextField(_messageCtrl, 'Core Transmission Message', Icons.message_rounded, lines: 6, max: 500),
          const SizedBox(height: 32),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('TRANSMISSION PREVIEW'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: C.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: C.outlineVariant.withValues(alpha: 0.2), style: BorderStyle.none),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: C.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(_getTypeIcon(_selectedType), color: C.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_titleCtrl.text.isEmpty ? 'Signal Title' : _titleCtrl.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_messageCtrl.text.isEmpty ? 'Enter your message content to see a preview of how it will appear to users on their mobile devices.' : _messageCtrl.text, 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.groups_rounded, 'Recipients', _selectedRole.toUpperCase()),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.layers_rounded, 'Category', _selectedType.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: C.onSurfaceVariant, letterSpacing: 1));
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _BroadChip(label: 'System', icon: Icons.settings_suggest_rounded, selected: _selectedType == 'system', onTap: () => setState(() => _selectedType = 'system')),
        _BroadChip(label: 'Orders', icon: Icons.shopping_bag_rounded, selected: _selectedType == 'order', onTap: () => setState(() => _selectedType = 'order')),
        _BroadChip(label: 'Marketing', icon: Icons.local_offer_rounded, selected: _selectedType == 'promotion', onTap: () => setState(() => _selectedType = 'promotion')),
      ],
    );
  }

  Widget _buildAudienceSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _BroadChip(label: 'Everyone', icon: Icons.public_rounded, selected: _selectedRole == 'all', onTap: () => setState(() => _selectedRole = 'all')),
        _BroadChip(label: 'Farmers', icon: Icons.eco_rounded, selected: _selectedRole == 'farmer', onTap: () => setState(() => _selectedRole = 'farmer')),
        _BroadChip(label: 'Merchants', icon: Icons.store_rounded, selected: _selectedRole == 'merchant', onTap: () => setState(() => _selectedRole = 'merchant')),
        _BroadChip(label: 'Logistics', icon: Icons.local_shipping_rounded, selected: _selectedRole == 'customer', onTap: () => setState(() => _selectedRole = 'customer')),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {int lines = 1, int? max}) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      maxLength: max,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: C.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: C.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: C.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton.icon(
        onPressed: _sending ? null : _sendNotification,
        icon: _sending
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(_sending ? 'SIGNAL TRANSMITTING...' : 'INITIATE BROADCAST', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: C.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: C.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: C.primary, letterSpacing: 1)),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'order': return Icons.shopping_bag_rounded;
      case 'promotion': return Icons.local_offer_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}

class _BroadChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BroadChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? C.primary : C.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? C.primary : C.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : C.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : C.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
