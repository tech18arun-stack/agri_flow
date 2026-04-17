import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'interactive_card.dart';
import '../../../core/constants/colors.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GlassContainer(
          height: 70,
          blur: 25,
          opacity: 0.6,
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              // Sliding Active Indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutBack,
                alignment: _getAlignment(currentIndex, items.length),
                child: FractionallySizedBox(
                  widthFactor: 1 / items.length,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            C.primary.withValues(alpha: 0.4),
                            C.primary.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: C.primary.withValues(alpha: 0.5),
                          width: 1,
                        ),
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
                      scaleFactor: 0.85,
                      onTap: () => onTap(index),
                      child: Container(
                        height: double.infinity,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: isSelected ? 24 : 22,
                                    color: isSelected
                                        ? C.primary
                                        : C.onSurface.withValues(alpha: 0.4),
                                  ),
                                  if (item.badge != null && item.badge! > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${item.badge}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    showTamil && item.labelTa != null
                                        ? item.labelTa!
                                        : item.label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: C.primary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
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
