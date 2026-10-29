import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Spinner used inside a navy filled button, where the default primary
/// color would disappear.
class SafePlantButtonProgress extends StatelessWidget {
  const SafePlantButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
    );
  }
}
