import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Premium Floating Bottom Navigation with glass effect + animated indicators
class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;
  final double bottomPadding;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: C.surfaceContainerLowest.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: C.outlineVariant.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabChange,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              enableFeedback: false,
              selectedItemColor: C.primary,
              unselectedItemColor: C.onSurfaceVariant,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              iconSize: 24,
              selectedIconTheme: const IconThemeData(size: 26),
              items: [
                _buildNavItem(Icons.home_rounded, 'Home', 0, currentIndex, hasBadge: false),
                _buildNavItem(Icons.grid_view_rounded, 'Products', 1, currentIndex, hasBadge: false),
                _buildNavItem(Icons.local_offer_rounded, 'Deals', 2, currentIndex, hasBadge: true, badgeCount: 3),
                _buildNavItem(Icons.trending_up_rounded, 'Trending', 3, currentIndex, hasBadge: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex, {
    bool hasBadge = false,
    int badgeCount = 0,
  }) {
    return BottomNavigationBarItem(
      icon: _TabIcon(
        icon: icon,
        isSelected: currentIndex == index,
        hasBadge: hasBadge,
        badgeCount: badgeCount,
      ),
      label: label,
    );
  }
}

/// Animated tab icon with scale effect + optional badge
class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool hasBadge;
  final int badgeCount;

  const _TabIcon({
    required this.icon,
    required this.isSelected,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected ? C.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Icon(
              icon,
              color: isSelected ? C.primary : C.onSurfaceVariant,
            ),
          ),
          if (hasBadge && badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
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
}
