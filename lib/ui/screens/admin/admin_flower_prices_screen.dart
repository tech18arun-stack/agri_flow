import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../data/flower_models.dart';

const _kFlowerPink = Color(0xFFdb2777);

class AdminFlowerPricesScreen extends StatefulWidget {
  const AdminFlowerPricesScreen({super.key});

  @override
  State<AdminFlowerPricesScreen> createState() =>
      _AdminFlowerPricesScreenState();
}

class _AdminFlowerPricesScreenState extends State<AdminFlowerPricesScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  String _filterDistrict = 'All';
  String _filterStatus = 'All';
  late AnimationController _gridController;

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _gridController.forward();
    });
  }

  @override
  void dispose() {
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await context
        .read<FlowerPriceProvider>()
        .loadAllDistrictPrices(date: _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final pricesProv = context.watch<FlowerPriceProvider>();
    final allPrices = pricesProv.allPrices;

    final filtered = allPrices.where((p) {
      if (_filterDistrict != 'All' && p.district != _filterDistrict) return false;
      if (_filterStatus != 'All' && p.status != _filterStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final districtSummary = <String, _DistrictSummary>{};
    for (final p in allPrices) {
      districtSummary.putIfAbsent(p.district, () => _DistrictSummary(district: p.district, total: 0, published: 0, draft: 0));
      final s = districtSummary[p.district]!;
      districtSummary[p.district] = _DistrictSummary(
        district: p.district,
        total: s.total + 1,
        published: s.published + (p.isPublished ? 1 : 0),
        draft: s.draft + (p.isDraft ? 1 : 0),
      );
    }

    final sortedDistricts = districtSummary.values.toList()..sort((a, b) => b.total.compareTo(a.total));
    final districts = ['All', ...TamilNaduDistricts.names];

    return Scaffold(
      backgroundColor: C.background,
      body: pricesProv.loading
          ? const Center(child: CircularProgressIndicator(color: _kFlowerPink))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(allPrices.length, allPrices.where((p) => p.isPublished).length),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Regional Coverage', 'Publishing status across districts'),
                        const SizedBox(height: 16),
                        _buildDistrictGrid(sortedDistricts),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader('Global Inventory', 'Manage flower pricing entries'),
                        const SizedBox(height: 16),
                        _buildFiltersRow(districts),
                        const SizedBox(height: 20),
                        _buildPriceTable(filtered),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: C.onSurface)),
        Text(sub, style: TextStyle(fontSize: 12, color: C.onSurfaceVariant.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildSliverHeader(int total, int published) {
    return SliverAppBar(
      expandedHeight: 180.0,
      backgroundColor: C.primary,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kFlowerPink, Color(0xFF7c3aed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Text('🌸', style: TextStyle(fontSize: 200)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flower Price Monitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildHeaderChip('$total Entries', Icons.list_alt_rounded),
                      const SizedBox(width: 12),
                      _buildHeaderChip('$published Published', Icons.check_circle_outline_rounded),
                      const Spacer(),
                      _buildDateSelector(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: _kFlowerPink, size: 16),
            const SizedBox(width: 10),
            Text(
              DateFormat('d MMM yyyy').format(_selectedDate),
              style: const TextStyle(color: _kFlowerPink, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictGrid(List<_DistrictSummary> summaries) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: summaries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final s = summaries[i];
          final completed = s.total > 0 && s.published == s.total;
          final pct = s.total == 0 ? 0.0 : s.published / s.total;
          
          return Container(
            width: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: completed ? Colors.green.withValues(alpha: 0.2) : C.outlineVariant.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(s.district, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    if (completed)
                      const Icon(Icons.verified_rounded, color: Colors.green, size: 16),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${s.published}/${s.total} items', style: TextStyle(fontSize: 11, color: C.onSurfaceVariant.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: C.surfaceContainerLow,
                        color: completed ? Colors.green : _kFlowerPink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersRow(List<String> districts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown(
            label: 'District',
            value: _filterDistrict,
            items: districts,
            onChanged: (v) => setState(() => _filterDistrict = v ?? 'All'),
            width: 200,
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(
            label: 'Status',
            value: _filterStatus,
            items: ['All', 'Published', 'Draft'],
            onChanged: (v) => setState(() => _filterStatus = v ?? 'All'),
            width: 150,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            label: 'Sync Now',
            icon: Icons.sync_rounded,
            onPressed: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double width = 150,
  }) {
    return Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: C.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _kFlowerPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kFlowerPink.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Icon(icon, color: _kFlowerPink, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: _kFlowerPink, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable(List<FlowerPriceEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: C.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3), style: BorderStyle.none),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔍', style: TextStyle(fontSize: 32)),
              SizedBox(height: 12),
              Text('No matches for current filters', style: TextStyle(fontWeight: FontWeight.w700, color: C.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: C.onSurface.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(C.surfaceContainerLow.withValues(alpha: 0.5)),
            dataRowMinHeight: 70,
            columnSpacing: 32,
            columns: const [
              DataColumn(label: Text('Flowering Resource', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Region', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Range (₹)', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Performance', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Controls', style: TextStyle(fontWeight: FontWeight.w900))),
            ],
            rows: entries.map((e) => _buildDataRow(e)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(FlowerPriceEntry entry) {
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.flowerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(entry.flowerNameTa, style: TextStyle(fontSize: 10, color: C.onSurfaceVariant.withValues(alpha: 0.5))),
            ],
          ),
        ),
        DataCell(Text(entry.district, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        DataCell(
          Row(
            children: [
              Text('₹${entry.priceMin.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
              Text(' — ', style: TextStyle(color: C.onSurfaceVariant.withValues(alpha: 0.3))),
              Text('₹${entry.priceMax.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        DataCell(
          Text('₹${entry.avgPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
            child: Text(entry.unit, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.onSurfaceVariant)),
          ),
        ),
        DataCell(
          _buildStatusTag(entry.status),
        ),
        DataCell(
          Row(
            children: [
              _buildControlIcon(Icons.edit_note_rounded, C.primary, () => _showEditDialog(entry)),
              const SizedBox(width: 8),
              _buildControlIcon(
                entry.isPublished ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                entry.isPublished ? Colors.orange : Colors.green,
                () => _toggleStatus(entry),
              ),
              const SizedBox(width: 8),
              _buildControlIcon(Icons.delete_sweep_rounded, Colors.red, () => _confirmDelete(entry)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    final isPublished = status == 'published';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isPublished ? Colors.green.shade700 : Colors.orange.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _kFlowerPink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  Future<void> _toggleStatus(FlowerPriceEntry entry) async {
    final newStatus = entry.isPublished ? 'draft' : 'published';
    final ok = await context.read<FlowerPriceProvider>().updateStatus(entry.docId ?? '', newStatus);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${entry.flowerName} is now $newStatus!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _confirmDelete(FlowerPriceEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Deletion'),
        content: Text('Remove ${entry.flowerName} price entry for ${entry.district}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<FlowerPriceProvider>().deletePrice(entry.docId ?? '');
    }
  }

  Future<void> _showEditDialog(FlowerPriceEntry entry) async {
    final auth = context.read<AuthProvider>();
    final minCtrl = TextEditingController(text: entry.priceMin.toStringAsFixed(0));
    final maxCtrl = TextEditingController(text: entry.priceMax.toStringAsFixed(0));

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Adjust Pricing', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${entry.flowerName}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('Region: ${entry.district}', style: TextStyle(fontSize: 12, color: C.onSurfaceVariant)),
            const SizedBox(height: 24),
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minimum Price (₹)',
                filled: true,
                fillColor: C.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Maximum Price (₹)',
                filled: true,
                fillColor: C.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    if (res == true && mounted) {
      final min = double.tryParse(minCtrl.text) ?? entry.priceMin;
      final max = double.tryParse(maxCtrl.text) ?? entry.priceMax;
      
      await context.read<FlowerPriceProvider>().savePrice(
        flowerId: entry.flowerId,
        flowerName: entry.flowerName,
        flowerNameTa: entry.flowerNameTa,
        district: entry.district,
        priceMin: min,
        priceMax: max,
        unit: entry.unit,
        updatedById: auth.user?.id ?? 'admin',
        updatedByName: auth.user?.name ?? 'Admin',
        status: entry.status,
      );
    }
  }
}

class _DistrictSummary {
  final String district;
  final int total;
  final int published;
  final int draft;
  const _DistrictSummary({
    required this.district,
    required this.total,
    required this.published,
    required this.draft,
  });
}
