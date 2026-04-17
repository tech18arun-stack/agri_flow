import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../widgets/interactive_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models.dart';

/// Full-featured Cart Screen replacing the previous stub route.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      body: Column(
        children: [
          // Glassy Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064e3b), Color(0xFF065f46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'MY CART',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5),
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, _) => cart.itemCount > 0
                      ? InteractiveCard(
                          onTap: () => _confirmClearCart(context, cart),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete_sweep_rounded,
                                color: Colors.white, size: 20),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.itemCount == 0) {
                  return _EmptyCartState(onShop: () => Navigator.pop(context));
                }
                return _CartBody(cart: cart);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: C.error, foregroundColor: Colors.white),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  final CartProvider cart;
  const _CartBody({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: cart.items.length,
            itemBuilder: (context, i) {
              final item = cart.items[i];
              return _CartItemTile(item: item, cart: cart);
            },
          ),
        ),
        _OrderSummaryPanel(cart: cart),
      ],
    );
  }
}

// Cart item tile with quantity stepper + swipe-to-remove
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;
  const _CartItemTile({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        cart.removeItem(item.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed'),
            backgroundColor: const Color(0xFF064e3b),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.red, size: 28),
      ),
      child: InteractiveCard(
        scaleFactor: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.product.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: categoryColor(item.product.category).withValues(alpha: 0.1),
                          child: Center(
                            child: Icon(categoryIcon(item.product.category), size: 24, color: categoryColor(item.product.category).withValues(alpha: 0.3)),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: categoryColor(item.product.category).withValues(alpha: 0.1),
                          child: Center(
                            child: Icon(categoryIcon(item.product.category), size: 24, color: categoryColor(item.product.category)),
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: categoryColor(item.product.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(categoryIcon(item.product.category), size: 30, color: categoryColor(item.product.category)),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF064e3b)),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BY ${item.product.farmerName.toUpperCase()}',
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF064e3b)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (item.product.farmerPhone != null && item.product.farmerPhone!.isNotEmpty) {
                    final url = Uri.parse('tel:${item.product.farmerPhone}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Farmer contact not available')),
                    );
                  }
                },
                icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0d631b), size: 18),
                tooltip: 'Call Farmer',
              ),
              _QuantityStepper(item: item, cart: cart),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;
  const _QuantityStepper({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              cart.decrementItem(item.product.id);
            },
          ),
          const SizedBox(width: 12),
          Text(
            '${item.quantity}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF064e3b)),
          ),
          const SizedBox(width: 12),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              cart.incrementItem(item.product.id);
            },
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: C.primary),
        ),
      ),
    );
  }
}

// Order summary panel at bottom
class _OrderSummaryPanel extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummaryPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -10)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _CostRow(
                label: 'SUBTOTAL',
                value: '₹${cart.subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            _CostRow(
                label: 'SHIPPING',
                value: '₹${cart.shipping.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            _CostRow(
                label: 'TAXES',
                value: '₹${cart.platformFee.toStringAsFixed(0)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),
            _CostRow(
                label: 'TOTAL AMOUNT',
                value: '₹${cart.total.toStringAsFixed(0)}',
                isTotal: true),
            const SizedBox(height: 24),
            InteractiveCard(
              onTap: () => Navigator.pushNamed(context, '/checkout'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF064e3b), Color(0xFF065f46)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF064e3b).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'COMPLETE ORDER',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _CostRow(
      {required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? C.onSurface : C.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? C.primary : C.onSurface,
          ),
        ),
      ],
    );
  }
}

// Empty cart state
class _EmptyCartState extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCartState({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: C.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 72, color: C.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: C.onSurface),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add fresh produce from farmers\nto get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: C.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onShop,
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Browse Products'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
