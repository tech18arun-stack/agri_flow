import 'package:flutter/material.dart';

/// Responsive utility functions based on screen size
/// No external packages needed -- uses MediaQuery + LayoutBuilder
class Responsive {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isPhone(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1200;
  static bool isDesktop(BuildContext context) => width(context) >= 1200;
  
  static Orientation orientation(BuildContext context) => MediaQuery.of(context).orientation;
  static bool isLandscape(BuildContext context) => orientation(context) == Orientation.landscape;

  /// Responsive font size: scales with screen width, clamped between min and max
  static double fs(BuildContext context, double size) {
    final scale = width(context) / 390;
    // Tighter clamp for landscape to prevent huge text
    final landscapeMod = isLandscape(context) ? 0.85 : 1.0;
    return (size * scale * landscapeMod).clamp(size * 0.85, size * 1.2);
  }

  /// Responsive spacing: scales with screen width
  static double sp(BuildContext context, double base, {double min = 4, double max = 64}) {
    final scale = width(context) / 375;
    return (base * scale).clamp(min, max);
  }

  /// Responsive padding: scales with screen width
  static EdgeInsets pad(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.all(scaled.clamp(4.0, 32.0));
  }

  /// Responsive horizontal padding
  static EdgeInsets padH(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.symmetric(horizontal: scaled.clamp(base * 0.8, base * 2.0));
  }

  /// Responsive vertical padding
  static EdgeInsets padV(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.symmetric(vertical: scaled.clamp(base * 0.5, base * 1.5));
  }

  /// Dynamic grid column count based on screen width
  static int gridCount(BuildContext context, {int phone = 2, int tablet = 3, int desktop = 4}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return phone;
  }

  /// Responsive height as percentage of screen height
  static double pctH(BuildContext context, double pct) => height(context) * pct;

  /// Responsive width as percentage of screen width
  static double pctW(BuildContext context, double pct) => width(context) * pct;

  /// Card aspect ratio based on screen size
  static double cardAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 1.6;
    if (isTablet(context)) return 1.3;
    return 1.1;
  }

  /// Border radius that scales with screen
  static double radius(BuildContext context, double base, {double max = 32}) {
    return (width(context) * base / 375).clamp(8.0, max);
  }
}
