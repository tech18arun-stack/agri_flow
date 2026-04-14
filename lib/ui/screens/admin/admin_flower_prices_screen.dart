import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/providers.dart';
import '../../../data/flower_models.dart';

const _kFlowerPink = Color(0xFFdb2777);
const _kFlowerPinkLight = Color(0xFFfce7f3);

class AdminFlowerPricesScreen extends StatefulWidget {
  const AdminFlowerPricesScreen({super.key});

  @override
  State<AdminFlowerPricesScreen> createState() =>
      _AdminFlowerPricesScreenState();
}

class _AdminFlowerPricesScreenState extends State<AdminFlowerPricesScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterDistrict = 'All';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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

    // Apply filters
    final filtered = allPrices.where((p) {
      if (_filterDistrict != 'All' && p.district != _filterDistrict) {
        return false;
      }
      if (_filterStatus != 'All' && p.status != _filterStatus.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    // Summary by district
    final districtSummary = <String, _DistrictSummary>{};
    for (final p in allPrices) {
      districtSummary.putIfAbsent(
          p.district,
          () => _DistrictSummary(
              district: p.district,
              total: 0,
              published: 0,
              draft: 0));
      final s = districtSummary[p.district]!;
      districtSummary[p.district] = _DistrictSummary(
        district: p.district,
        total: s.total + 1,
        published: s.published + (p.isPublished ? 1 : 0),
        draft: s.draft + (p.isDraft ? 1 : 0),
      );
    }

    final districts = ['All', ...TamilNaduDistricts.names];
    final publishedCount = allPrices.where((p) => p.isPublished).length;
    final draftCount = allPrices.where((p) => p.isDraft).length;

    return Scaffold(
      backgroundColor: C.background,
      body: pricesProv.loading
          ? const Center(child: CircularProgressIndicator(color: _kFlowerPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header + Date Selector
                  _buildHeader(publishedCount, draftCount, allPrices.length),
                  const SizedBox(height: 20),

                  // District overview cards
                  if (districtSummary.isNotEmpty) ...[
                    const Text('District Overview',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    _buildDistrictCards(districtSummary),
                    const SizedBox(height: 24),
                  ],

                  // Filters row
                  _buildFilters(districts),
                  const SizedBox(height: 16),

                  // Data Table
                  _buildTable(filtered),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(int published, int draft, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kFlowerPink, Color(0xFF7c3aed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Flower Price Monitor',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                Text(
                  '$published published · $draft draft · $total total',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _kFlowerPink,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictCards(Map<String, _DistrictSummary> summaries) {
    final sorted = summaries.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final s = sorted[i];
          final completion =
              s.total == 0 ? 0.0 : s.published / s.total;
          return Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: completion == 1
                      ? Colors.green.withValues(alpha: 0.4)
                      : _kFlowerPink.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.district,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const Spacer(),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor:
                      _kFlowerPink.withValues(alpha: 0.1),
                  color: completion == 1
                      ? Colors.green
                      : _kFlowerPink,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text('${s.published}/${s.total} published',
                    style: TextStyle(
                        fontSize: 10,
                        color: completion == 1
                            ? Colors.green.shade700
                            : C.onSurfaceVariant)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(List<String> districts) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // District filter
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            value: _filterDistrict,
            decoration: InputDecoration(
              labelText: 'District',
              prefixIcon: const Icon(Icons.location_on, size: 18),
              filled: true,
              fillColor: C.surfaceContainerLow,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: districts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => _filterDistrict = v ?? 'All'),
          ),
        ),
        // Status filter
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: _filterStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(Icons.flag, size: 18),
              filled: true,
              fillColor: C.surfaceContainerLow,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ['All', 'Published', 'Draft']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _filterStatus = v ?? 'All'),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<FlowerPriceEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: C.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Text('🌸', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text('No price data for selected filters',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(_kFlowerPinkLight),
            dataRowMinHeight: 52,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Flower', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('District', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Min ₹', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Max ₹', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Avg ₹', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Updated By', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.w800))),
            ],
            rows: entries.map((entry) {
              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(entry.flowerName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(entry.flowerNameTa,
                        style: const TextStyle(
                            fontSize: 11, color: C.onSurfaceVariant)),
                  ],
                )),
                DataCell(Text(entry.district)),
                DataCell(Text('₹${entry.priceMin.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.green))),
                DataCell(Text('₹${entry.priceMax.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.red))),
                DataCell(Text('₹${entry.avgPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kFlowerPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(entry.unit,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _kFlowerPink)),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.isPublished
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: entry.isPublished
                              ? Colors.green.shade700
                              : Colors.orange.shade700),
                    ),
                  ),
                ),
                DataCell(Text(entry.updatedByName ?? '—',
                    style: const TextStyle(fontSize: 12))),
                DataCell(Text(
                  entry.createdAt != null
                      ? DateFormat('HH:mm').format(entry.createdAt!)
                      : '—',
                  style: const TextStyle(fontSize: 12),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
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
