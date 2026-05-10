import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static TextTheme _textTheme(Color onSurfaceColor) => GoogleFonts.dmSansTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w900),
          displayMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w900),
          displaySmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800),
          headlineSmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
          labelSmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: C.primary,
          primaryContainer: C.primaryContainer,
          secondary: C.secondary,
          secondaryContainer: C.secondaryContainer,
          tertiary: C.tertiary,
          tertiaryContainer: C.tertiaryContainer,
          error: C.error,
          errorContainer: C.errorContainer,
          surface: C.surface,
          surfaceContainerLow: C.surfaceContainerLow,
          surfaceContainer: C.surfaceContainer,
          surfaceContainerHigh: C.surfaceContainerHigh,
          surfaceContainerHighest: C.surfaceContainerHighest,
          onPrimary: C.onPrimary,
          onSecondary: C.onSecondary,
          onTertiary: C.onPrimary,
          onError: C.onError,
          onSurface: C.onSurface,
          onSurfaceVariant: C.onSurfaceVariant,
          outline: C.outline,
          outlineVariant: C.outlineVariant,
        ),
        textTheme: _textTheme(C.onSurface),
        scaffoldBackgroundColor: C.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: C.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: C.onSurface,
          ),
          iconTheme: const IconThemeData(color: C.primary),
        ),
        cardTheme: CardThemeData(
          color: C.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: C.primary,
            foregroundColor: C.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: C.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: C.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.dmSans(fontSize: 13),
          hintStyle: GoogleFonts.dmSans(fontSize: 13, color: C.onSurfaceVariant),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: C.surfaceContainerLow,
          selectedItemColor: C.primary,
          unselectedItemColor: C.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: C.surfaceContainerLowest,
          indicatorColor: C.primary.withValues(alpha: 0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: C.primary, size: 24);
            }
            return IconThemeData(color: C.onSurfaceVariant, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: C.primary,
              );
            }
            return GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: C.onSurfaceVariant,
            );
          }),
          elevation: 0,
          height: 64,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(C.surfaceContainerLow),
          dataRowMinHeight: 56,
          headingTextStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 11),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: C.surfaceContainerHigh,
          selectedColor: C.primary.withValues(alpha: 0.15),
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentTextStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          showDragHandle: true,
        ),
      );
}
