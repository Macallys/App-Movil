import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
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
      surfaceDim: AppColors.ice,
      surfaceBright: AppColors.white,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.canvas,
      surfaceContainer: AppColors.ice,
      surfaceContainerHigh: AppColors.lightBlue,
      surfaceContainerHighest: AppColors.lightBlue,
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
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.white,
        titleSpacing: AppSpacing.md,
        titleTextStyle: TextStyle(
          color: AppColors.navy,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
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
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.navy,
          shape: shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(minHeight: 48),
        prefixIconColor: AppColors.slate,
        suffixIconColor: AppColors.slate,
        errorMaxLines: 3,
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
        surfaceTintColor: AppColors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: const BorderSide(color: AppColors.lightBlue),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        shape: shape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        indicatorColor: AppColors.lightBlue,
        indicatorShape: shape,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.smallButton.copyWith(
            color: selected ? AppColors.navy : AppColors.slate,
          );
        }),
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
