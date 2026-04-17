import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../data/models.dart';

// ==================== TAP ANIMATION WRAPPER ====================

class TapScaleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleEnd;

  const TapScaleAnimation({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleEnd = 0.95,
  });

  @override
  State<TapScaleAnimation> createState() => _TapScaleAnimationState();
}

class _TapScaleAnimationState extends State<TapScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

// ==================== PREMIUM PRODUCT CARD (GRID) ====================

class PremiumProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel)? onTap;
  final bool showFarmerName;
  final bool showLocation;
  final bool showRating;
  final bool compact;

  const PremiumProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showFarmerName = true,
    this.showLocation = true,
    this.showRating = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: () => onTap?.call(product),
      child: Selector<CartProvider, bool>(
        selector: (_, cart) => cart.items.any((item) => item.product.id == product.id),
        builder: (context, inCart, child) {
          return Selector<WishlistProvider, bool>(
            selector: (_, wishlist) => wishlist.isInWishlist(product.id),
            builder: (context, inWishlist, child) {
              return Container(
                decoration: BoxDecoration(
                  color: C.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Area
                    Expanded(
                      child: Stack(
                        children: [
                          // Show product image if available, otherwise show icon
                          product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: CachedNetworkImage(
                                    imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (_, __) => Container(
                                      color: C.primaryContainer.withValues(alpha: 0.08),
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: compact ? 36 : 48,
                                          color: C.primary.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: C.primaryContainer.withValues(alpha: 0.08),
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: compact ? 36 : 48,
                                          color: C.primary.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: C.primaryContainer.withValues(alpha: 0.08),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(product.category),
                                      size: compact ? 36 : 48,
                                      color: C.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                          // Badges
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Row(
                              children: [
                                if (product.organic)
                                  _Badge(label: '🌿 Organic', color: const Color(0xFFc8f17a)),
                              ],
                            ),
                          ),
                          // Wishlist Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _WishlistButton(
                              productId: product.id,
                              inWishlist: inWishlist,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 product.name,
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(
                                   fontSize: compact ? 12 : 13,
                                   fontWeight: FontWeight.w800,
                                   color: C.onSurface,
                                 ),
                               ),
                               if (product.nameTa.isNotEmpty)
                                 Text(
                                   product.nameTa,
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                   style: TextStyle(
                                     fontSize: compact ? 10 : 11,
                                     fontWeight: FontWeight.w600,
                                     color: C.primary,
                                   ),
                                 ),
                             ],
                           ),
                          if (showFarmerName && !compact) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${product.farmerName} • ${product.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                          if (showRating) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                ),
                                const Spacer(),
                                Text(
                                  '${product.quantity.toStringAsFixed(0)} ${product.unit}',
                                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: compact ? 14 : 16,
                                  fontWeight: FontWeight.w900,
                                  color: C.primary,
                                ),
                              ),
                              Text(
                                '/${product.unit}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                              const Spacer(),
                              _AddToCartButton(product: product, inCart: inCart),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.water_drop;
      default:
        return Icons.eco;
    }
  }
}

// ==================== HORIZONTAL PRODUCT CARD ====================

class HorizontalProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel)? onTap;
  final bool showFreshBadge;
  final bool showOrganicBadge;

  const HorizontalProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showFreshBadge = false,
    this.showOrganicBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: () => onTap?.call(product),
      child: Selector<CartProvider, bool>(
        selector: (_, cart) => cart.items.any((item) => item.product.id == product.id),
        builder: (context, inCart, child) {
          return Selector<WishlistProvider, bool>(
            selector: (_, wishlist) => wishlist.isInWishlist(product.id),
            builder: (context, inWishlist, child) {
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: C.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.outlineVariant.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Area
                    Expanded(
                      child: Stack(
                        children: [
                          // Show product image if available, otherwise show icon
                          product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: CachedNetworkImage(
                                    imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (_, __) => Container(
                                      color: C.primaryContainer.withValues(alpha: 0.08),
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: 48,
                                          color: C.primary.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: C.primaryContainer.withValues(alpha: 0.08),
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: 48,
                                          color: C.primary.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: C.primaryContainer.withValues(alpha: 0.08),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(product.category),
                                      size: 48,
                                      color: C.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                          // Badges
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Row(
                              children: [
                                if (product.organic || showOrganicBadge)
                                  _Badge(label: '🌿 Organic', color: const Color(0xFFc8f17a)),
                                if (showFreshBadge) ...[
                                  const SizedBox(width: 4),
                                  _Badge(label: '🌱 Fresh', color: const Color(0xFFFFF9C4)),
                                ],
                              ],
                            ),
                          ),
                          // Wishlist Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _WishlistButton(
                              productId: product.id,
                              inWishlist: inWishlist,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: C.onSurface,
                                ),
                              ),
                              if (product.nameTa.isNotEmpty)
                                Text(
                                  product.nameTa,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: C.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.farmerName} • ${product.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: C.primary,
                                ),
                              ),
                              Text(
                                '/${product.unit}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                              const Spacer(),
                              _AddToCartButton(product: product, inCart: inCart),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.water_drop;
      default:
        return Icons.eco;
    }
  }
}

// ==================== BADGE ====================

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ==================== WISHLIST BUTTON WITH ANIMATION ====================

class _WishlistButton extends StatelessWidget {
  final String productId;
  final bool inWishlist;

  const _WishlistButton({required this.productId, required this.inWishlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<WishlistProvider>().toggleWishlist(productId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            inWishlist ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(inWishlist),
            size: 16,
            color: inWishlist ? C.error : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ==================== ADD TO CART BUTTON WITH BOUNCE ====================

class _AddToCartButton extends StatelessWidget {
  final ProductModel product;
  final bool inCart;

  const _AddToCartButton({required this.product, required this.inCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!inCart) {
          context.read<CartProvider>().addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} | ${product.nameTa} added to cart'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: C.primary,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: inCart ? const Color(0xFFc8f17a) : C.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: inCart
            ? const Icon(Icons.check, size: 12, color: Color(0xFF002b02))
            : const Text(
                'ADD',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
              ),
      ),
    );
  }
}

// ==================== EMPTY STATE WIDGET ====================

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.shopping_bag),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
