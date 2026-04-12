import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart' as aw;
import '../../../providers/providers.dart';
import '../../../services/location_service.dart';
import '../../../data/models.dart';
import '../../../core/constants/strings.dart';
import '../../../widgets/shared_widgets.dart';
import 'dart:ui';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.farmer;
  bool _showTamil = false;
  List<aw.Document> _districts = [];
  List<aw.Document> _talukas = [];
  List<aw.Document> _municipalities = [];

  String? _selectedDistrict;
  String? _selectedTaluk;
  String? _selectedMunicipality;

  bool _loadingLocations = false;
  bool _registering = false;

  late AnimationController _animCtrl;
  Animation<double>? _fadeHeader;
  Animation<Offset>? _slideHeader;
  Animation<double>? _fadeForm;
  Animation<double>? _fadeLocations;

  bool get _isFormValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _confirmPassCtrl.text.isNotEmpty &&
      _passCtrl.text == _confirmPassCtrl.text &&
      _selectedDistrict != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeHeader = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _slideHeader =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _fadeForm = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _fadeLocations = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _animCtrl.forward();
    _loadDistricts();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    if (!mounted) return;
    setState(() => _loadingLocations = true);
    try {
      _districts = await LocationService.instance.getDistricts();
      if (mounted && _districts.isNotEmpty) {
        setState(() {
          _selectedDistrict = _districts.first.data['name'];
        });
        await _loadTalukas(_selectedDistrict!);
      }
    } catch (e) {
      debugPrint('Failed to load districts: $e');
    } finally {
      if (mounted) setState(() => _loadingLocations = false);
    }
  }

  Future<void> _loadTalukas(String district) async {
    if (!mounted) return;
    setState(() {
      _talukas = [];
      _selectedTaluk = null;
      _municipalities = [];
      _selectedMunicipality = null;
    });
    try {
      _talukas = await LocationService.instance.getTalukas(district);
      if (mounted && _talukas.isNotEmpty) {
        setState(() => _selectedTaluk = _talukas.first.data['name']);
        await _loadMunicipalities(district, taluk: _selectedTaluk);
      } else if (mounted) {
        await _loadMunicipalities(district);
      }
    } catch (e) {
      debugPrint('Failed to load talukas: $e');
    }
  }

  Future<void> _loadMunicipalities(String district, {String? taluk}) async {
    if (!mounted) return;
    setState(() {
      _municipalities = [];
      _selectedMunicipality = null;
    });
    try {
      _municipalities = await LocationService.instance
          .getMunicipalities(district, taluk: taluk);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to load municipalities: $e');
    }
  }

  void _onDistrictChanged(String? district) {
    if (district != null && district != _selectedDistrict && mounted) {
      _selectedDistrict = district;
      _loadTalukas(district);
    }
  }

  void _onTalukChanged(String? taluk) {
    if (taluk != null &&
        taluk != _selectedTaluk &&
        _selectedDistrict != null &&
        mounted) {
      _selectedTaluk = taluk;
      _loadMunicipalities(_selectedDistrict!, taluk: taluk);
    }
  }

  void _doRegister() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your district')));
      return;
    }
    if (!mounted) return;
    setState(() => _registering = true);

    final success = await context.read<AuthProvider>().register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          name: _nameCtrl.text.trim(),
          role: _selectedRole,
          district: _selectedDistrict!,
          taluk: _selectedTaluk ?? '',
          municipality: _selectedMunicipality ?? '',
        );

    if (!mounted) return;
    setState(() => _registering = false);

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      final auth = context.read<AuthProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        // Top bar
                        Row(
                          mainAxisAlignment: isWideScreen
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isWideScreen)
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            InteractiveCard(
                              scaleFactor: 0.9,
                              onTap: () =>
                                  setState(() => _showTamil = !_showTamil),
                              child: GlassContainer(
                                blur: 15,
                                opacity: 0.2,
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
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
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                                Text(
                                  'Create Account',
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
                                      ? 'புதிய கணக்கை உருவாக்க விவரங்களை உள்ளிடுங்கள்'
                                      : 'Join our agricultural community today.',
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

                        // Role selector and form fields
                        FadeTransition(
                          opacity: _fadeForm ?? kAlwaysCompleteAnimation,
                          child: Column(
                            crossAxisAlignment: isWideScreen
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showTamil ? 'நான் ஒரு' : 'I am a',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.9)),
                              ),
                              const SizedBox(height: 12),
                              _RoleSelectorModern(
                                selectedRole: _selectedRole,
                                showTamil: _showTamil,
                                onRoleSelected: (role) =>
                                    setState(() => _selectedRole = role),
                              ),
                              const SizedBox(height: 32),
                              _buildTextField(
                                  _nameCtrl,
                                  _showTamil ? 'பெயர்' : 'Full Name',
                                  _showTamil
                                      ? 'உங்கள் முழு பெயர்'
                                      : 'Enter your full name'),
                              const SizedBox(height: 12),
                              _buildTextField(
                                  _emailCtrl,
                                  'Email',
                                  _showTamil
                                      ? 'மின்னஞ்சல் முகவரி'
                                      : 'Email address',
                                  keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              _buildTextField(
                                  _passCtrl,
                                  _showTamil ? 'கடவுச்சொல்' : 'Password',
                                  _showTamil
                                      ? 'கடவுச்சொல்லை உள்ளிடுங்கள்'
                                      : 'Enter password',
                                  obscureText: true),
                              const SizedBox(height: 12),
                              _buildTextField(
                                  _confirmPassCtrl,
                                  _showTamil
                                      ? 'கடவுச்சொல்லை உறுதிப்படுத்தவும்'
                                      : 'Confirm Password',
                                  _showTamil
                                      ? 'கடவுச்சொல்லை மீண்டும் உள்ளிடுங்கள்'
                                      : 'Re-enter password',
                                  obscureText: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        FadeTransition(
                          opacity: _fadeLocations ?? kAlwaysCompleteAnimation,
                          child: Column(
                            crossAxisAlignment: isWideScreen
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showTamil
                                    ? 'உங்கள் இருப்பிடம்'
                                    : 'Your Location',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _showTamil
                                    ? 'உங்கள் மாவட்டம், வட்டம் மற்றும் நகராட்சியை தேர்ந்தெடுக்கவும்'
                                    : 'Select your district, taluk, and municipality',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.6)),
                              ),
                              const SizedBox(height: 20),
                              if (_loadingLocations)
                                const Center(child: CircularProgressIndicator())
                              else ...[
                                _buildDropdown(
                                    'District',
                                    'மாவட்டம்',
                                    _selectedDistrict,
                                    _districts
                                        .map<DropdownMenuItem<String>>((d) {
                                      final name = d.data['name'] as String;
                                      final nameTa = d.data['nameTa'] as String;
                                      return DropdownMenuItem<String>(
                                          value: name,
                                          child:
                                              Text(_showTamil ? nameTa : name));
                                    }).toList(),
                                    _onDistrictChanged),
                                const SizedBox(height: 12),
                                _buildDropdown(
                                    'Taluk',
                                    'வட்டம்',
                                    _talukas.isEmpty ? null : _selectedTaluk,
                                    _talukas.map<DropdownMenuItem<String>>((t) {
                                      final name = t.data['name'] as String;
                                      final nameTa = t.data['nameTa'] as String;
                                      return DropdownMenuItem<String>(
                                          value: name,
                                          child:
                                              Text(_showTamil ? nameTa : name));
                                    }).toList(),
                                    _onTalukChanged),
                                const SizedBox(height: 12),
                                _buildDropdown(
                                    'Municipality',
                                    'நகராட்சி',
                                    _municipalities.isEmpty
                                        ? null
                                        : _selectedMunicipality,
                                    _municipalities
                                        .map<DropdownMenuItem<String>>((m) {
                                      final name = m.data['name'] as String;
                                      final nameTa = m.data['nameTa'] as String;
                                      return DropdownMenuItem<String>(
                                          value: name,
                                          child:
                                              Text(_showTamil ? nameTa : name));
                                    }).toList(),
                                    (v) => setState(
                                        () => _selectedMunicipality = v)),
                                const SizedBox(height: 32),
                              ],
                              if (_registering)
                                const Center(child: CircularProgressIndicator())
                              else
                                InteractiveCard(
                                  scaleFactor: _isFormValid ? 0.96 : 1.0,
                                  onTap: _isFormValid ? _doRegister : () {},
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
                                      onPressed:
                                          _isFormValid ? _doRegister : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(999)),
                                      ),
                                      child: Text(
                                        _showTamil
                                            ? 'கணக்கை உருவாக்குங்கள்'
                                            : 'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: _isFormValid
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _showTamil
                                          ? 'ஏற்கனவே கணக்கு உள்ளதா? '
                                          : 'Already have an account? ',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize: isWideScreen ? 14 : 13),
                                      children: [
                                        TextSpan(
                                          text: _showTamil
                                              ? 'உள்நுழையுங்கள்'
                                              : 'Sign In',
                                          style: const TextStyle(
                                              color: Color(0xFF16A34A),
                                              fontWeight: FontWeight.w700),
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

  Widget _buildTextField(
      TextEditingController ctrl, String label, String hintText,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return GlassContainer(
      blur: 15,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: ctrl,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5), width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String labelTa, String? value,
      List<DropdownMenuItem<String>> items, void Function(String?) onChanged) {
    // Deduplicate items by value to prevent Flutter assertion errors
    final seen = <String>{};
    final uniqueItems = <DropdownMenuItem<String>>[];
    for (final item in items) {
      if (item.value != null && !seen.contains(item.value)) {
        seen.add(item.value!);
        uniqueItems.add(item);
      }
    }

    // If value doesn't match any unique item, use first item's value
    String? safeValue = value;
    if (value != null && !seen.contains(value) && uniqueItems.isNotEmpty) {
      safeValue = uniqueItems.first.value;
    }

    return GlassContainer(
      blur: 15,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(16),
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        dropdownColor: const Color(0xFF202020),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        iconEnabledColor: Colors.white,
        decoration: InputDecoration(
            label: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: BiLabel(en: label, ta: labelTa, enSize: 13)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none)),
        items: uniqueItems,
        onChanged: onChanged,
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
        child: Container(
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
