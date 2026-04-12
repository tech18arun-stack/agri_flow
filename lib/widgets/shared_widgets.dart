import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/utils/responsive.dart';

/// Bilingual label: English + Tamil
class BiLabel extends StatelessWidget {
  final String en, ta;
  final double enSize;
  final double? taSize;
  final FontWeight enWeight;
  final Color? enColor;
  final Color? taColor;
  const BiLabel({
    required this.en, required this.ta,
    this.enSize = 14, this.taSize, this.enWeight = FontWeight.w700,
    this.enColor, this.taColor, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(en, style: TextStyle(fontSize: enSize, fontWeight: enWeight, color: enColor)),
        Text(ta, style: TextStyle(fontSize: taSize ?? enSize - 2, color: taColor ?? C.onSurfaceVariant)),
      ],
    );
  }
}

/// Primary button with gradient or outline
class PrimaryButton extends StatelessWidget {
  final String en, ta;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outlined;
  const PrimaryButton({required this.en, required this.ta, required this.onTap, this.icon, this.outlined = false, super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.pctW(context, 0.9);
    return SizedBox(
      width: w,
      child: Material(
        color: outlined ? Colors.transparent : C.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: outlined ? BorderSide(color: C.primary) : BorderSide.none),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.sp(context, 14, min: 12, max: 18)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, color: outlined ? C.primary : C.onPrimary, size: Responsive.fs(context, 18)), const SizedBox(width: 8)],
                Flexible(child: Text(en, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.fs(context, 14), fontWeight: FontWeight.w700, color: outlined ? C.primary : C.onPrimary))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stat card for dashboard bento grid
class StatCard extends StatelessWidget {
  final String en, ta, value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  const StatCard({required this.en, required this.ta, required this.value, this.subtitle, required this.icon, this.accentColor, super.key});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? C.primary;
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 12, min: 10, max: 16)),
      decoration: BoxDecoration(
        color: C.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.sp(context, 6, min: 4, max: 10)),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Responsive.radius(context, 8))),
            child: Icon(icon, color: color, size: Responsive.fs(context, 16, min: 14, max: 24)),
          ),
          Text(value, style: TextStyle(fontSize: Responsive.fs(context, 18, min: 14, max: 28), fontWeight: FontWeight.w800, color: color)),
          Text(en, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.fs(context, 9, min: 8, max: 11), color: C.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Status badge chip
class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const StatusBadge({required this.status, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.sp(context, 6, min: 4, max: 8), vertical: Responsive.sp(context, 2, min: 2, max: 4)),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: Responsive.fs(context, 8, min: 7, max: 10), fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Gradient box for hero/CTA sections
class GradientBox extends StatelessWidget {
  final Widget child;
  final double? height;
  const GradientBox({required this.child, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(Responsive.sp(context, 20, min: 16, max: 28)),
      decoration: BoxDecoration(gradient: C.silkGradient, borderRadius: BorderRadius.circular(Responsive.radius(context, 20))),
      child: child,
    );
  }
}

/// Empty state placeholder
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const EmptyStateWidget({required this.icon, required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.sp(context, 40, min: 32, max: 48)),
      decoration: BoxDecoration(color: C.surfaceContainerLow, borderRadius: BorderRadius.circular(Responsive.radius(context, 20))),
      child: Column(
        children: [
          Icon(icon, size: Responsive.fs(context, 48, min: 36, max: 64), color: C.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: Responsive.sp(context, 12, min: 8, max: 16)),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: Responsive.fs(context, 14), fontWeight: FontWeight.w600, color: C.onSurfaceVariant)),
          SizedBox(height: Responsive.sp(context, 4, min: 2, max: 8)),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: Responsive.fs(context, 11), color: C.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

/// Responsive helpers
bool isWeb(BuildContext context) => Responsive.isDesktop(context);
bool isTablet(BuildContext context) => Responsive.isTablet(context);
bool isPhone(BuildContext context) => Responsive.isPhone(context);
EdgeInsets adaptivePadding(BuildContext context) => Responsive.padH(context, 16).copyWith(top: Responsive.sp(context, 12), bottom: Responsive.sp(context, 24));
