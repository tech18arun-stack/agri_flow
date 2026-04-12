import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';

class AdminPushNotificationScreen extends StatefulWidget {
  const AdminPushNotificationScreen({super.key});

  @override
  State<AdminPushNotificationScreen> createState() => _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState extends State<AdminPushNotificationScreen> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _selectedType = 'system';
  String _selectedRole = 'all';
  bool _sending = false;

  Future<void> _sendNotification() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and message'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final users = context.read<AdminProvider>().users;
      final notifProvider = context.read<NotificationProvider>();
      
      // Filter users by role
      final targetUsers = _selectedRole == 'all'
          ? users
          : users.where((u) => u.role.toString().split('.').last == _selectedRole).toList();

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
            content: Text('✅ Sent to $sent users'),
            backgroundColor: Colors.green,
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [C.primary, C.primaryContainer]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Push Notification Composer',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Send notifications to all users or filter by role',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form
            const Text('Notification Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLength: 100,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLength: 500,
            ),

            const SizedBox(height: 16),

            // Type Selector
            const Text('Notification Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _TypeChip('System', Icons.notifications, _selectedType == 'system', () => setState(() => _selectedType = 'system')),
                _TypeChip('Order', Icons.shopping_bag, _selectedType == 'order', () => setState(() => _selectedType = 'order')),
                _TypeChip('Promotion', Icons.local_offer, _selectedType == 'promotion', () => setState(() => _selectedType = 'promotion')),
              ],
            ),

            const SizedBox(height: 16),

            // Role Selector
            const Text('Target Audience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _RoleChip('All Users', 'all', _selectedRole == 'all', () => setState(() => _selectedRole = 'all')),
                _RoleChip('Farmers', 'farmer', _selectedRole == 'farmer', () => setState(() => _selectedRole = 'farmer')),
                _RoleChip('Merchants', 'merchant', _selectedRole == 'merchant', () => setState(() => _selectedRole = 'merchant')),
                _RoleChip('Customers', 'customer', _selectedRole == 'customer', () => setState(() => _selectedRole = 'customer')),
              ],
            ),

            const SizedBox(height: 24),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _sendNotification,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_sending ? 'Sending...' : 'Send Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip(this.label, this.icon, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? C.primary : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip(this.label, this.role, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? C.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
