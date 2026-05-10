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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0E8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Area
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: _buildImage(context),
                            ),
                          ),
                          // Gradient Overlay for better badge visibility
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.0, 0.2, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Badges
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.organic)
                                  _Badge(
                                    label: 'ORGANIC',
                                    icon: Icons.eco_rounded,
                                    color: const Color(0xFFE8F5E9),
                                    textColor: const Color(0xFF2E7D32),
                                  ),
                                if (product.quantity < 10)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: _Badge(
                                      label: 'LOW STOCK',
                                      icon: Icons.warning_amber_rounded,
                                      color: const Color(0xFFFFF3E0),
                                      textColor: const Color(0xFFE65100),
                                    ),
                                  ),
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
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (product.nameTa.isNotEmpty)
                              Text(
                                product.nameTa,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D6A35),
                                ),
                              ),
                            const Spacer(flex: 1),
                            if (showFarmerName && !compact)
                              Text(
                                product.farmerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1A1A1A),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'per ${product.unit}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _AddToCartButton(product: product, inCart: inCart),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return _PlaceholderImage(category: product.category);
    }

    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      placeholder: (context, url) => _PlaceholderImage(category: product.category, isShimmer: true),
      errorWidget: (context, url, error) => _PlaceholderImage(category: product.category),
    );
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
                width: 280,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0E8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image Section
                    Stack(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                            child: _buildImage(context),
                          ),
                        ),
                        if (showFreshBadge || product.organic)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _Badge(
                              label: showFreshBadge ? 'FRESH' : 'ORGANIC',
                              icon: showFreshBadge ? Icons.auto_awesome : Icons.eco,
                              color: showFreshBadge ? const Color(0xFFFFF9C4) : const Color(0xFFE8F5E9),
                              textColor: showFreshBadge ? const Color(0xFFF9A825) : const Color(0xFF2E7D32),
                              compact: true,
                            ),
                          ),
                      ],
                    ),
                    // Info Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${product.farmerName} • ${product.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF2D6A35),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'per ${product.unit}',
                                        style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _AddToCartButton(product: product, inCart: inCart),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildImage(BuildContext context) {
    if (product.imageUrl == null || product.imageUrl!.isEmpty) {
      return _PlaceholderImage(category: product.category);
    }

    return CachedNetworkImage(
      imageUrl: ImageUrlUtils.normalizeImageUrl(product.imageUrl!),
      fit: BoxFit.cover,
      placeholder: (context, url) => _PlaceholderImage(category: product.category, isShimmer: true),
      errorWidget: (context, url, error) => _PlaceholderImage(category: product.category),
    );
  }
}

// ==================== PLACEHOLDER IMAGE ====================

class _PlaceholderImage extends StatelessWidget {
  final String category;
  final bool isShimmer;

  const _PlaceholderImage({required this.category, this.isShimmer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 32,
              color: const Color(0xFF2D6A35).withValues(alpha: isShimmer ? 0.05 : 0.15),
            ),
            if (!isShimmer) ...[
              const SizedBox(height: 4),
              Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D6A35).withValues(alpha: 0.3),
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables': return Icons.grass_rounded;
      case 'fruits': return Icons.apple_rounded;
      case 'flowers': return Icons.local_florist_rounded;
      case 'seeds': return Icons.spa_rounded;
      default: return Icons.eco_rounded;
    }
  }
}

// ==================== BADGE ====================

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final bool compact;

  const _Badge({
    required this.label,
    this.icon,
    required this.color,
    required this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 8 : 10, color: textColor),
            SizedBox(width: compact ? 2 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 7 : 8,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
    return TapScaleAnimation(
      onTap: () {
        context.read<WishlistProvider>().toggleWishlist(productId);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            inWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            key: ValueKey(inWishlist),
            size: 18,
            color: inWishlist ? const Color(0xFFE53935) : const Color(0xFF757575),
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
    return TapScaleAnimation(
      onTap: () {
        if (!inCart) {
          context.read<CartProvider>().addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2D6A35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(inCart ? 8 : 10),
        decoration: BoxDecoration(
          color: inCart ? const Color(0xFFE8F5E9) : const Color(0xFF2D6A35),
          shape: BoxShape.circle,
          boxShadow: [
            if (!inCart)
              BoxShadow(
                color: const Color(0xFF2D6A35).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(
          inCart ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
          size: 16,
          color: inCart ? const Color(0xFF2D6A35) : Colors.white,
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
