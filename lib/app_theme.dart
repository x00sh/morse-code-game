import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Cold-war terminal palette
  static const Color kColorBackground = Color(0xFF12131C);
  static const Color kColorPrimary = Color(0xFF39FF14);
  static const Color kColorSecondary = Color(0xFF00E5FF);
  static const Color kColorError = Color(0xFFFF3333);
  static const Color kColorSuccess = Color(0xFF1FCC00);
  static const Color kColorSurface = Color(0xFF1A1B26);
  static const Color kColorOnSurface = Color(0xFFC8D4C0);

  static const _outline = Color(0xFF4A6A42);
  static const _outlineVariant = Color(0xFF2A3A28);

  static ThemeData buildTheme() {
    const colorScheme = ColorScheme.dark(
      primary: kColorPrimary,
      onPrimary: kColorBackground,
      primaryContainer: Color(0xFF1A3010),
      onPrimaryContainer: kColorPrimary,
      secondary: kColorSecondary,
      onSecondary: kColorBackground,
      secondaryContainer: Color(0xFF003038),
      onSecondaryContainer: kColorSecondary,
      tertiary: kColorSuccess,
      onTertiary: kColorBackground,
      tertiaryContainer: Color(0xFF0D2800),
      onTertiaryContainer: kColorSuccess,
      error: kColorError,
      onError: kColorBackground,
      errorContainer: Color(0xFF3D0000),
      onErrorContainer: kColorError,
      surface: kColorBackground,
      onSurface: kColorOnSurface,
      onSurfaceVariant: kColorOnSurface,
      outline: _outline,
      outlineVariant: _outlineVariant,
      surfaceContainerLowest: kColorBackground,
      surfaceContainerLow: Color(0xFF171828),
      surfaceContainer: kColorSurface,
      surfaceContainerHigh: Color(0xFF1E2030),
      surfaceContainerHighest: kColorSurface,
      inverseSurface: kColorOnSurface,
      onInverseSurface: kColorBackground,
      inversePrimary: Color(0xFF1A3010),
    );

    final textTheme = GoogleFonts.courierPrimeTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kColorBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kColorBackground,
        foregroundColor: kColorPrimary,
        titleTextStyle: GoogleFonts.courierPrime(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
          color: kColorPrimary,
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0x6639FF14), width: 1),
        ),
        iconTheme: const IconThemeData(color: kColorPrimary),
        actionsIconTheme: const IconThemeData(color: kColorPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.courierPrime(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0x9939FF14)),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.courierPrime(fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.courierPrime(fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
        ),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: kColorSecondary),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: kColorSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kColorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kColorError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kColorError, width: 2),
        ),
        hintStyle: TextStyle(color: _outline),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: kColorSurface,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        color: kColorSurface,
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: kColorSurface,
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(kColorPrimary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0x4D39FF14);
          }
          return _outlineVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return _outline;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: kColorPrimary,
        thumbColor: kColorPrimary,
        overlayColor: Color(0x2639FF14),
        inactiveTrackColor: Color(0xFF2A3A28),
      ),
      iconTheme: const IconThemeData(color: kColorPrimary),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(kColorPrimary),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: kColorSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: GoogleFonts.courierPrime(color: kColorOnSurface),
      ),
    );
  }

  // Courier Prime for morse display and user input — typewriter / teletype feel
  static TextStyle get morseTextStyle => GoogleFonts.courierPrime(
        fontSize: 34,
        height: 1.4,
        letterSpacing: 4,
        fontWeight: FontWeight.w600,
      );

  // Two-layer phosphor bloom — use sparingly (morse display, revealed answer)
  static List<Shadow> glowShadow(Color color) => [
        Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
        Shadow(color: color.withValues(alpha: 0.4), blurRadius: 20),
      ];
}
