import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models.dart';
import '../../../../services/appwrite_service.dart';
import '../../../../services/appwrite_config.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../widgets/interactive_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cod';
  bool _processing = false;
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _labelCtrl = TextEditingController(text: 'Home');

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();
    if (cartProv.items.isEmpty || _addressCtrl.text.isEmpty) return;

    setState(() => _processing = true);

    try {
      if (!AppwriteService.instance.isInitialized) {
        await AppwriteService.instance.init();
      }

      if (!mounted) return;
      final user = auth.user;
      final products = context.read<ProductProvider>().all;

      // Group items by farmer
      final farmerGroups = <String, List<CartItem>>{};
      for (final item in cartProv.items) {
        farmerGroups.putIfAbsent(item.product.farmerId, () => []).add(item);
      }

      for (final entry in farmerGroups.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;
        final farmerProduct = farmerItems.first.product;

        final orderItems = farmerItems
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'productImageUrl': item.product.imageUrl ?? '',
                  'price': item.product.price,
                  'quantity': item.quantity,
                })
            .toList();

        final total = farmerItems.fold(0.0, (sum, item) => sum + item.total);

        await AppwriteService.instance.db.createDocument(
          databaseId: AppwriteService.instance.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          documentId: ID.unique(),
          data: {
            'customerId': user?.id ?? '',
            'customerName': user?.name ?? '',
            'farmerId': farmerId,
            'farmerName': farmerProduct.farmerName,
            'items': orderItems,
            'total': total,
            'totalAmount': total, // For admin compatibility
            'status': 'pending',
            'shippingAddress': _addressCtrl.text,
            'paymentMethod': _paymentMethod,
            'phone': _phoneCtrl.text,
            'city': _cityCtrl.text,
            'pincode': _pincodeCtrl.text,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );

        // Update farmer stock quantities
        for (final item in farmerItems) {
          final productDoc = products.firstWhere((p) => p.id == item.product.id);
          final newQty = productDoc.quantity - item.quantity;
          if (newQty >= 0) {
            try {
              await AppwriteService.instance.db.updateDocument(
                databaseId: AppwriteService.instance.databaseId,
                collectionId: AppwriteConfig.productsCollectionId,
                documentId: item.product.id,
                data: {'quantity': newQty},
              );
            } catch (_) {}
          }
        }
      }

      cartProv.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/order_confirmation', (r) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _LuxuryCheckoutHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1000) {
                  return _ResponsiveCheckoutLayout(
                    cart: cart,
                    processing: _processing,
                    onPlaceOrder: _placeOrder,
                    addressCtrl: _addressCtrl,
                    phoneCtrl: _phoneCtrl,
                    cityCtrl: _cityCtrl,
                    pincodeCtrl: _pincodeCtrl,
                    labelCtrl: _labelCtrl,
                    paymentMethod: _paymentMethod,
                    onPaymentMethodChanged: (val) => setState(() => _paymentMethod = val),
                  );
                }
                return _StandardCheckoutLayout(
                  cart: cart,
                  processing: _processing,
                  onPlaceOrder: _placeOrder,
                  addressCtrl: _addressCtrl,
                  phoneCtrl: _phoneCtrl,
                  cityCtrl: _cityCtrl,
                  pincodeCtrl: _pincodeCtrl,
                  labelCtrl: _labelCtrl,
                  paymentMethod: _paymentMethod,
                  onPaymentMethodChanged: (val) => setState(() => _paymentMethod = val),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryCheckoutHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          InteractiveCard(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF14532D)),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Secure Checkout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              Text('FINALIZE YOUR FARM-TO-TABLE ORDER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StandardCheckoutLayout extends StatelessWidget {
  final CartProvider cart;
  final bool processing;
  final VoidCallback onPlaceOrder;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController pincodeCtrl;
  final TextEditingController labelCtrl;
  final String paymentMethod;
  final Function(String) onPaymentMethodChanged;

  const _StandardCheckoutLayout({
    required this.cart,
    required this.processing,
    required this.onPlaceOrder,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.pincodeCtrl,
    required this.labelCtrl,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckoutForm(
                  addressCtrl: addressCtrl,
                  phoneCtrl: phoneCtrl,
                  cityCtrl: cityCtrl,
                  pincodeCtrl: pincodeCtrl,
                  labelCtrl: labelCtrl,
                ),
                const SizedBox(height: 32),
                _PaymentSelector(
                  selected: paymentMethod,
                  onChanged: onPaymentMethodChanged,
                ),
                const SizedBox(height: 32),
                _OrderSummaryCard(cart: cart),
              ],
            ),
          ),
        ),
        _BottomActionBar(processing: processing, onPlaceOrder: onPlaceOrder, cart: cart, isFormValid: addressCtrl.text.isNotEmpty),
      ],
    );
  }
}

class _ResponsiveCheckoutLayout extends StatelessWidget {
  final CartProvider cart;
  final bool processing;
  final VoidCallback onPlaceOrder;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController pincodeCtrl;
  final TextEditingController labelCtrl;
  final String paymentMethod;
  final Function(String) onPaymentMethodChanged;

  const _ResponsiveCheckoutLayout({
    required this.cart,
    required this.processing,
    required this.onPlaceOrder,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.pincodeCtrl,
    required this.labelCtrl,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckoutForm(
                  addressCtrl: addressCtrl,
                  phoneCtrl: phoneCtrl,
                  cityCtrl: cityCtrl,
                  pincodeCtrl: pincodeCtrl,
                  labelCtrl: labelCtrl,
                ),
                const SizedBox(height: 40),
                _PaymentSelector(
                  selected: paymentMethod,
                  onChanged: onPaymentMethodChanged,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                _OrderSummaryCard(cart: cart),
                const SizedBox(height: 40),
                _ActionCard(processing: processing, onPlaceOrder: onPlaceOrder, cart: cart, isFormValid: addressCtrl.text.isNotEmpty),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutForm extends StatelessWidget {
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController pincodeCtrl;
  final TextEditingController labelCtrl;

  const _CheckoutForm({
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.pincodeCtrl,
    required this.labelCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SHIPPING LOGISTICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Column(
            children: [
              _PremiumField(label: 'ADDRESS LABEL', controller: labelCtrl, icon: Icons.bookmark_rounded, hint: 'e.g. Home, Office'),
              const SizedBox(height: 20),
              _PremiumField(label: 'FULL DELIVERY ADDRESS', controller: addressCtrl, icon: Icons.location_on_rounded, hint: 'Street, House Number', maxLines: 2),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _PremiumField(label: 'CITY', controller: cityCtrl, icon: Icons.apartment_rounded, hint: 'e.g. Coimbatore')),
                  const SizedBox(width: 16),
                  Expanded(child: _PremiumField(label: 'PINCODE', controller: pincodeCtrl, icon: Icons.pin_drop_rounded, hint: '641001', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              _PremiumField(label: 'CONTACT NUMBER', controller: phoneCtrl, icon: Icons.phone_android_rounded, hint: '+91 98765 43210', keyboardType: TextInputType.phone),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _PremiumField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF), letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB), fontWeight: FontWeight.w400),
              prefixIcon: Icon(icon, color: const Color(0xFF14532D), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _PaymentSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SECURE PAYMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _PaymentCard(
          title: 'CASH ON DELIVERY',
          subtitle: 'Pay at your doorstep after verification',
          icon: Icons.payments_rounded,
          isSelected: selected == 'cod',
          onTap: () => onChanged('cod'),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          title: 'DIGITAL WALLET',
          subtitle: 'Instant farm-direct payments',
          icon: Icons.account_balance_wallet_rounded,
          isSelected: selected == 'digital',
          onTap: () => onChanged('digital'),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentCard({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF14532D) : const Color(0xFFF3F4F6), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF14532D) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF9CA3AF), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isSelected ? const Color(0xFF14532D) : const Color(0xFF1F2937))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF14532D)),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER OVERVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1.5)),
          const SizedBox(height: 20),
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text('${item.quantity}x', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)))),
                    Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                  ],
                ),
              )),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF3F4F6))),
          _SummaryLine(label: 'BASKET TOTAL', value: '₹${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _SummaryLine(label: 'MARKET DELIVERY', value: '₹${cart.shipping.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _SummaryLine(label: 'TAXES & FEES', value: '₹${cart.platformFee.toStringAsFixed(0)}'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              Text('₹${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF14532D))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final bool processing;
  final VoidCallback onPlaceOrder;
  final CartProvider cart;
  final bool isFormValid;

  const _BottomActionBar({required this.processing, required this.onPlaceOrder, required this.cart, required this.isFormValid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))]),
      child: SafeArea(top: false, child: _ActionCardContent(processing: processing, onPlaceOrder: onPlaceOrder, cart: cart, isFormValid: isFormValid)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final bool processing;
  final VoidCallback onPlaceOrder;
  final CartProvider cart;
  final bool isFormValid;

  const _ActionCard({required this.processing, required this.onPlaceOrder, required this.cart, required this.isFormValid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: _ActionCardContent(processing: processing, onPlaceOrder: onPlaceOrder, cart: cart, isFormValid: isFormValid),
    );
  }
}

class _ActionCardContent extends StatelessWidget {
  final bool processing;
  final VoidCallback onPlaceOrder;
  final CartProvider cart;
  final bool isFormValid;

  const _ActionCardContent({required this.processing, required this.onPlaceOrder, required this.cart, required this.isFormValid});

  @override
  Widget build(BuildContext context) {
    final enabled = !processing && cart.items.isNotEmpty && isFormValid;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InteractiveCard(
          onTap: enabled ? onPlaceOrder : () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFF14532D) : const Color(0xFF9CA3AF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: enabled ? [BoxShadow(color: const Color(0xFF14532D).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))] : [],
            ),
            child: Center(
              child: processing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('CONFIRM & PAY NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            ),
          ),
        ),
        if (!isFormValid) ...[
          const SizedBox(height: 12),
          const Text('PLEASE PROVIDE DELIVERY ADDRESS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFEF4444), letterSpacing: 1)),
        ],
      ],
    );
  }
}
