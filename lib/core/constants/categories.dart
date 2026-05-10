import 'package:flutter/material.dart';

class CategoryNode {
  final String name;
  final IconData icon;
  final List<String> subcategories;

  const CategoryNode({
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}

class CategoryTree {
  static const List<CategoryNode> hierarchy = [
    CategoryNode(
      name: 'Produce',
      icon: Icons.agriculture_rounded,
      subcategories: ['Vegetables', 'Fruits', 'Greens', 'Tubers'],
    ),
    CategoryNode(
      name: 'Essentials',
      icon: Icons.shopping_basket_rounded,
      subcategories: ['Grains', 'Staples', 'Pulses', 'Oilseeds'],
    ),
    CategoryNode(
      name: 'Specialty',
      icon: Icons.star_rounded,
      subcategories: ['Spices', 'Flowers', 'Plantation', 'Organic'],
    ),
    CategoryNode(
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      subcategories: ['Industrial', 'Processed'],
    ),
  ];
}
