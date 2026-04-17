import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'dart:ui';
import '../../../widgets/glass_container.dart';
import '../../../widgets/interactive_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _showTamil = false;

  final _slides = const [
    _OnboardingSlide(
      icon: Icons.agriculture_outlined,
      iconBg: C.primaryContainer,
      iconColor: C.onPrimaryContainer,
      title: 'Direct from Farm',
      titleTa: 'நேரடி பண்ணையிலிருந்து',
      subtitle: 'Connect directly with verified farmers across Tamil Nadu',
      subtitleTa:
          'தமிழ்நாடு முழுவதும் சரிபார்க்கப்பட்ட விவசாயிகளுடன் நேரடியாக இணையுங்கள்',
    ),
    _OnboardingSlide(
      icon: Icons.price_check,
      iconBg: C.secondaryContainer,
      iconColor: C.onSecondaryContainer,
      title: 'Live Price Comparison',
      titleTa: 'நிகழ்நேர விலை ஒப்பீடு',
      subtitle: 'Compare prices across districts and find the best deals',
      subtitleTa: 'மாவட்டங்களில் விலைகளை ஒப்பிட்டு சிறந்த Deals கண்டறியுங்கள்',
    ),
    _OnboardingSlide(
      icon: Icons.shopping_basket_outlined,
      iconBg: C.tertiaryContainer,
      iconColor: C.onTertiaryContainer,
      title: 'Order & Deliver',
      titleTa: 'ஆர்டர் மற்றும் விநியோகம்',
      subtitle: 'Fresh produce delivered from farm to your doorstep',
      subtitleTa: 'பண்ணையிலிருந்து உங்கள் வாசல்வரை புதிய விளைபொருட்கள்',
    ),
    _OnboardingSlide(
      icon: Icons.location_on_outlined,
      iconBg: Color(0xFFE0E7FF),
      iconColor: Color(0xFF4338CA),
      title: 'Secure Location',
      titleTa: 'பாதுகாப்பான இடம்',
      subtitle:
          'AgriFlow uses your location to show products and farmers near you. This ensures the freshest produce with minimal transit.',
      subtitleTa:
          'அக்ரிப்ளோ உங்கள் இருப்பிடத்தைப் பயன்படுத்தி உங்களுக்கு அருகிலுள்ள தயாரிப்புகளையும் விவசாயிகளையும் காட்டுகிறது. இது குறைந்த போக்குவரத்து மற்றும் புதிய விளைபொருட்களை உறுதி செய்கிறது.',
    ),
  ];

  Future<void> _finish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      debugPrint('Failed to save onboarding status: $e');
    }
    // Navigate to login screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with heavy blur
          Image.asset(
            'assets/images/agri_bg.png',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar with language toggle
                Padding(
                  padding: Responsive.padH(context, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          _showTamil ? 'தவிர்' : 'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      // Language toggle
                      InteractiveCard(
                        scaleFactor: 0.9,
                        onTap: () => setState(() => _showTamil = !_showTamil),
                        child: GlassContainer(
                          blur: 15,
                          opacity: 0.2,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _showTamil ? 'EN' : 'தமிழ்',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) {
                      final slide = _slides[i];
                      return Padding(
                        padding: Responsive.padH(context, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: w * 0.35,
                              height: w * 0.35,
                              decoration: BoxDecoration(
                                color: slide.iconBg,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        slide.iconColor.withValues(alpha: 0.2),
                                    blurRadius: 32,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                slide.icon,
                                color: slide.iconColor,
                                size: w * 0.18,
                              ),
                            ),
                            SizedBox(height: Responsive.sp(context, 40)),

                            // Title
                            Text(
                              _showTamil ? slide.titleTa : slide.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Responsive.fs(context, 26,
                                    min: 22, max: 32),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (!_showTamil) ...[
                              SizedBox(height: Responsive.sp(context, 4)),
                              Text(
                                slide.titleTa,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Responsive.fs(context, 14,
                                      min: 12, max: 16),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                            SizedBox(height: Responsive.sp(context, 16)),

                            // Subtitle
                            Text(
                              _showTamil ? slide.subtitleTa : slide.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Responsive.fs(context, 14,
                                    min: 12, max: 16),
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom section
                Padding(
                  padding: Responsive.padH(context, 24)
                      .copyWith(bottom: Responsive.sp(context, 32)),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final isActive = _currentPage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isActive ? 32 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? C.primary
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                          color:
                                              C.primary.withValues(alpha: 0.5),
                                          blurRadius: 10)
                                    ]
                                  : [],
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: Responsive.sp(context, 32)),

                      // CTA Button
                      InteractiveCard(
                        scaleFactor: 0.96,
                        onTap: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finish();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: C.silkGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: C.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _slides.length - 1
                                    ? (_showTamil ? 'அடுத்தது' : 'Next')
                                    : (_showTamil
                                        ? 'தொடங்குங்கள்'
                                        : 'Get Started'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: C.onPrimary,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < _slides.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.task_alt_rounded,
                                color: C.onPrimary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, titleTa, subtitle, subtitleTa;
  const _OnboardingSlide({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.titleTa,
    required this.subtitle,
    required this.subtitleTa,
  });
}
