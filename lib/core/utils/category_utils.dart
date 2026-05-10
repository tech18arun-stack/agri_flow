import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
      case 'காய்கறிகள்':
        return Icons.grass_rounded;
      case 'fruits':
      case 'பழங்கள்':
        return Icons.apple_rounded;
      case 'grains':
      case 'தானியங்கள்':
        return Icons.grain_rounded;
      case 'spices':
      case 'மசாலா':
        return Icons.water_drop_rounded;
      case 'flowers':
      case 'மலர்கள்':
        return Icons.local_florist_rounded;
      case 'seeds':
      case 'விதை':
        return Icons.spa_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  static String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return '🥬';
      case 'fruits':
        return '🍎';
      case 'grains':
        return '🌾';
      case 'spices':
        return '🌶️';
      case 'flowers':
        return '🌸';
      case 'seeds':
        return '🌱';
      default:
        return '🛍️';
    }
  }
  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
      case 'காய்கறிகள்':
        return const Color(0xFF2D6A35);
      case 'fruits':
      case 'பழங்கள்':
        return const Color(0xFFD81B60);
      case 'grains':
      case 'தானியங்கள்':
        return const Color(0xFF92400E);
      case 'spices':
      case 'மசாலா':
        return const Color(0xFFB45309);
      case 'flowers':
      case 'மலர்கள்':
        return const Color(0xFFBE185D);
      case 'seeds':
      case 'விதை':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF2D6A35);
    }
  }
}
