import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../providers/providers.dart';
import '../../../../core/constants/colors.dart';
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
      if (!AppwriteService.instance.isInitialized)
        await AppwriteService.instance.init();

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
          final productDoc =
              products.firstWhere((p) => p.id == item.product.id);
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

      // Clear cart
      cartProv.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/order_confirmation', (r) => false);
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Order failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
                    'CHECKOUT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Section
                  _buildModernSectionHeader('SHIPPING DESTINATION'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        _buildPremiumField(_labelCtrl, 'LOCATION LABEL',
                            Icons.label_important_rounded),
                        const SizedBox(height: 16),
                        _buildPremiumField(_addressCtrl, 'STREET ADDRESS',
                            Icons.location_on_rounded,
                            maxLines: 2),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildPremiumField(_cityCtrl, 'CITY',
                                    Icons.apartment_rounded)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildPremiumField(_pincodeCtrl,
                                    'PINCODE', Icons.pin_drop_rounded,
                                    keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumField(
                            _phoneCtrl, 'CONTACT NUMBER', Icons.phone_rounded,
                            keyboardType: TextInputType.phone),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Payment Section
                  _buildModernSectionHeader('PAYMENT METHOD'),
                  const SizedBox(height: 16),
                  _PaymentOption(
                    value: 'cod',
                    selected: _paymentMethod == 'cod',
                    icon: Icons.payments_rounded,
                    title: 'CASH ON DELIVERY',
                    subtitle: 'Secure payment at your doorstep',
                    onTap: () => setState(() => _paymentMethod = 'cod'),
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    value: 'upi',
                    selected: _paymentMethod == 'upi',
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'DIGITAL UPI',
                    subtitle: 'Instant secure checkout via UPI',
                    onTap: () => setState(() => _paymentMethod = 'upi'),
                  ),
                  const SizedBox(height: 32),

                  // Final Summary
                  _buildModernSectionHeader('ORDER SUMMARY'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        ...cart.items.map((item) => _OrderItemTile(item: item)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildCostRow(
                            'SUBTOTAL', '₹${cart.subtotal.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _buildCostRow(
                            'SHIPPING', '₹${cart.shipping.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _buildCostRow(
                            'TAXES', '₹${cart.platformFee.toStringAsFixed(0)}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildCostRow('TOTAL PAYABLE',
                            '₹${cart.total.toStringAsFixed(0)}',
                            isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Place Order Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -10)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: InteractiveCard(
                onTap: _processing ||
                        cart.items.isEmpty ||
                        _addressCtrl.text.isEmpty
                    ? () {}
                    : _placeOrder,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: (_processing ||
                            cart.items.isEmpty ||
                            _addressCtrl.text.isEmpty)
                        ? LinearGradient(colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400
                          ])
                        : const LinearGradient(
                            colors: [Color(0xFF064e3b), Color(0xFF065f46)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: (_processing ||
                            cart.items.isEmpty ||
                            _addressCtrl.text.isEmpty)
                        ? []
                        : [
                            BoxShadow(
                                color: const Color(0xFF064e3b)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8)),
                          ],
                  ),
                  child: _processing
                      ? const Center(
                          child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3)))
                      : const Center(
                          child: Text(
                            'PLACE ORDER NOW',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 1.5),
    );
  }

  Widget _buildPremiumField(
      TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100)),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5),
          prefixIcon: Icon(icon, color: const Color(0xFF064e3b), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isTotal ? 14 : 11,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
              color: isTotal ? const Color(0xFF064e3b) : Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: isTotal ? 18 : 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF064e3b)),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaymentOption(
      {required this.value,
      required this.selected,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF064e3b).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? const Color(0xFF064e3b) : Colors.grey.shade100,
              width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF064e3b) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : const Color(0xFF064e3b),
                  size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color:
                            selected ? const Color(0xFF064e3b) : Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF064e3b), size: 24),
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final CartItem item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF064e3b).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(item.product.category),
                color: const Color(0xFF064e3b), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF064e3b)),
                ),
                Text(
                  '${item.quantity} ${item.product.unit} × ₹${item.product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF064e3b)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) => categoryIcon(category);
}
