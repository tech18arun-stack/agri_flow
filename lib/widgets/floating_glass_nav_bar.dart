import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'interactive_card.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class FloatingGlassNavItem {
  final IconData icon;
  final String label;
  final String? labelTa;
  final int? badge;

  FloatingGlassNavItem({
    required this.icon,
    required this.label,
    this.labelTa,
    this.badge,
  });
}

class FloatingGlassNavBar extends StatelessWidget {
  final List<FloatingGlassNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final bool showTamil;

  const FloatingGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: GlassContainer(
          height: 72,
          blur: 15,
          opacity: 0.7,
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            children: [
              // Sliding Active Indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                alignment: _getAlignment(currentIndex, items.length),
                child: FractionallySizedBox(
                  widthFactor: 1 / items.length,
                  child: Center(
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            C.primary.withValues(alpha: 0.15),
                            C.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: C.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Nav Items
              Row(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: InteractiveCard(
                      scaleFactor: 0.9,
                      onTap: () => onTap(index),
                      child: Container(
                        height: double.infinity,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: isSelected ? 26 : 22,
                              color: isSelected
                                  ? C.primary
                                  : C.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (Responsive.isPhone(context)) ...[
                                    Text(
                                      showTamil ? (item.labelTa ?? item.label) : item.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? C.primary : C.onSurface.withValues(alpha: 0.5),
                                        height: 1.1,
                                      ),
                                    ),
                                  ] else ...[
                                    if (item.labelTa != null)
                                      Text(
                                        item.labelTa!,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? C.primary : C.onSurface.withValues(alpha: 0.5),
                                          height: 1.1,
                                        ),
                                      ),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? C.primary : C.onSurface.withValues(alpha: 0.4),
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index, int total) {
    if (total <= 1) return Alignment.center;
    final double pos = (index / (total - 1)) * 2 - 1;
    return Alignment(pos, 0);
  }
}
