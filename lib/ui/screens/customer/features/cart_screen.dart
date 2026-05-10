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

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.itemCount == 0) {
            return _EmptyCartState(onShop: () {
              // If we can pop, pop. Otherwise, we might be in a tab.
              // In this app, we assume index 0 is home.
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // If we are in the Cart tab, we need to signal the parent to switch tabs.
                // For now, simple pop or just letting it be is fine if it's a tab.
                // But better UX: if it's a tab, we don't 'pop'.
              }
            });
          }

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _LuxuryCartSliverHeader(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 220),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _CartItemCard(item: cart.items[i], cart: cart),
                        childCount: cart.items.length,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _OrderSummaryPanel(cart: cart),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LuxuryCartSliverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final canPop = Navigator.canPop(context);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            if (canPop)
              InteractiveCard(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
                ),
              )
            else
              // Fallback icon for tab-based view
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_basket_rounded, size: 18, color: Color(0xFF14532D)),
              ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Basket',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                ),
                Text(
                  'FARMFLOW PREMIUM CURATION',
                  style: TextStyle(
                    fontSize: 8, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5, 
                    color: Color(0xFF6B7280)
                  ),
                ),
              ],
            ),
            const Spacer(),
            Consumer<CartProvider>(
              builder: (context, cart, _) => cart.itemCount > 0
                  ? InteractiveCard(
                      onTap: () => _confirmClearCart(context, cart),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 8),
                            Text(
                              'CLEAR',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Empty Basket?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        content: const Text('This will remove all premium items from your selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('EMPTY NOW', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;
  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.removeItem(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(32)),
        child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 32),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            _ProductThumb(product: item.product),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                  ),
                  Text(
                    'FROM ${item.product.farmerName.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9, 
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF14532D), 
                      letterSpacing: 0.5
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w900, 
                          color: Color(0xFF111827), 
                          letterSpacing: -1
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'total',
                        style: TextStyle(
                          fontSize: 9, 
                          color: Colors.grey.shade400, 
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _QuantityStepper(item: item, cart: cart),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final ProductModel product;
  const _ProductThumb({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
              )
            : Icon(CategoryUtils.getIcon(product.category), size: 28, color: const Color(0xFFD1D5DB)),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _StepBtn(icon: Icons.add_rounded, onTap: () => cart.incrementItem(item.product.id)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
          ),
          _StepBtn(icon: Icons.remove_rounded, onTap: () => cart.decrementItem(item.product.id)),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
          ],
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF14532D)),
      ),
    );
  }
}

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
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, -10)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Basket Value', value: '₹${cart.subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Logistics & Handling', value: '₹${cart.shipping.toStringAsFixed(0)}'),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF3F4F6))),
            _SummaryRow(label: 'Estimated Total', value: '₹${cart.total.toStringAsFixed(0)}', isTotal: true),
            const SizedBox(height: 24),
            InteractiveCard(
              onTap: () {
                if (context.read<AuthProvider>().isGuest) {
                  _showGuestLoginDialog(context);
                } else {
                  Navigator.pushNamed(context, '/checkout');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14532D), Color(0xFF064E3B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14532D).withValues(alpha: 0.25), 
                      blurRadius: 20, 
                      offset: const Offset(0, 8)
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    context.watch<AuthProvider>().isGuest ? 'LOGIN TO CHECKOUT' : 'PROCEED TO CHECKOUT',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 15, 
                      letterSpacing: 1
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Identity Required', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('To ensure secure farm-to-table delivery, please sign in to your FarmFlow account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('LATER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: isTotal ? 16 : 13, 
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600, 
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280)
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontSize: isTotal ? 22 : 14, 
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700, 
            color: isTotal ? const Color(0xFF14532D) : const Color(0xFF1F2937)
          )
        ),
      ],
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCartState({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4), 
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF14532D).withValues(alpha: 0.1), width: 2),
              ),
              child: const Icon(Icons.shopping_basket_outlined, size: 80, color: Color(0xFF14532D)),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your basket is empty', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore the curated marketplace to find fresh, premium produce directly from the farm.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
            ),
            const SizedBox(height: 40),
            InteractiveCard(
              onTap: onShop,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14532D).withValues(alpha: 0.2), 
                      blurRadius: 20, 
                      offset: const Offset(0, 10)
                    ),
                  ],
                ),
                child: const Text(
                  'START SHOPPING', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
