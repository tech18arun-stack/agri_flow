import 'package:flutter/material.dart';

/// Shared category icon utility — eliminates duplication across screens.
IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'vegetables':
      return Icons.grass;
    case 'fruits':
      return Icons.apple;
    case 'grains':
      return Icons.grain;
    case 'spices':
      return Icons.water_drop;
    case 'flowers':
      return Icons.local_florist;
    case 'organic':
      return Icons.eco;
    case 'staples':
      return Icons.shopping_basket;
    case 'pulses':
      return Icons.circle;
    case 'greens':
      return Icons.yard_rounded;
    case 'tubers':
      return Icons.bakery_dining_rounded;
    case 'plantation':
      return Icons.coffee_rounded;
    case 'oilseeds':
      return Icons.circle_notifications_rounded;
    case 'industrial':
      return Icons.factory_rounded;
    case 'processed':
      return Icons.liquor;
    default:
      return Icons.eco;
  }
}

/// Returns a curated color for each category.
Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'vegetables':
      return const Color(0xFF4CAF50);
    case 'fruits':
      return const Color(0xFFFF5722);
    case 'grains':
      return const Color(0xFFFFC107);
    case 'spices':
      return const Color(0xFFE91E63);
    case 'flowers':
      return const Color(0xFF9C27B0);
    case 'organic':
      return const Color(0xFF009688);
    case 'staples':
      return const Color(0xFF795548);
    case 'pulses':
      return const Color(0xFFFF9800);
    case 'greens':
      return const Color(0xFF2E7D32);
    case 'tubers':
      return const Color(0xFF8D6E63);
    case 'plantation':
      return const Color(0xFF5D4037);
    case 'oilseeds':
      return const Color(0xFFFBC02D);
    case 'industrial':
      return const Color(0xFF455A64);
    case 'processed':
      return const Color(0xFF0097A7);
    default:
      return const Color(0xFF0d631b);
  }
}
