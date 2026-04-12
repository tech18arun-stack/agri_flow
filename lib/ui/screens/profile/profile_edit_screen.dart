import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../services/location_service.dart';
import '../../../data/models.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  String? _selectedDistrict;
  String? _selectedTaluk;
  String? _selectedMunicipality;
  List<String> _districts = [];
  List<String> _talukas = [];
  List<String> _municipalities = [];
  bool _loadingLocations = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
    _selectedDistrict = user?.district;
    _selectedTaluk = user?.taluk;
    _selectedMunicipality = user?.municipality;
    _loadLocations();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final districts = await LocationService.instance.getDistricts();
      if (mounted) {
        setState(() {
          final uniqueDistricts =
              districts.map((d) => d.data['name'] as String).toSet().toList();

          final userDistrict = _selectedDistrict;
          if (userDistrict != null && !uniqueDistricts.contains(userDistrict)) {
            uniqueDistricts.add(userDistrict);
          }

          _districts = uniqueDistricts..sort();
          _loadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLocations = false);
      }
    }
  }

  Future<void> _loadTalukas(String district) async {
    setState(() => _loadingLocations = true);
    try {
      final talukas = await LocationService.instance.getTalukas(district);
      if (mounted) {
        setState(() {
          _talukas = talukas
              .map((t) => t.data['name'] as String)
              .toSet()
              .toList()
            ..sort();
          _selectedTaluk = null;
          _selectedMunicipality = null;
          _loadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _talukas = [];
          _loadingLocations = false;
        });
      }
    }
  }

  Future<void> _loadMunicipalities(String district, {String? taluk}) async {
    setState(() => _loadingLocations = true);
    try {
      final municipalities = await LocationService.instance.getMunicipalities(
        district,
        taluk: taluk,
      );
      if (mounted) {
        setState(() {
          _municipalities = municipalities
              .map((m) => m.data['name'] as String)
              .toSet()
              .toList()
            ..sort();
          _selectedMunicipality = null;
          _loadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _municipalities = [];
          _loadingLocations = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final success = await context.read<AuthProvider>().updateProfile(
          name: _nameCtrl.text.trim(),
          district: _selectedDistrict ?? '',
          taluk: _selectedTaluk ?? '',
          municipality: _selectedMunicipality ?? '',
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully'),
            backgroundColor: Color(0xFF0D631B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update: ${context.read<AuthProvider>().error}'),
            backgroundColor: C.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final role = user?.role ?? UserRole.customer;

    return Scaffold(
      backgroundColor: C.background,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: C.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: C.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Edit Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: C.onSurface)),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: _saving ? null : _saveProfile,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: C.primary))
                          : const Text('SAVE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: C.primary)),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          borderRadius: BorderRadius.circular(32),
                          opacity: 0.05,
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: C.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.displayName[0].toUpperCase() ??
                                            'U',
                                        style: const TextStyle(
                                          color: C.primary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: C.primary,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        size: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user?.displayName ?? 'User',
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: C.onSurface)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: C.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                          role
                                              .toString()
                                              .split('.')
                                              .last
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: C.primary)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        _sectionHeader('BASIC INFORMATION'),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _nameCtrl,
                          label: 'Full Legal Name',
                          hint: 'Enter your name',
                          icon: Icons.person_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),

                        _buildInputField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          hint: 'Email cannot be changed',
                          icon: Icons.alternate_email_rounded,
                          enabled: false,
                        ),

                        _buildInputField(
                          controller: _phoneCtrl,
                          label: 'Contact Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 32),

                        _sectionHeader('LOCATION DETAILS'),
                        const SizedBox(height: 16),

                        if (_loadingLocations)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(
                                      color: C.primary)))
                        else
                          Column(
                            children: [
                              _buildDropdownField(
                                label: 'District',
                                value: _selectedDistrict != null &&
                                        _districts.contains(_selectedDistrict)
                                    ? _selectedDistrict
                                    : null,
                                items: _districts,
                                icon: Icons.location_city_rounded,
                                onChanged: (value) {
                                  setState(() => _selectedDistrict = value);
                                  if (value != null) _loadTalukas(value);
                                },
                              ),
                              if (_talukas.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildDropdownField(
                                  label: 'Taluk',
                                  value: _selectedTaluk != null &&
                                          _talukas.contains(_selectedTaluk)
                                      ? _selectedTaluk
                                      : null,
                                  items: _talukas,
                                  icon: Icons.map_rounded,
                                  onChanged: (value) {
                                    setState(() => _selectedTaluk = value);
                                    if (value != null &&
                                        _selectedDistrict != null) {
                                      _loadMunicipalities(_selectedDistrict!,
                                          taluk: value);
                                    }
                                  },
                                ),
                              ],
                              if (_municipalities.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildDropdownField(
                                  label: 'Municipality',
                                  value: _selectedMunicipality != null &&
                                          _municipalities
                                              .contains(_selectedMunicipality)
                                      ? _selectedMunicipality
                                      : null,
                                  items: _municipalities,
                                  icon: Icons.home_work_rounded,
                                  onChanged: (value) => setState(
                                      () => _selectedMunicipality = value),
                                ),
                              ],
                            ],
                          ),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _addressCtrl,
                          label: 'Physical Address',
                          hint: 'Street, Building, Mark...',
                          icon: Icons.place_rounded,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 48),

                        InteractiveCard(
                          onTap: _saving ? null : _saveProfile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: C.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: C.primary.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 3))
                                  : const Text('UPDATE PROFILE',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          letterSpacing: 1.2)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: C.onSurface.withValues(alpha: 0.4),
              letterSpacing: 2)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color:
                  enabled ? Colors.white : C.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: C.onSurface),
              decoration: InputDecoration(
                prefixIcon: Icon(icon,
                    color: enabled ? C.primary : Colors.grey, size: 20),
                hintText: hint,
                hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.5), fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: C.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            icon: const Icon(Icons.expand_more_rounded, color: C.primary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: C.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            items: items.map((item) {
              return DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
