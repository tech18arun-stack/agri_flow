import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistItem {
  final String productId;
  final DateTime addedAt;

  const WishlistItem({
    required this.productId,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'addedAt': addedAt.toIso8601String(),
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        productId: json['productId'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}

class WishlistProvider extends ChangeNotifier {
  final List<WishlistItem> _items = [];
  List<WishlistItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('wishlist');
    if (wishlistJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        _items.clear();
        _items.addAll(
          decoded.map((e) => WishlistItem.fromJson(e)).toList(),
        );
      } catch (e) {
        debugPrint('Error loading wishlist: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('wishlist', wishlistJson);
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      _items.removeWhere((item) => item.productId == productId);
    } else {
      _items.add(WishlistItem(
        productId: productId,
        addedAt: DateTime.now(),
      ));
    }
    await _save();
    notifyListeners();
  }

  Future<void> addToWishlist(String productId) async {
    if (!isInWishlist(productId)) {
      _items.add(WishlistItem(
        productId: productId,
        addedAt: DateTime.now(),
      ));
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((item) => item.productId == productId);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _save();
    notifyListeners();
  }
}
