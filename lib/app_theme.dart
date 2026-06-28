import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for the cold-war terminal look.
///
/// To change the design by hand, edit the **DESIGN TOKENS** block below —
/// colors, font, corner radius, glow. Everything else (`buildTheme()` and the
/// widgets) derives from these tokens, so a change in one place flows
/// everywhere. Widgets may read either `Theme.of(context)` or these `AppTheme`
/// constants directly; both resolve to the same token.
class AppTheme {
  AppTheme._();

  // ======================= DESIGN TOKENS — edit these =======================

  // Palette
  static const Color kColorBackground = Color(0xFF12131C);
  static const Color kColorPrimary = Color(0xFF39FF14);
  static const Color kColorPrimaryContainer = Color(0xFF1A3010);
  static const Color kColorSecondary = Color(0xFF00E5FF);
  static const Color kColorError = Color(0xFFFF3333);
  static const Color kColorSuccess = Color(0xFF1FCC00);
  static const Color kColorSurface = Color(0xFF1A1B26);
  static const Color kColorOnSurface = Color(0xFFC8D4C0);
  static const Color kColorOutline = Color(0xFF4A6A42);
  static const Color kColorOutlineVariant = Color(0xFF2A3A28);

  /// Subtle CRT scanline overlay (black at ~4% opacity).
  static const Color kColorScanline = Color(0x0A000000);

  /// Square corners everywhere — the terminal aesthetic.
  static const double kRadius = 0;

  /// Phosphor-glow blur radii (inner, outer).
  static const double kGlowInner = 8;
  static const double kGlowOuter = 20;

  /// The one place the typeface is named. All text styles go through [mono].
  static TextStyle mono({
    double? size,
    FontWeight? weight,
    double? spacing,
    double? height,
    Color? color,
  }) =>
      GoogleFonts.courierPrime(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
        color: color,
      );

  // =========================== Derived theme ================================

  /// Square shape shared by buttons, cards, dialogs, sheets, list tiles, menus.
  static const _square = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(kRadius)),
  );

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(kRadius)),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData buildTheme() {
    const colorScheme = ColorScheme.dark(
      primary: kColorPrimary,
      onPrimary: kColorBackground,
      primaryContainer: kColorPrimaryContainer,
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
      outline: kColorOutline,
      outlineVariant: kColorOutlineVariant,
      surfaceContainerLowest: kColorBackground,
      surfaceContainerLow: Color(0xFF171828),
      surfaceContainer: kColorSurface,
      surfaceContainerHigh: Color(0xFF1E2030),
      surfaceContainerHighest: kColorSurface,
      inverseSurface: kColorOnSurface,
      onInverseSurface: kColorBackground,
      inversePrimary: kColorPrimaryContainer,
    );

    final buttonText = WidgetStatePropertyAll(
      mono(weight: FontWeight.w700, spacing: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kColorBackground,
      textTheme: GoogleFonts.courierPrimeTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kColorBackground,
        foregroundColor: kColorPrimary,
        titleTextStyle: mono(
          size: 14,
          weight: FontWeight.w700,
          spacing: 2.4,
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
          shape: const WidgetStatePropertyAll(_square),
          textStyle: WidgetStatePropertyAll(
            mono(size: 18, weight: FontWeight.w700, spacing: 1.5),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(_square),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0x9939FF14)),
          ),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(_square),
          textStyle: buttonText,
        ),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(_square),
          side: WidgetStatePropertyAll(BorderSide(color: kColorSecondary)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kColorSurface,
        border: _inputBorder(kColorOutline),
        enabledBorder: _inputBorder(kColorOutline),
        focusedBorder: _inputBorder(kColorPrimary, 2),
        errorBorder: _inputBorder(kColorError),
        focusedErrorBorder: _inputBorder(kColorError, 2),
        hintStyle: const TextStyle(color: kColorOutline),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: _square,
        backgroundColor: kColorSurface,
      ),
      cardTheme: const CardThemeData(shape: _square, color: kColorSurface),
      dialogTheme: const DialogThemeData(
        shape: _square,
        backgroundColor: kColorSurface,
      ),
      listTileTheme: const ListTileThemeData(shape: _square),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(kColorPrimary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0x4D39FF14);
          }
          return kColorOutlineVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return kColorOutline;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: kColorPrimary,
        thumbColor: kColorPrimary,
        overlayColor: Color(0x2639FF14),
        inactiveTrackColor: kColorOutlineVariant,
      ),
      iconTheme: const IconThemeData(color: kColorPrimary),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(kColorPrimary),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: kColorSurface,
        shape: _square,
        textStyle: mono(color: kColorOnSurface),
      ),
    );
  }

  // ====================== Custom (non-Material) styles ======================

  /// Large ·/− morse display and revealed answer — typewriter / teletype feel.
  static TextStyle get morseTextStyle =>
      mono(size: 34, height: 1.4, spacing: 4, weight: FontWeight.w600);

  /// Two-layer phosphor bloom — use sparingly (morse display, revealed answer).
  static List<Shadow> glowShadow(Color color) => [
        Shadow(color: color.withValues(alpha: 0.8), blurRadius: kGlowInner),
        Shadow(color: color.withValues(alpha: 0.4), blurRadius: kGlowOuter),
      ];
}
