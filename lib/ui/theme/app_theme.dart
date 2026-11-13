import 'package:flutter/material.dart';

/// Cores da marca MovieAI que não cabem no [ColorScheme].
///
/// Os valores vêm do design system do Stitch (design/stitch).
abstract final class AppColors {
  /// Degradê do logo: âmbar → rosa → violeta.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
  );

  /// Degradê dos botões de destaque: âmbar → lilás.
  static const ctaGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFFC174), Color(0xFFD0BCFF)],
  );
}

/// Tema escuro do app, com os tokens do design system do Stitch.
abstract final class AppTheme {
  static const fontFamily = 'PlusJakartaSans';

  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFC174),
    onPrimary: Color(0xFF472A00),
    primaryContainer: Color(0xFFF59E0B),
    onPrimaryContainer: Color(0xFF613B00),
    primaryFixed: Color(0xFFFFDDB8),
    primaryFixedDim: Color(0xFFFFB95F),
    onPrimaryFixed: Color(0xFF2A1700),
    onPrimaryFixedVariant: Color(0xFF653E00),
    secondary: Color(0xFFD0BCFF),
    onSecondary: Color(0xFF3C0091),
    secondaryContainer: Color(0xFF571BC1),
    onSecondaryContainer: Color(0xFFC4ABFF),
    secondaryFixed: Color(0xFFE9DDFF),
    secondaryFixedDim: Color(0xFFD0BCFF),
    onSecondaryFixed: Color(0xFF23005C),
    onSecondaryFixedVariant: Color(0xFF5516BE),
    tertiary: Color(0xFF54DDFC),
    onTertiary: Color(0xFF003640),
    tertiaryContainer: Color(0xFF29C1DF),
    onTertiaryContainer: Color(0xFF004B58),
    tertiaryFixed: Color(0xFFACEDFF),
    tertiaryFixedDim: Color(0xFF4CD7F6),
    onTertiaryFixed: Color(0xFF001F26),
    onTertiaryFixedVariant: Color(0xFF004E5C),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF10131A),
    onSurface: Color(0xFFE1E2EB),
    onSurfaceVariant: Color(0xFFD8C3AD),
    surfaceDim: Color(0xFF10131A),
    surfaceBright: Color(0xFF363940),
    surfaceContainerLowest: Color(0xFF0B0E14),
    surfaceContainerLow: Color(0xFF191C22),
    surfaceContainer: Color(0xFF1D2026),
    surfaceContainerHigh: Color(0xFF272A31),
    surfaceContainerHighest: Color(0xFF32353C),
    outline: Color(0xFFA08E7A),
    outlineVariant: Color(0xFF534434),
    inverseSurface: Color(0xFFE1E2EB),
    onInverseSurface: Color(0xFF2E3037),
    inversePrimary: Color(0xFF855300),
    surfaceTint: Color(0xFFFFB95F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData dark() {
    const scheme = colorScheme;
    const stadium = StadiumBorder();
    final rounded12 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: rounded12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: TextStyle(color: scheme.outline),
        prefixIconColor: scheme.outline,
        suffixIconColor: scheme.outline,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: stadium,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: stadium),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: stadium),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary,
        side: BorderSide.none,
        shape: stadium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: scheme.onSurface,
        ),
        shape: rounded12,
      ),
      dividerTheme: DividerThemeData(color: scheme.surfaceContainerHighest),
    );
  }
}
