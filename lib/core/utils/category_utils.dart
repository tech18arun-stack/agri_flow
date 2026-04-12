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
    case 'dairy':
      return Icons.egg_alt;
    case 'pulses':
      return Icons.circle;
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
    case 'dairy':
      return const Color(0xFF2196F3);
    case 'pulses':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFF0d631b);
  }
}
