import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF1A73E8);
  static const Color accent = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFF9AB00);

  static final ColorScheme _fallbackScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  static ColorScheme schemeOf(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color surfaceLight(BuildContext context) => schemeOf(context).surface;
  static Color cardLight(BuildContext context) =>
      schemeOf(context).surfaceContainerLow;
  static Color dividerLight(BuildContext context) =>
      schemeOf(context).outlineVariant;
  static Color textPrimary(BuildContext context) => schemeOf(context).onSurface;
  static Color textSecondary(BuildContext context) =>
      schemeOf(context).onSurfaceVariant;
  static Color textHint(BuildContext context) =>
      schemeOf(context).onSurfaceVariant;
  static Color primaryLight(BuildContext context) =>
      schemeOf(context).primaryContainer;

  static Color avatarColorForName(String name, ColorScheme scheme) {
    final palette = [
      scheme.primary,
      scheme.tertiary,
      accent,
      warning,
      const Color(0xFF7E57C2),
      const Color(0xFFEF6C00),
      const Color(0xFF00897B),
      scheme.secondary,
    ];
    if (name.isEmpty) return palette.first;
    final index = name.codeUnitAt(0) % palette.length;
    return palette[index];
  }

  static ThemeData lightTheme([ColorScheme? dynamicScheme]) {
    final colorScheme = dynamicScheme ?? _fallbackScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(error: error),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black12,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        toolbarTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
