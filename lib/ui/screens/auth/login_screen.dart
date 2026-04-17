import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models.dart';
import '../../../core/constants/strings.dart';
import 'dart:ui';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.farmer;
  bool _showTamil = false;
  late AnimationController _animCtrl;
  Animation<double>? _fadeHeader;
  Animation<Offset>? _slideHeader;
  Animation<double>? _fadeForm;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeHeader = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _slideHeader =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _fadeForm = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.trim().isNotEmpty;

  void _doLogin() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    final success = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
        );
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(context.read<AuthProvider>().error ?? 'Login Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 700;
    final horizontalPadding = isWideScreen ? screenWidth * 0.15 : 20.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with heavy blur
          Image.asset(
            'assets/images/agri_bg.png',
            fit: BoxFit.cover,
          ),
          // Layered Glass Shapes
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 500 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: isWideScreen
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        // Top bar with language toggle
                        Row(
                          mainAxisAlignment: isWideScreen
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.end,
                          children: [
                            InteractiveCard(
                              scaleFactor: 0.9,
                              onTap: () =>
                                  setState(() => _showTamil = !_showTamil),
                              child: GlassContainer(
                                blur: 15,
                                opacity: 0.2,
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.language,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      _showTamil ? 'EN' : 'தமிழ்',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        FadeTransition(
                          opacity: _fadeHeader ?? kAlwaysCompleteAnimation,
                          child: SlideTransition(
                            position: _slideHeader ??
                                kAlwaysDismissedAnimation.drive(
                                  Tween<Offset>(
                                      begin: Offset.zero, end: Offset.zero),
                                ),
                            child: Column(
                              crossAxisAlignment: isWideScreen
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                // Logo
                                Row(
                                  mainAxisAlignment: isWideScreen
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.eco,
                                          color: Color(0xFF16A34A), size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Agri Flow',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // Welcome Text
                                Text(
                                  _showTamil ? 'வரவேற்போம்' : 'Welcome back',
                                  textAlign: isWideScreen
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 32 : 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _showTamil
                                      ? 'உங்கள் விளைச்சல்கள் மற்றும் ஆர்டர்களை நிர்வகிக்க உள்நுழையுங்கள்'
                                      : 'Sign in to manage your harvests and orders.',
                                  textAlign: isWideScreen
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 16 : 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Role Selector & Form
                        FadeTransition(
                          opacity: _fadeForm ?? kAlwaysCompleteAnimation,
                          child: Column(
                            crossAxisAlignment: isWideScreen
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showTamil
                                    ? 'உங்கள் பங்கைத் தேர்ந்தெடுக்கவும்'
                                    : 'Select your role',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _RoleSelectorModern(
                                selectedRole: _selectedRole,
                                showTamil: _showTamil,
                                onRoleSelected: (role) =>
                                    setState(() => _selectedRole = role),
                              ),
                              const SizedBox(height: 32),
                              // Email
                              GlassContainer(
                                blur: 15,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(16),
                                child: TextField(
                                  controller: _emailCtrl,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: _showTamil
                                        ? 'மொபைல் எண் அல்லது மின்னஞ்சல்'
                                        : 'Mobile Number or Email',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white
                                            .withValues(alpha: 0.6)),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Colors.white
                                              .withValues(alpha: 0.5),
                                          width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password
                              GlassContainer(
                                blur: 15,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(16),
                                child: TextField(
                                  controller: _passCtrl,
                                  onChanged: (_) => setState(() {}),
                                  obscureText: true,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText:
                                        _showTamil ? 'கடவுச்சொல்' : 'Password',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white
                                            .withValues(alpha: 0.6)),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Colors.white
                                              .withValues(alpha: 0.5),
                                          width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      _showForgotPasswordDialog(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _showTamil
                                        ? 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?'
                                        : 'Forgot Password?',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Sign In Button
                              if (auth.loading)
                                const Center(child: CircularProgressIndicator())
                              else
                                InteractiveCard(
                                  scaleFactor: _isFormValid ? 0.96 : 1.0,
                                  onTap: _isFormValid ? _doLogin : () {},
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: _isFormValid
                                          ? const LinearGradient(colors: [
                                              Color(0xFF16A34A),
                                              Color(0xFF15803D)
                                            ])
                                          : null,
                                      color: _isFormValid
                                          ? null
                                          : Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: _isFormValid
                                          ? [
                                              BoxShadow(
                                                  color: const Color(0xFF16A34A)
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4)),
                                            ]
                                          : [],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isFormValid ? _doLogin : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _showTamil
                                                ? 'உள்நுழையுங்கள்'
                                                : 'Sign In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: _isFormValid
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: _isFormValid
                                                ? Colors.white
                                                : Colors.white
                                                    .withValues(alpha: 0.3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Create Account Link
                              Center(
                                child: GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/register'),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _showTamil
                                          ? "கணக்கு இல்லையா? "
                                          : "Don't have an account? ",
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: isWideScreen ? 14 : 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _showTamil
                                              ? 'கணக்கை உருவாக்குங்கள்'
                                              : 'Create an account',
                                          style: const TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isWideScreen ? 40 : 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset_rounded,
                    color: Color(0xFF16A34A), size: 48),
                const SizedBox(height: 16),
                Text(
                  _showTamil ? 'கடவுச்சொல் மீட்பு' : 'Recover Password',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _showTamil
                      ? 'மீட்பு இணைப்பைப் பெற உங்கள் மின்னஞ்சலை உள்ளிடவும்'
                      : 'Enter your email to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  blur: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: emailCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _showTamil ? 'ரத்துசெய்' : 'CANCEL',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InteractiveCard(
                        onTap: () async {
                          final email = emailCtrl.text.trim();
                          if (email.isEmpty) return;

                          Navigator.pop(context);
                          final success = await context
                              .read<AuthProvider>()
                              .requestPasswordReset(email);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? (_showTamil
                                        ? 'மீட்பு மின்னஞ்சல் அனுப்பப்பட்டது'
                                        : 'Recovery email sent!')
                                    : (context.read<AuthProvider>().error ??
                                        'Error sending email')),
                                backgroundColor: success
                                    ? const Color(0xFF16A34A)
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _showTamil ? 'அனுப்பு' : 'SEND',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12),
                            ),
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
      ),
    );
  }
}

class _RoleSelectorModern extends StatelessWidget {
  final UserRole selectedRole;
  final bool showTamil;
  final Function(UserRole) onRoleSelected;

  const _RoleSelectorModern({
    required this.selectedRole,
    required this.showTamil,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 20,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            alignment: _getAlignment(),
            child: FractionallySizedBox(
              widthFactor: 0.33,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _RoleTab(
                label: showTamil ? L.farmerTa : L.farmer,
                icon: Icons.agriculture_outlined,
                isSelected: selectedRole == UserRole.farmer,
                onTap: () => onRoleSelected(UserRole.farmer),
              ),
              _RoleTab(
                label: showTamil ? L.customerTa : L.customer,
                icon: Icons.shopping_basket_outlined,
                isSelected: selectedRole == UserRole.customer,
                onTap: () => onRoleSelected(UserRole.customer),
              ),
              _RoleTab(
                label: showTamil ? L.merchantTa : L.merchant,
                icon: Icons.storefront_outlined,
                isSelected: selectedRole == UserRole.merchant,
                onTap: () => onRoleSelected(UserRole.merchant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Alignment _getAlignment() {
    switch (selectedRole) {
      case UserRole.farmer:
        return Alignment.centerLeft;
      case UserRole.customer:
        return Alignment.center;
      case UserRole.merchant:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
