import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../data/flower_models.dart';

class FlowerPricePublicScreen extends StatefulWidget {
  const FlowerPricePublicScreen({super.key});

  @override
  State<FlowerPricePublicScreen> createState() => _FlowerPricePublicScreenState();
}

class _FlowerPricePublicScreenState extends State<FlowerPricePublicScreen> {
  String _selectedDistrict = 'Madurai';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final prices = context.read<FlowerPriceProvider>();
    final catalog = context.read<FlowerCatalogProvider>();
    
    await Future.wait([
      catalog.loadCatalog(),
      prices.loadPrices(_selectedDistrict),
      prices.loadYesterdayPrices(_selectedDistrict),
    ]);
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _onDistrictChanged(String? district) {
    if (district != null && district != _selectedDistrict) {
      setState(() => _selectedDistrict = district);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = context.watch<FlowerPriceProvider>();
    final catalog = context.watch<FlowerCatalogProvider>();
    final flowers = catalog.activeFlowers;
    
    const kFlowerPink = Color(0xFFdb2777);
    const kFlowerPurple = Color(0xFF7c3aed);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Flower Mandi Prices',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kFlowerPink, kFlowerPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(Icons.eco, size: 200, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDistrictSelector(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Market Rates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: C.primary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: kFlowerPink)),
            )
          else if (flowers.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No flowers found in catalog')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final flower = flowers[index];
                    final today = prices.getPriceFor(flower.id);
                    final yesterday = prices.getYesterdayPriceFor(flower.id);
                    
                    if (today == null || !today.isPublished) {
                      return _buildEmptyPriceCard(flower);
                    }
                    
                    return _buildFlowerPriceCard(flower, today, yesterday);
                  },
                  childCount: flowers.length,
                ),
              ),
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildDistrictSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrict,
          isExpanded: true,
          icon: const Icon(Icons.location_on, color: Color(0xFFdb2777)),
          items: TamilNaduDistricts.names.map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(
                '$name — ${TamilNaduDistricts.getTamil(name)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: _onDistrictChanged,
        ),
      ),
    );
  }

  Widget _buildFlowerPriceCard(FlowerCatalogItem flower, FlowerPriceEntry today, FlowerPriceEntry? yesterday) {
    final avg = today.avgPrice;
    final yAvg = yesterday?.avgPrice ?? 0;
    final diff = yAvg > 0 ? ((avg - yAvg) / yAvg) * 100 : 0.0;
    final isUp = diff > 0;
    
    Color flowerColor;
    try {
      flowerColor = Color(int.parse(flower.color.replaceAll('#', '0xFF')));
    } catch (_) {
      flowerColor = const Color(0xFFdb2777);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: flowerColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: flowerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(flower.icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flower.nameEn,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    flower.nameTa,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${avg.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: flowerColor,
                  ),
                ),
                Text(
                  'per ${flower.unit}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (diff.abs() > 0.1)
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: isUp ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${diff.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUp ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPriceCard(FlowerCatalogItem flower) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Text(flower.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${flower.nameEn} — Price Pending',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            const Icon(Icons.update, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
