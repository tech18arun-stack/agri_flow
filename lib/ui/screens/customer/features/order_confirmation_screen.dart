import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/interactive_card.dart';
import '../../../../widgets/glass_container.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width > 600;
        final iconSize = width * 0.25 > 120 ? 120.0 : width * 0.25;
        final maxWidth = isWide ? 500.0 : double.infinity;

        return Scaffold(
          backgroundColor: C.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 48 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlassContainer(
                        blur: 20,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFbef264).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFbef264)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10)
                            ],
                          ),
                          child: Icon(Icons.check_circle_rounded,
                              size: iconSize * 0.6,
                              color: const Color(0xFF0d631b)),
                        ),
                      ),
                      SizedBox(height: isWide ? 40 : 24),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Order Placed Successfully!',
                          style: TextStyle(
                            fontSize: isWide ? 28 : 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0d631b),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your order has been sent to the farmer. You\'ll receive a confirmation shortly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: isWide ? 16 : 14, color: Colors.grey),
                      ),
                      SizedBox(height: isWide ? 48 : 32),
                      InteractiveCard(
                        scaleFactor: 0.95,
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/', (r) => false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF0d631b), Color(0xFF16A34A)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF16A34A)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Back to Home',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InteractiveCard(
                        scaleFactor: 0.95,
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/customer_orders'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF0d631b)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                  color: Color(0xFF0d631b)),
                              SizedBox(width: 12),
                              Text('View Orders',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0d631b))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
