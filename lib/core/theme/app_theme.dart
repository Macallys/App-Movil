import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Light theme assembled from the SAFEPLANT style guide.
///
/// Space Grotesk is named by the guide and is not bundled, so the theme
/// leaves the platform font in place. Only the light palette exists.
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.navy,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.deepBlue,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.blue,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.lightBlue,
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.cyan,
      onTertiary: AppColors.navy,
      tertiaryContainer: AppColors.ice,
      onTertiaryContainer: AppColors.navy,
      error: AppColors.red,
      onError: AppColors.white,
      errorContainer: AppColors.red,
      onErrorContainer: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.navy,
      onSurfaceVariant: AppColors.slate,
      outline: AppColors.slate,
      outlineVariant: AppColors.lightBlue,
      shadow: AppColors.navy,
      scrim: AppColors.navy,
      inverseSurface: AppColors.navy,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.cyan,
      surfaceTint: AppColors.navy,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: AppTypography.lineHeight,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.slate,
          disabledForegroundColor: AppColors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: AppTypography.lineHeight,
          ),
          minimumSize: const Size(48, 48),
          elevation: 0,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: AppTypography.lineHeight,
          ),
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.navy),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: AppTypography.lineHeight,
          ),
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.slate),
        labelStyle: const TextStyle(color: AppColors.navy),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.lightBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: shape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: shape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightBlue,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.navy : AppColors.slate,
          );
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue;
          return AppColors.white;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
      ),
    );
  }
}
