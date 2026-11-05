import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class PlantSetupCard extends StatelessWidget {
  const PlantSetupCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
  );
}

class PlantSetupIconLine extends StatelessWidget {
  const PlantSetupIconLine({
    required this.icon,
    required this.child,
    this.color = AppColors.blue,
    super.key,
  });
  final IconData icon;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: child),
    ],
  );
}

class PlantSetupStatusChip extends StatelessWidget {
  const PlantSetupStatusChip({
    required this.icon,
    required this.color,
    required this.child,
    super.key,
  });
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      border: Border.all(color: color.withValues(alpha: 0.24)),
      borderRadius: BorderRadius.circular(AppRadius.control),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: child),
        ],
      ),
    ),
  );
}
