import 'package:flutter/material.dart';
import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _dotsOpacity;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _bgController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // Logo animation (scale + fade)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Loading dots animation
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _dotsOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeInOut),
    );

    // Start animations in sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });

    // Load app version
    _loadVersion();

    // Navigate after delay
    _navigate();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = 'v${info.version}');
      }
    } catch (e) {
      // Ignore version loading errors
    }
  }

  Future<void> _navigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final auth = context.read<AuthProvider>();

      debugPrint(
          '💧 Splash Check: hasSeenOnboarding=$hasSeenOnboarding, isLoggedIn=${auth.isLoggedIn}');

      if (!mounted) return;

      if (auth.isLoggedIn) {
        debugPrint('💧 Splash → User logged in, going to home');
        Navigator.pushReplacementNamed(context, '/');
      } else if (hasSeenOnboarding) {
        debugPrint('💧 Splash → /login');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        debugPrint('💧 Splash → /onboarding');
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      debugPrint('💧 Splash nav error: $e — falling back to /login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background Gradient
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      C.primary,
                      C.primaryContainer,
                      const Color(0xFF2e7d32),
                    ],
                    stops: [
                      0.0,
                      _bgController.value * 0.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Background Pattern
          Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: _GridPainter(),
              child: Container(),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: GlassContainer(
                            blur: 20,
                            opacity: 0.15,
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 76,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Title
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _titleFade,
                      child: const Text(
                        'Agri Flow',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Subtitle
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'Farm to Market Direct',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // Loading Indicator with animated dots
                AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _dotsOpacity.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Version
                if (_appVersion.isNotEmpty)
                  Text(
                    _appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid pattern painter for background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
