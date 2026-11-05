import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type styles from the SAFEPLANT light style guide.
///
/// The family is Space Grotesk. It is not bundled in this project, so these
/// styles do not set [TextStyle.fontFamily].
abstract final class AppTypography {
  static const family = 'Space Grotesk';
  static const lineHeight = 1.5;

  static const heading01 = TextStyle(
    fontSize: 128,
    fontWeight: FontWeight.w900,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const heading02 = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w700,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const heading03 = TextStyle(
    fontSize: 43,
    fontWeight: FontWeight.w700,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const heading04 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const heading05 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.navy,
  );
  static const heading06 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.navy,
  );
  static const body = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const bodyStrong = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: lineHeight,
    color: AppColors.navy,
  );
  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: lineHeight,
    color: AppColors.slate,
  );
  static const primaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: lineHeight,
  );
  static const secondaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: lineHeight,
  );
  static const smallButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: lineHeight,
  );

  static const textTheme = TextTheme(
    displayLarge: heading01,
    displayMedium: heading02,
    displaySmall: heading03,
    headlineMedium: heading04,
    headlineSmall: heading06,
    titleLarge: heading05,
    titleMedium: bodyStrong,
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: lineHeight,
      color: AppColors.navy,
    ),
    bodyLarge: body,
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: lineHeight,
      color: AppColors.navy,
    ),
    labelLarge: primaryButton,
    labelMedium: smallButton,
    labelSmall: smallButton,
    bodySmall: caption,
  );
}
