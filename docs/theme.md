# Theme & style

The app wears a **cold-war terminal** look: phosphor green on near-black, a monospace typeface (Courier Prime via `google_fonts`), square corners everywhere, faint CRT scanlines over the whole screen, and a two-layer phosphor glow on the morse display. The aesthetic is centralized so it can be retuned from one block of constants.

## Single source of truth

[lib/app_theme.dart](../lib/app_theme.dart) `AppTheme` owns the entire design. The **DESIGN TOKENS** block at the top — palette colors, `kRadius`, glow radii, and the `mono()` font helper — is the only place meant for hand-editing. `buildTheme()` and every widget derive from those tokens, so a change in one place flows everywhere.

Widgets may read the design either through `Theme.of(context)` (the derived Material theme) or via `AppTheme` constants directly — both resolve to the same token.

## Design tokens

| Token | Value | Role |
|---|---|---|
| `kColorBackground` | `#12131C` | Scaffold / surface base — near-black |
| `kColorPrimary` | `#39FF14` | Phosphor green — primary accent, text glow, focus |
| `kColorPrimaryContainer` | `#1A3010` | Dim green fill (e.g. home primary button) |
| `kColorSecondary` | `#00E5FF` | Cyan — secondary accent (segmented buttons, chart code) |
| `kColorError` | `#FF3333` | Error red |
| `kColorSuccess` | `#1FCC00` | Correct-answer green (mapped to `tertiary`) |
| `kColorSurface` | `#1A1B26` | Cards, dialogs, sheets, inputs |
| `kColorOnSurface` | `#C8D4C0` | Body text — muted green-grey |
| `kColorOutline` | `#4A6A42` | Borders, hints |
| `kColorOutlineVariant` | `#2A3A28` | Subtle dividers, inactive tracks |
| `kColorScanline` | `#0A000000` | Black at ~4% opacity — CRT overlay |
| `kRadius` | `0` | Corner radius — `0` = square, the terminal look |
| `kGlowInner` / `kGlowOuter` | `8` / `20` | Phosphor-bloom blur radii (inner, outer) |
| `mono({size, weight, spacing, height, color})` | — | The one place the typeface is named; all text styles route through it |

## Derived Material theme

`buildTheme()` maps the tokens into a Material 3 `ThemeData`:

- A `ColorScheme.dark` built from the palette (primary/secondary/tertiary/error plus their containers and surface tiers).
- Component themes for app bar, filled/outlined/text/segmented buttons, inputs, cards, dialogs, bottom sheets, list tiles, switches, sliders, icons, and popup menus.
- Every shape uses the shared square `_square` border (`RoundedRectangleBorder` at `kRadius`); inputs use `_inputBorder()`.
- Text styles route through `mono` — uppercase-ish tracked button labels (`spacing: 1.5`), a tracked app-bar title, and `GoogleFonts.courierPrimeTextTheme` as the base `textTheme`.

## Custom (non-Material) styles

Two styles fall outside Material's theming and are exposed as statics:

- `morseTextStyle` — large (34px) tracked teletype style for the ·/− morse display and the revealed answer.
- `glowShadow(color)` — a two-layer phosphor bloom (inner blur at 80% alpha, outer at 40%). Use sparingly: currently only the morse display ([morse_visual.dart](../lib/widgets/morse_visual.dart)) and the revealed answer in the prompt panel ([prompt_panel.dart](../lib/widgets/prompt_panel.dart)).

## CRT scanline overlay

[lib/widgets/scanline_overlay.dart](../lib/widgets/scanline_overlay.dart) paints horizontal lines every 4px at `kColorScanline` (~4% opacity) over its child. It wraps the entire app via `MaterialApp.builder` in [lib/app.dart](../lib/app.dart), so the effect sits above every screen. The painter is rasterized once (`shouldRepaint => false`) and `IgnorePointer`-wrapped, so it costs nothing at runtime and never intercepts touches.

## File map

| File | Role |
|---|---|
| [lib/app_theme.dart](../lib/app_theme.dart) | `AppTheme` — design tokens, `buildTheme()`, custom styles |
| [lib/app.dart](../lib/app.dart) | Applies `buildTheme()` and wraps the app in `ScanlineOverlay` |
| [lib/widgets/scanline_overlay.dart](../lib/widgets/scanline_overlay.dart) | CRT scanline painter |
| [lib/widgets/morse_visual.dart](../lib/widgets/morse_visual.dart) | ·/− display — `morseTextStyle` + `glowShadow` |
| [lib/widgets/prompt_panel.dart](../lib/widgets/prompt_panel.dart) | Prompt + revealed answer with glow |
| [lib/widgets/answer_field.dart](../lib/widgets/answer_field.dart) | Answer input — feedback colors via `mono` |
| [lib/widgets/reference_chart_sheet.dart](../lib/widgets/reference_chart_sheet.dart) | Morse chart sheet — cyan code styling |
| [lib/screens/home_screen.dart](../lib/screens/home_screen.dart) | Home buttons using primary/container tokens |

## How to restyle

Edit only the **DESIGN TOKENS** block in [lib/app_theme.dart](../lib/app_theme.dart) and the change propagates through the derived theme and all widgets:

- Swap the palette to amber (`kColorPrimary = Color(0xFFFFB000)`) for a different terminal phosphor.
- Bump `kRadius` (e.g. `8`) to round every corner at once.
- Tune `kGlowInner` / `kGlowOuter` to soften or intensify the bloom, or change the `mono()` font to re-typeface the whole app.
