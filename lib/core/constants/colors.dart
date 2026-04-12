import 'package:flutter/material.dart';

/// AgriFlow Living Ledger Design Tokens
/// Based on Material 3 with editorial agricultural theme
/// Primary: deep green (#0d631b) | Surface: cream (#fbfbe2) | Tertiary: burnt orange (#8d3f00)
class C {
  // Primary: deep forest green (matches HTML #0d631b)
  static const primary = Color(0xFF0d631b);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2e7d32);
  static const onPrimaryContainer = Color(0xFFcbffc2);
  static const primaryFixed = Color(0xFFa3f69c);
  static const primaryFixedDim = Color(0xFF88d982);
  static const onPrimaryFixed = Color(0xFF002204);
  static const onPrimaryFixedVariant = Color(0xFF005312);

  // Secondary: sage green
  static const secondary = Color(0xFF3e6837);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFbef0b1);
  static const onSecondaryContainer = Color(0xFF436f3c);
  static const secondaryFixed = Color(0xFFbef0b1);
  static const secondaryFixedDim = Color(0xFFa3d396);
  static const onSecondaryFixed = Color(0xFF002201);
  static const onSecondaryFixedVariant = Color(0xFF265021);

  // Tertiary: burnt orange / amber
  static const tertiary = Color(0xFF8d3f00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFb25200);
  static const onTertiaryContainer = Color(0xFFffeee6);
  static const tertiaryFixed = Color(0xFFffdbc9);
  static const tertiaryFixedDim = Color(0xFFffb68d);
  static const onTertiaryFixed = Color(0xFF321200);
  static const onTertiaryFixedVariant = Color(0xFF763400);

  // Surface & Background (cream/earth tones from HTML)
  static const background = Color(0xFFfbfbe2);
  static const onBackground = Color(0xFF1b1d0e);
  static const surface = Color(0xFFfbfbe2);
  static const onSurface = Color(0xFF1b1d0e);
  static const surfaceBright = Color(0xFFfbfbe2);
  static const surfaceDim = Color(0xFFdbdcc3);
  static const surfaceVariant = Color(0xFFe4e4cc);
  static const onSurfaceVariant = Color(0xFF40493d);
  static const inverseSurface = Color(0xFF303221);
  static const inverseOnSurface = Color(0xFFf2f2d9);
  static const inversePrimary = Color(0xFF88d982);

  // Surface containers (layered cream tones)
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFf5f5dc);
  static const surfaceContainer = Color(0xFFefefd7);
  static const surfaceContainerHigh = Color(0xFFeaead1);
  static const surfaceContainerHighest = Color(0xFFe4e4cc);

  // Error
  static const error = Color(0xFFba1a1a);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFffdad6);
  static const onErrorContainer = Color(0xFF93000a);

  // Outline
  static const outline = Color(0xFF707a6c);
  static const outlineVariant = Color(0xFFbfcaba);

  // Gradients matching HTML editorial feel
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const tertiaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardShadow = [
    BoxShadow(
      color: Color(0x101b1d0e),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const softShadow = [
    BoxShadow(
      color: Color(0x0A1b1d0e),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Legacy aliases for backward compatibility
  static const farmerGradient = primaryGradient;
  static const merchantGradient = tertiaryGradient;
  static const customerGradient = primaryGradient;
  static const silkGradient = LinearGradient(
    colors: [surfaceContainerLow, surfaceContainerHigh],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
