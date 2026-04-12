import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// A responsive container that:
/// - Constrains max width to 1200px on wide screens
/// - Applies responsive padding
/// - Centers content on wide screens
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const ResponsiveScreen({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Container(
          color: C.background,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? maxWidth : double.infinity),
              child: Padding(
                padding: isWide ? padding : padding.copyWith(
                  left: 12,
                  right: 12,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Responsive grid that adapts column count to screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final int minColumns;
  final int maxColumns;
  final double maxColumnWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 0.8,
    this.minColumns = 1,
    this.maxColumns = 5,
    this.maxColumnWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _computeColumns(width, maxColumnWidth).clamp(minColumns, maxColumns);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _computeColumns(double width, double maxColWidth) {
    final count = (width / maxColWidth).ceil();
    return count.clamp(1, maxColumns);
  }
}

/// Responsive stat cards that stack vertically on narrow screens
class ResponsiveStatRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveStatRow({
    super.key,
    required this.children,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            children: children.expand((child) => [child, SizedBox(height: spacing)]).toList()
              ..removeLast(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .expand((child) => [Expanded(child: child), SizedBox(width: spacing)])
              .toList()
            ..removeLast(),
        );
      },
    );
  }
}
