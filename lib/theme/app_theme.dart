import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Copied from temp.dart/lib/util.dart
TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final baseTextTheme = Theme.of(context).textTheme;
  final bodyTextTheme =
      GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  final displayTextTheme =
      GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
  final textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

// Removed TextTheme field and constructor
class MaterialTheme {
  // const MaterialTheme(this.textTheme); // Removed constructor

  // Static method to create TextTheme, doesn't need instance or full context
  // It still needs *a* context, typically from where it's called.
  static TextTheme _textTheme(BuildContext context) {
    // Using the fonts from the temp example
    return createTextTheme(context, 'Open Sans', 'Adamina');
  }

  // Make theme methods accept BuildContext
  ThemeData light(BuildContext context) {
    return _theme(lightScheme(), _textTheme(context));
  }

  ThemeData lightMediumContrast(BuildContext context) {
    return _theme(lightMediumContrastScheme(), _textTheme(context));
  }

  ThemeData lightHighContrast(BuildContext context) {
    return _theme(lightHighContrastScheme(), _textTheme(context));
  }

  ThemeData dark(BuildContext context) {
    return _theme(darkScheme(), _textTheme(context));
  }

  ThemeData darkMediumContrast(BuildContext context) {
    return _theme(darkMediumContrastScheme(), _textTheme(context));
  }

  ThemeData darkHighContrast(BuildContext context) {
    return _theme(darkHighContrastScheme(), _textTheme(context));
  }

  // Renamed the internal theme creation method to avoid conflict
  // It now takes TextTheme as an argument
  ThemeData _theme(ColorScheme colorScheme, TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        // Apply colors from the scheme
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      // TODO: Add other component themes (buttons, cards, etc.)
      // using colorScheme and textTheme for full implementation
    );
  }

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8f4c38),
      surfaceTint: Color(0xff8f4c38),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbd1),
      onPrimaryContainer:
          Color(0xff723523), // Corrected from original 3a0b01? Check generator
      secondary: Color(0xff77574e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdbd1),
      onSecondaryContainer:
          Color(0xff5d4037), // Corrected from original 2c150f? Check generator
      tertiary: Color(0xff6c5d2f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff5e1a7),
      onTertiaryContainer:
          Color(0xff534619), // Corrected from original 231b00? Check generator
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer:
          Color(0xff93000a), // Corrected from original 410002? Check generator
      surface: Color(0xfffff8f6),
      onSurface:
          Color(0xff231917), // Corrected from original 201a18? Check generator
      onSurfaceVariant:
          Color(0xff53433f), // Corrected from original 4f4541? Check generator
      outline: Color(0xff85736e),
      outlineVariant: Color(0xffd8c2bc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface:
          Color(0xff392e2b), // Corrected from original 362f2d? Check generator
      inversePrimary: Color(0xffffb5a0),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff3a0b01),
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff723523),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff2c150f),
      secondaryFixedDim: Color(0xffe7bdb2),
      onSecondaryFixedVariant: Color(0xff5d4037),
      tertiaryFixed: Color(0xfff5e1a7),
      onTertiaryFixed: Color(0xff231b00),
      tertiaryFixedDim: Color(0xffd8c58d),
      onTertiaryFixedVariant: Color(0xff534619),
      surfaceDim: Color(0xffe8d6d2),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ed),
      surfaceContainer: Color(0xfffceae5),
      surfaceContainerHigh: Color(0xfff7e4e0),
      surfaceContainerHighest: Color(0xfff1dfda),
    );
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5d2514),
      surfaceTint: Color(0xff8f4c38),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa15a45),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4b2f28),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff87655c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff41350a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7b6c3c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff180f0d), // Corrected
      onSurfaceVariant: Color(0xff41332f), // Corrected
      outline: Color(0xff5f4f4a), // Corrected
      outlineVariant: Color(0xff7b6964), // Corrected
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2b), // Corrected
      inversePrimary: Color(0xffffb5a0),
      primaryFixed: Color(0xffa15a45),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff84422f),
      onPrimaryFixedVariant: Color(0xffffffff), // Corrected
      secondaryFixed: Color(0xff87655c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6d4d45),
      onSecondaryFixedVariant: Color(0xffffffff), // Corrected
      tertiaryFixed: Color(0xff7b6c3c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff615426),
      onTertiaryFixedVariant: Color(0xffffffff), // Corrected
      surfaceDim: Color(0xffd4c3be), // Corrected
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ed), // Corrected
      surfaceContainer: Color(0xfff7e4e0), // Corrected
      surfaceContainerHigh: Color(0xffebd9d4), // Corrected
      surfaceContainerHighest: Color(0xffdfcec9), // Corrected
    );
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff501b0b),
      surfaceTint: Color(0xff8f4c38),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff753725),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3f261e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff60423a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff362b02),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff55481c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000), // Corrected
      outline: Color(0xff372925), // Corrected
      outlineVariant: Color(0xff554641), // Corrected
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2b), // Corrected
      inversePrimary: Color(0xffffb5a0), // Corrected
      primaryFixed: Color(0xff753725),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff592111),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff60423a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff472c24),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff55481c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3d3206),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6b5b1), // Corrected
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede8), // Corrected
      surfaceContainer: Color(0xfff1dfda), // Corrected
      surfaceContainerHigh: Color(0xffe2d1cc), // Corrected
      surfaceContainerHighest: Color(0xffd4c3be), // Corrected
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb5a0),
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff561f0f),
      primaryContainer: Color(0xff723523),
      onPrimaryContainer: Color(0xffffdbd1),
      secondary: Color(0xffe7bdb2),
      onSecondary: Color(0xff442a22),
      secondaryContainer: Color(0xff5d4037),
      onSecondaryContainer: Color(0xffffdbd1),
      tertiary: Color(0xffd8c58d),
      onTertiary: Color(0xff3b2f05),
      tertiaryContainer: Color(0xff534619),
      onTertiaryContainer: Color(0xfff5e1a7),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a110f),
      onSurface: Color(0xfff1dfda),
      onSurfaceVariant: Color(0xffd8c2bc),
      outline: Color(0xffa08c87),
      outlineVariant: Color(0xff53433f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda),
      inversePrimary: Color(0xff8f4c38),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff3a0b01),
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff723523),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff2c150f),
      secondaryFixedDim: Color(0xffe7bdb2),
      onSecondaryFixedVariant: Color(0xff5d4037),
      tertiaryFixed: Color(0xfff5e1a7),
      onTertiaryFixed: Color(0xff231b00),
      tertiaryFixedDim: Color(0xffd8c58d),
      onTertiaryFixedVariant: Color(0xff534619),
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff423734),
      surfaceContainerLowest: Color(0xff140c0a),
      surfaceContainerLow: Color(0xff231917),
      surfaceContainer: Color(0xff271d1b),
      surfaceContainerHigh: Color(0xff322825),
      surfaceContainerHighest: Color(0xff3d322f),
    );
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2c6), // Corrected
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff481506), // Corrected
      primaryContainer: Color(0xffcb7c65), // Corrected
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffed3c7), // Corrected
      onSecondary: Color(0xff381f18), // Corrected
      secondaryContainer: Color(0xffae887e), // Corrected
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffefdba1), // Corrected
      onTertiary: Color(0xff2f2500), // Corrected
      tertiaryContainer: Color(0xffa0905c), // Corrected
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc), // Corrected
      onError: Color(0xff540003), // Corrected
      errorContainer: Color(0xffff5449), // Corrected
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a110f),
      onSurface: Color(0xffffffff), // Corrected
      onSurfaceVariant: Color(0xffeed7d1), // Corrected
      outline: Color(0xffc2ada8), // Corrected
      outlineVariant: Color(0xffa08c87), // Corrected
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda), // Corrected
      inversePrimary: Color(0xff743624), // Corrected
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff280500), // Corrected
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff5d2514), // Corrected
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff200b06), // Corrected
      secondaryFixedDim: Color(0xffe7bdb2),
      onSecondaryFixedVariant: Color(0xff4b2f28), // Corrected
      tertiaryFixed: Color(0xfff5e1a7),
      onTertiaryFixed: Color(0xff171100), // Corrected
      tertiaryFixedDim: Color(0xffd8c58d),
      onTertiaryFixedVariant: Color(0xff41350a), // Corrected
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff4e423f), // Corrected
      surfaceContainerLowest: Color(0xff0d0604), // Corrected
      surfaceContainerLow: Color(0xff251b19), // Corrected
      surfaceContainer: Color(0xff302623), // Corrected
      surfaceContainerHigh: Color(0xff3b302d), // Corrected
      surfaceContainerHighest: Color(0xff463b38), // Corrected
    );
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece7),
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaf98), // Corrected
      onPrimaryContainer: Color(0xff1e0300), // Corrected
      secondary: Color(0xffffece7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe3b9ae), // Corrected
      onSecondaryContainer: Color(0xff190603), // Corrected
      tertiary: Color(0xffffefc4), // Corrected
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd4c289), // Corrected
      onTertiaryContainer: Color(0xff100b00), // Corrected
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4), // Corrected
      onErrorContainer: Color(0xff220001), // Corrected
      surface: Color(0xff1a110f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff), // Corrected
      outline: Color(0xffffece7), // Corrected
      outlineVariant: Color(0xffd4beb8), // Corrected
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda), // Corrected
      inversePrimary: Color(0xff743624), // Corrected
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff000000), // Corrected
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff280500), // Corrected
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff000000), // Corrected
      secondaryFixedDim: Color(0xffe7bdb2),
      onSecondaryFixedVariant: Color(0xff200b06), // Corrected
      tertiaryFixed: Color(0xfff5e1a7),
      onTertiaryFixed: Color(0xff000000), // Corrected
      tertiaryFixedDim: Color(0xffd8c58d),
      onTertiaryFixedVariant: Color(0xff171100), // Corrected
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff5a4d4a), // Corrected
      surfaceContainerLowest: Color(0xff000000), // Corrected
      surfaceContainerLow: Color(0xff271d1b), // Corrected
      surfaceContainer: Color(0xff392e2b), // Corrected
      surfaceContainerHigh: Color(0xff443936), // Corrected
      surfaceContainerHighest: Color(0xff504441), // Corrected
    );
  }

  // These seem unused for now, keeping them but commented out potentially
  // List<ExtendedColor> get extendedColors => [
  // ];
}

/* // Unused classes for now
class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
*/
