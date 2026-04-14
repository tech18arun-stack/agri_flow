import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../providers/providers.dart';
import '../../../../data/flower_models.dart';

const _kFlowerPink = Color(0xFFdb2777);
const _kFlowerPinkLight = Color(0xFFfce7f3);

class FlowerPricesPublicScreen extends StatefulWidget {
  const FlowerPricesPublicScreen({super.key});

  @override
  State<FlowerPricesPublicScreen> createState() =>
      _FlowerPricesPublicScreenState();
}

class _FlowerPricesPublicScreenState extends State<FlowerPricesPublicScreen> {
  String _selectedDistrict = 'Madurai';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await context.read<FlowerCatalogProvider>().loadCatalog();
    await _loadDistrict('Madurai');
    if (mounted) setState(() => _initialized = true);
  }

  Future<void> _loadDistrict(String district) async {
    setState(() => _selectedDistrict = district);
    final pricesProv = context.read<FlowerPriceProvider>();
    await pricesProv.loadPrices(district);
  }

  @override
  Widget build(BuildContext context) {
    final prices = context.watch<FlowerPriceProvider>();
    final catalog = context.watch<FlowerCatalogProvider>();
    final publishedPrices =
        prices.todayPrices.where((p) => p.isPublished).toList();

    return Scaffold(
      backgroundColor: C.background,
      body: CustomScrollView(
        slivers: [
          // Fancy App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: _kFlowerPink,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌸 Today\'s Flower Prices',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kFlowerPink, Color(0xFF7c3aed)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('🌹🌼🌺🌸',
                        style: TextStyle(fontSize: 28, letterSpacing: 4)),
                  ),
                ),
              ),
            ),
          ),

          // District selector
          SliverToBoxAdapter(
            child: _buildDistrictSelector(),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: _buildStatsBar(publishedPrices.length, prices),
          ),

          // Price list
          if (!_initialized || prices.loading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _kFlowerPink),
                    SizedBox(height: 12),
                    Text('Loading prices...',
                        style: TextStyle(color: C.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else if (publishedPrices.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = publishedPrices[index];
                  // Match with catalog for icon
                  final catalogItem = catalog.activeFlowers
                      .where((f) => f.id == entry.flowerId)
                      .firstOrNull;
                  return _FlowerPriceTile(
                    entry: entry,
                    catalogItem: catalogItem,
                    index: index,
                  );
                },
                childCount: publishedPrices.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDistrictSelector() {
    final districts = TamilNaduDistricts.names;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: C.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select District',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: C.onSurfaceVariant)),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: districts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = districts[i];
                final isSelected = d == _selectedDistrict;
                return GestureDetector(
                  onTap: () => _loadDistrict(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _kFlowerPink : C.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _kFlowerPink
                            : C.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : C.onSurface),
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

  Widget _buildStatsBar(int count, FlowerPriceProvider prices) {
    final lastUpdated = prices.todayPrices
        .where((p) => p.isPublished && p.createdAt != null)
        .map((p) => p.createdAt!)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _kFlowerPinkLight,
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '$count flowers available for $_selectedDistrict',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kFlowerPink),
          ),
          const Spacer(),
          if (lastUpdated.isNotEmpty)
            Text(
              'Updated ${DateFormat('HH:mm').format(lastUpdated.first)}',
              style: const TextStyle(
                  fontSize: 11, color: C.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'No Prices Published Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Prices for $_selectedDistrict will be updated daily.\nPlease check back later.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: C.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _init,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kFlowerPink,
                side: const BorderSide(color: _kFlowerPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PRICE TILE ====================

class _FlowerPriceTile extends StatelessWidget {
  final FlowerPriceEntry entry;
  final FlowerCatalogItem? catalogItem;
  final int index;

  const _FlowerPriceTile({
    required this.entry,
    required this.catalogItem,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color flowerColor = _kFlowerPink;
    try {
      if (catalogItem != null) {
        flowerColor = Color(
            int.parse(catalogItem!.color.replaceAll('#', '0xFF')));
      }
    } catch (_) {}

    final icon = catalogItem?.icon ?? '🌸';
    final isAlternate = index % 2 == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isAlternate
            ? _kFlowerPinkLight.withValues(alpha: 0.4)
            : C.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: flowerColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: flowerColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Row(
          children: [
            Text(entry.flowerName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text(entry.flowerNameTa,
                style: const TextStyle(
                    fontSize: 12, color: C.onSurfaceVariant)),
          ],
        ),
        subtitle: Text(
          'per ${entry.unit}  •  ${entry.district}',
          style: const TextStyle(fontSize: 11, color: C.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${entry.priceMin.toStringAsFixed(0)} – ₹${entry.priceMax.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: flowerColor),
            ),
            Text(
              'avg ₹${entry.avgPrice.toStringAsFixed(0)} / ${entry.unit}',
              style: const TextStyle(
                  fontSize: 10,
                  color: C.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
