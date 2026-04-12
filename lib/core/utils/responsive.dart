import 'package:flutter/material.dart';

/// Responsive utility functions based on screen size
/// No external packages needed -- uses MediaQuery + LayoutBuilder
class Responsive {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isPhone(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1200;
  static bool isDesktop(BuildContext context) => width(context) >= 1200;

  /// Responsive font size: scales with screen width, clamped between min and max
  static double fs(BuildContext context, double base, {double min = 10, double max = 48}) {
    final scaled = width(context) * base / 375;
    return scaled.clamp(min, max);
  }

  /// Responsive spacing: scales with screen width
  static double sp(BuildContext context, double base, {double min = 4, double max = 64}) {
    final scaled = width(context) * base / 375;
    return scaled.clamp(min, max);
  }

  /// Responsive padding: scales with screen width
  static EdgeInsets pad(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.all(scaled.clamp(4.0, 32.0));
  }

  /// Responsive horizontal padding
  static EdgeInsets padH(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.symmetric(horizontal: scaled.clamp(8.0, 48.0));
  }

  /// Responsive vertical padding
  static EdgeInsets padV(BuildContext context, double base) {
    final scaled = width(context) * base / 375;
    return EdgeInsets.symmetric(vertical: scaled.clamp(4.0, 32.0));
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
