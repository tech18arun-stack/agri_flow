import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../../../core/constants/colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _doLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter credentials')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (success && mounted) {
      if (auth.role != UserRole.admin) {
        await auth.logout();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: Not an Admin')));
      } else {
        // Pop the admin login screen so the _Router's admin portal is visible
        Navigator.of(context).pop();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Login Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 700;
    final formMaxWidth = isWideScreen ? 450.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: C.surface,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? screenWidth * 0.15 : 20,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: formMaxWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isWideScreen ? 80 : 64,
                        height: isWideScreen ? 80 : 64,
                        decoration: const BoxDecoration(
                          color: C.primary,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: C.onPrimary,
                          size: isWideScreen ? 40 : 32,
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 32 : 24),
                      Text(
                        'Admin Portal',
                        style: TextStyle(
                          fontSize: isWideScreen ? 28 : 24,
                          fontWeight: FontWeight.w800,
                          color: C.onSurface,
                        ),
                      ),
                      Text(
                        'அட்மின் போர்டல்',
                        style: TextStyle(
                          fontSize: isWideScreen ? 16 : 14,
                          color: C.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 48 : 40),

                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: C.surfaceContainerLow,
                          label: const Text('Admin Email'),
                          prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: C.surfaceContainerLow,
                          label: const Text('Password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 40 : 32),

                      if (auth.loading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: isWideScreen ? 56 : 50,
                          child: ElevatedButton(
                            onPressed: _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.primary,
                              foregroundColor: C.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isWideScreen ? 14 : 12),
                              ),
                            ),
                            child: Text(
                              'Login to Dashboard',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isWideScreen ? 16 : 14,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: isWideScreen ? 40 : 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
