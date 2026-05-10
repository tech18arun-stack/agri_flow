import 'package:flutter/material.dart';

// ==================== STAT CARD WIDGET ====================

class MarketStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MarketStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? const Color(0xFF002b02);
    final bgColor = backgroundColor ?? const Color(0xFFf5f4ed);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: cardColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cardColor)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ==================== PRICE INDICATOR WIDGET ====================

class PriceIndicator extends StatelessWidget {
  final double yourPrice;
  final double marketAvg;
  final double marketMin;
  final double marketMax;
  final String unit;

  const PriceIndicator({
    super.key,
    required this.yourPrice,
    required this.marketAvg,
    required this.marketMin,
    required this.marketMax,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final priceDiff = yourPrice - marketAvg;
    final isHigher = priceDiff > 0;
    final percentage = marketAvg > 0 ? ((priceDiff / marketAvg) * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigher
            ? const Color(0xFFc8f17a).withValues(alpha: 0.2)
            : const Color(0xFFffdad6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHigher
              ? const Color(0xFFc8f17a)
              : const Color(0xFFffdad6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHigher ? Icons.trending_up : Icons.trending_down,
                color: isHigher ? const Color(0xFF2b3f00) : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHigher
                      ? 'Your price is ${percentage.toStringAsFixed(0)}% above market average'
                      : 'Your price is ${percentage.abs().toStringAsFixed(0)}% below market average',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isHigher ? const Color(0xFF2b3f00) : Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PriceBox(
                  label: 'Your Price',
                  value: '₹${yourPrice.toStringAsFixed(0)}',
                  color: isHigher ? const Color(0xFF2b3f00) : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PriceBox(
                  label: 'Market Avg',
                  value: '₹${marketAvg.toStringAsFixed(0)}',
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PriceBox(
                  label: 'Range',
                  value: '₹${marketMin.toStringAsFixed(0)}-₹${marketMax.toStringAsFixed(0)}',
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PriceBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// ==================== DEMAND BADGE WIDGET ====================

class DemandBadge extends StatelessWidget {
  final double totalQuantity;
  final int sellerCount;
  final bool showLabel;

  const DemandBadge({
    super.key,
    required this.totalQuantity,
    required this.sellerCount,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final demandLevel = _getDemandLevel();

    return Container(
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: demandLevel.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            demandLevel.icon,
            size: showLabel ? 14 : 10,
            color: demandLevel.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              demandLevel.label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: demandLevel.color),
            ),
          ],
        ],
      ),
    );
  }

  _DemandLevel _getDemandLevel() {
    if (totalQuantity >= 1000) {
      return const _DemandLevel(
        label: 'HIGH DEMAND',
        color: Color(0xFFc8f17a),
        icon: Icons.local_fire_department,
      );
    } else if (totalQuantity >= 500) {
      return const _DemandLevel(
        label: 'MODERATE',
        color: Colors.orange,
        icon: Icons.whatshot,
      );
    } else if (totalQuantity >= 200) {
      return const _DemandLevel(
        label: 'LOW DEMAND',
        color: Colors.yellow,
        icon: Icons.show_chart,
      );
    } else {
      return const _DemandLevel(
        label: 'VERY LOW',
        color: Colors.red,
        icon: Icons.trending_down,
      );
    }
  }
}

class _DemandLevel {
  final String label;
  final Color color;
  final IconData icon;

  const _DemandLevel({
    required this.label,
    required this.color,
    required this.icon,
  });
}

// ==================== TREND CHART WIDGET ====================

class MiniTrendChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color? lineColor;
  final Color? fillColor;
  final double height;

  const MiniTrendChart({
    super.key,
    required this.dataPoints,
    this.lineColor,
    this.fillColor,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(height: height);
    }

    final lineColor = this.lineColor ?? const Color(0xFF002b02);
    final fillColor = this.fillColor ?? const Color(0xFF002b02).withValues(alpha: 0.1);

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TrendChartPainter(
          dataPoints: dataPoints,
          lineColor: lineColor,
          fillColor: fillColor,
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;

  _TrendChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final y = range > 0
          ? size.height - ((dataPoints[i] - minVal) / range) * size.height
          : size.height / 2;
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path();
    fillPath.moveTo(points[0].dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}

// ==================== EMPTY STATE WIDGET ====================

class MarketEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const MarketEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

