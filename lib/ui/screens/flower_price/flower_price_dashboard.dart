import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../data/flower_models.dart';

const _kFlowerPink = Color(0xFFdb2777);
const _kFlowerPinkLight = Color(0xFFfce7f3);
const _kFlowerPurple = Color(0xFF7c3aed);

class FlowerPriceDashboard extends StatefulWidget {
  const FlowerPriceDashboard({super.key});

  @override
  State<FlowerPriceDashboard> createState() => _FlowerPriceDashboardState();
}

class _FlowerPriceDashboardState extends State<FlowerPriceDashboard>
    with SingleTickerProviderStateMixin {
  String _selectedDistrict = 'Madurai';
  late TabController _tabController;

  // price controllers: flowerId -> {min, max}
  final Map<String, TextEditingController> _minControllers = {};
  final Map<String, TextEditingController> _maxControllers = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final catalog = context.read<FlowerCatalogProvider>();
    final prices = context.read<FlowerPriceProvider>();
    await catalog.loadCatalog();
    _buildControllers(catalog.activeFlowers);
    await prices.loadPrices(_selectedDistrict);
    await prices.loadYesterdayPrices(_selectedDistrict);
    _populateControllers(prices.todayPrices);
    setState(() => _initialized = true);
  }

  void _buildControllers(List<FlowerCatalogItem> flowers) {
    for (final flower in flowers) {
      _minControllers[flower.id] ??= TextEditingController();
      _maxControllers[flower.id] ??= TextEditingController();
    }
  }

  void _populateControllers(List<FlowerPriceEntry> entries) {
    for (final entry in entries) {
      if (_minControllers.containsKey(entry.flowerId)) {
        _minControllers[entry.flowerId]!.text =
            entry.priceMin > 0 ? entry.priceMin.toStringAsFixed(0) : '';
        _maxControllers[entry.flowerId]!.text =
            entry.priceMax > 0 ? entry.priceMax.toStringAsFixed(0) : '';
      }
    }
  }

  Future<void> _switchDistrict(String district) async {
    setState(() => _selectedDistrict = district);
    final prices = context.read<FlowerPriceProvider>();
    await prices.loadPrices(district);
    await prices.loadYesterdayPrices(district);
    _populateControllers(prices.todayPrices);
  }

  Map<String, ({double min, double max})> _collectPrices() {
    final Map<String, ({double min, double max})> result = {};
    for (final entry in _minControllers.entries) {
      final minVal = double.tryParse(entry.value.text) ?? 0;
      final maxVal = double.tryParse(_maxControllers[entry.key]?.text ?? '') ?? 0;
      if (minVal > 0 || maxVal > 0) {
        result[entry.key] = (min: minVal, max: maxVal <= 0 ? minVal : maxVal);
      }
    }
    return result;
  }

  Future<void> _saveDraft() async {
    final auth = context.read<AuthProvider>();
    final prices = context.read<FlowerPriceProvider>();
    final catalog = context.read<FlowerCatalogProvider>();
    final priceData = _collectPrices();
    if (priceData.isEmpty) {
      _showSnack('Please enter at least one price', isError: true);
      return;
    }
    final count = await prices.saveAllPrices(
      district: _selectedDistrict,
      flowers: catalog.activeFlowers,
      prices: priceData,
      updatedById: auth.user?.id ?? '',
      updatedByName: auth.user?.name ?? '',
      status: 'draft',
    );
    _showSnack('Saved $count prices as draft');
  }

  Future<void> _publishAll() async {
    final auth = context.read<AuthProvider>();
    final prices = context.read<FlowerPriceProvider>();
    final catalog = context.read<FlowerCatalogProvider>();
    final priceData = _collectPrices();
    if (priceData.isEmpty) {
      // Try to publish existing drafts
      final ok = await prices.publishAll(_selectedDistrict);
      if (!mounted) return;
      _showSnack(ok ? 'All draft prices published! ✅' : 'No draft prices to publish');
      return;
    }
    // Save as published directly
    final count = await prices.saveAllPrices(
      district: _selectedDistrict,
      flowers: catalog.activeFlowers,
      prices: priceData,
      updatedById: auth.user?.id ?? '',
      updatedByName: auth.user?.name ?? '',
      status: 'published',
    );
    if (!mounted) return;
    if (count > 0) {
      _showSnack('$count prices published for $_selectedDistrict ✅');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? C.error : _kFlowerPink,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _minControllers.values) {
      c.dispose();
    }
    for (final c in _maxControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prices = context.watch<FlowerPriceProvider>();
    final catalog = context.watch<FlowerCatalogProvider>();
    final flowers = catalog.activeFlowers;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 900;

    return Scaffold(
      backgroundColor: C.surface,
      body: Column(
        children: [
          _buildHeader(auth, isNarrow),
          _buildDistrictBar(isNarrow),
          _buildStatsRow(prices, flowers.length),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPriceTable(flowers, prices, isNarrow),
                _buildHistoryTab(prices),
              ],
            ),
          ),
          if (!isNarrow) _buildActionBar(prices),
        ],
      ),
      floatingActionButton: isNarrow
          ? FloatingActionButton.extended(
              onPressed: _publishAll,
              backgroundColor: _kFlowerPink,
              icon: const Icon(Icons.publish, color: Colors.white),
              label: const Text('Publish All',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(AuthProvider auth, bool isNarrow) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 16 : 32, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kFlowerPink, _kFlowerPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🌸', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNarrow ? 'Flower Prices' : 'Flower Price Portal',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (!isNarrow)
            Chip(
              label: Text(auth.user?.name ?? 'Updater',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              avatar: const Icon(Icons.person, color: Colors.white, size: 16),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              side: BorderSide.none,
            ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }

  // ==================== DISTRICT BAR ====================
  Widget _buildDistrictBar(bool isNarrow) {
    final districts = TamilNaduDistricts.names;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: C.surface,
        boxShadow: [
          BoxShadow(
              color: _kFlowerPink.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.location_on, color: _kFlowerPink, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDistrict,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: C.onSurface),
                icon: const Icon(Icons.keyboard_arrow_down, color: _kFlowerPink),
                items: districts.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text('$d — ${TamilNaduDistricts.getTamil(d)}'),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _switchDistrict(v);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (!isNarrow)
            OutlinedButton.icon(
              onPressed: () async {
                final prices = context.read<FlowerPriceProvider>();
                await prices.loadPrices(_selectedDistrict);
                await prices.loadYesterdayPrices(_selectedDistrict);
                _populateControllers(prices.todayPrices);
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kFlowerPink,
                side: const BorderSide(color: _kFlowerPink),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // ==================== STATS ROW ====================
  Widget _buildStatsRow(FlowerPriceProvider prices, int totalFlowers) {
    final stats = [
      (label: 'Total Flowers', value: '$totalFlowers', icon: '🌸', color: _kFlowerPink),
      (label: 'Updated Today', value: '${prices.totalCount}', icon: '📝', color: C.primary),
      (label: 'Draft', value: '${prices.draftCount}', icon: '⏸️', color: Colors.orange),
      (label: 'Published', value: '${prices.publishedCount}', icon: '✅', color: Colors.green),
    ];

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _kFlowerPinkLight,
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: s.color.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  Text(s.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.value,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: s.color)),
                        Text(s.label,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: C.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== TAB BAR ====================
  Widget _buildTabBar() {
    return Container(
      color: C.surfaceContainerLow,
      child: TabBar(
        controller: _tabController,
        labelColor: _kFlowerPink,
        unselectedLabelColor: C.onSurfaceVariant,
        indicatorColor: _kFlowerPink,
        tabs: const [
          Tab(icon: Icon(Icons.edit_note, size: 18), text: 'Enter Prices'),
          Tab(icon: Icon(Icons.history, size: 18), text: 'History'),
        ],
      ),
    );
  }

  // ==================== PRICE TABLE ====================
  Widget _buildPriceTable(
      List<FlowerCatalogItem> flowers,
      FlowerPriceProvider prices,
      bool isNarrow) {
    if (!_initialized || prices.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _kFlowerPink),
            SizedBox(height: 16),
            Text('Loading prices...', style: TextStyle(color: C.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (flowers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌸', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No flowers in catalog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Ask admin to add flowers to the catalog',
                style: TextStyle(color: C.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _kFlowerPinkLight,
          child: Row(
            children: [
              const Expanded(flex: 3, child: Text('Flower', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              if (!isNarrow)
                const Expanded(flex: 2, child: Text('Yesterday (₹)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              const Expanded(flex: 2, child: Text('Min Price (₹)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              const Expanded(flex: 2, child: Text('Max Price (₹)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              const SizedBox(width: 56),
              const Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
            ],
          ),
        ),
        // Table rows
        Expanded(
          child: ListView.separated(
            itemCount: flowers.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final flower = flowers[index];
              final entry = prices.getPriceFor(flower.id);
              final yesterday = prices.getYesterdayPriceFor(flower.id);
              return _FlowerPriceRow(
                flower: flower,
                entry: entry,
                yesterday: yesterday,
                minController: _minControllers[flower.id]!,
                maxController: _maxControllers[flower.id]!,
                isNarrow: isNarrow,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab(FlowerPriceProvider prices) {
    final history = prices.allPrices;
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No history yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Published prices will appear here',
                style: TextStyle(color: C.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text('🌸', style: const TextStyle(fontSize: 24)),
            title: Text('${entry.flowerName} — ${entry.district}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${entry.date} • ${entry.updatedByName ?? 'Unknown'}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${entry.priceMin.toStringAsFixed(0)} – ₹${entry.priceMax.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: _kFlowerPink)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry.isPublished
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: entry.isPublished ? Colors.green : Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== ACTION BAR ====================
  Widget _buildActionBar(FlowerPriceProvider prices) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: C.surfaceContainerLow,
        border: Border(top: BorderSide(color: C.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Text(
            'District: $_selectedDistrict  •  ${DateFormat('d MMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: C.onSurfaceVariant),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: prices.saving ? null : _saveDraft,
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Save as Draft'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kFlowerPink,
              side: const BorderSide(color: _kFlowerPink),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: prices.saving ? null : _publishAll,
            icon: prices.saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.publish, size: 16),
            label: const Text('Publish All Prices'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kFlowerPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FLOWER PRICE ROW ====================

class _FlowerPriceRow extends StatelessWidget {
  final FlowerCatalogItem flower;
  final FlowerPriceEntry? entry;
  final FlowerPriceEntry? yesterday;
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isNarrow;
  final int index;

  const _FlowerPriceRow({
    required this.flower,
    required this.entry,
    required this.yesterday,
    required this.minController,
    required this.maxController,
    required this.isNarrow,
    required this.index,
  });

  double get _todayAvg {
    final min = double.tryParse(minController.text) ?? 0;
    final max = double.tryParse(maxController.text) ?? 0;
    if (min <= 0 && max <= 0) return 0;
    return (min + max) / 2;
  }

  double get _changePercent {
    final todayAvg = _todayAvg;
    final yAvg = yesterday?.avgPrice ?? 0;
    if (yAvg == 0 || todayAvg == 0) return 0;
    return ((todayAvg - yAvg) / yAvg) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isAlternate = index % 2 == 1;
    final change = _changePercent;
    final isUp = change > 0;
    final isDown = change < 0;

    Color? flowerColor;
    try {
      flowerColor = Color(int.parse(flower.color.replaceAll('#', '0xFF')));
    } catch (_) {
      flowerColor = _kFlowerPink;
    }

    return Container(
      color: isAlternate
          ? C.surfaceContainerLow.withValues(alpha: 0.5)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Flower name column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: flowerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(flower.icon,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flower.nameEn,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(flower.nameTa,
                          style: const TextStyle(
                              fontSize: 11, color: C.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Yesterday price
          if (!isNarrow)
            Expanded(
              flex: 2,
              child: Text(
                yesterday != null && yesterday!.avgPrice > 0
                    ? '₹${yesterday!.avgPrice.toStringAsFixed(0)} / ${flower.unit}'
                    : '—',
                style: const TextStyle(
                    fontSize: 13,
                    color: C.onSurfaceVariant,
                    fontWeight: FontWeight.w500),
              ),
            ),

          // Min price input
          Expanded(
            flex: 2,
            child: _PriceField(
              controller: minController,
              hint: 'Min',
              color: flowerColor,
            ),
          ),

          // Max price input
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _PriceField(
                controller: maxController,
                hint: 'Max',
                color: flowerColor,
              ),
            ),
          ),

          // Trend indicator
          SizedBox(
            width: 56,
            child: Center(
              child: change == 0
                  ? const Icon(Icons.remove, color: C.onSurfaceVariant, size: 18)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          color: isUp ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        Text(
                          '${change.abs().toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isUp ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
            ),
          ),

          // Status badge
          Expanded(
            flex: 1,
            child: entry == null
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry!.isPublished
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry!.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: entry!.isPublished
                              ? Colors.green.shade700
                              : Colors.orange.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRICE INPUT FIELD ====================

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color color;

  const _PriceField({
    required this.controller,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: C.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: C.onSurfaceVariant),
          filled: true,
          fillColor: C.surfaceContainerHighest,
          prefixText: '₹',
          prefixStyle: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
        ),
      ),
    );
  }
}
