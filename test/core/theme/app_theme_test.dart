import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/theme/app_colors.dart';
import 'package:safeplant_mobile/core/theme/app_radius.dart';
import 'package:safeplant_mobile/core/theme/app_spacing.dart';
import 'package:safeplant_mobile/core/theme/app_theme.dart';
import 'package:safeplant_mobile/core/theme/app_typography.dart';

void main() {
  test('the light theme keeps the documented palette and radius', () {
    final theme = AppTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, AppColors.navy);
    expect(theme.colorScheme.onPrimary, AppColors.white);
    expect(theme.colorScheme.secondary, AppColors.blue);
    expect(theme.colorScheme.error, AppColors.red);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.textTheme.bodyLarge?.fontSize, 18);
    expect(theme.textTheme.bodyLarge?.fontFamily, isNot(AppTypography.family));
    expect(AppTypography.family, 'Space Grotesk');
    expect(AppSpacing.sm, 8);
    expect(AppSpacing.xl, 32);
    expect(AppRadius.control, 10);
  });
}
