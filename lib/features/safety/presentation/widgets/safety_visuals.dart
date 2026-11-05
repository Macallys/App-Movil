import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_state.dart';

/// Adds an icon while preserving the existing text widget.
class SafetyIconLine extends StatelessWidget {
  const SafetyIconLine({
    required this.icon,
    required this.child,
    this.color = AppColors.slate,
    super.key,
  });

  final IconData icon;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: child),
    ],
  );
}

class SafetyStatusChip extends StatelessWidget {
  const SafetyStatusChip({
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
      borderRadius: BorderRadius.circular(AppRadius.control),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

class SafetyMetricTile extends StatelessWidget {
  const SafetyMetricTile({required this.icon, required this.child, super.key});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.ice,
      borderRadius: BorderRadius.circular(AppRadius.control),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SafetyIconLine(
        icon: icon,
        color: AppColors.blue,
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class SafetyMetricPair extends StatelessWidget {
  const SafetyMetricPair({
    required this.first,
    required this.second,
    super.key,
  });
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < MediaQuery.textScalerOf(context).scale(320)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            first,
            const SizedBox(height: AppSpacing.sm),
            second,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: second),
        ],
      );
    },
  );
}

IconData actuatorVisualIcon(ActuatorType type) => switch (type) {
  ActuatorType.extractor => Icons.air,
  ActuatorType.siren => Icons.notifications_active_outlined,
  ActuatorType.barrier => Icons.shield_outlined,
};

IconData actuatorStateVisualIcon(ActuatorRunState state) => switch (state) {
  ActuatorRunState.failed => Icons.error_outline,
  ActuatorRunState.off ||
  ActuatorRunState.retracted => Icons.pause_circle_outline,
  ActuatorRunState.on ||
  ActuatorRunState.deployed => Icons.check_circle_outline,
};

Color actuatorStateVisualColor(ActuatorRunState state) => switch (state) {
  ActuatorRunState.failed => AppColors.red,
  ActuatorRunState.off || ActuatorRunState.retracted => AppColors.slate,
  ActuatorRunState.on || ActuatorRunState.deployed => AppColors.green,
};
