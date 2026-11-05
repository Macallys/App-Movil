import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_action.dart';
import '../../domain/entities/actuator_state.dart';
import '../safety_labels.dart';
import 'safety_visuals.dart';

class ActuatorActionListItem extends StatelessWidget {
  const ActuatorActionListItem({required this.action, super.key});

  final ActuatorAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final title = SafetyIconLine(
                  icon: actuatorVisualIcon(action.type),
                  color: AppColors.blue,
                  child: Text(
                    actuatorTypeLabel(action.type),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                );
                final status = SafetyStatusChip(
                  icon: actuatorStateVisualIcon(action.runState),
                  color: _stateColor(action.runState),
                  child: Text('Estado: ${runStateLabel(action.runState)}'),
                );
                if (constraints.maxWidth <
                    MediaQuery.textScalerOf(context).scale(360)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: AppSpacing.sm),
                      status,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: status),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SafetyIconLine(
              icon: Icons.schedule,
              child: Text(
                formatStatusDate(action.executedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _stateColor(ActuatorRunState state) {
  return switch (state) {
    ActuatorRunState.failed => AppColors.red,
    ActuatorRunState.off || ActuatorRunState.retracted => AppColors.slate,
    ActuatorRunState.on || ActuatorRunState.deployed => AppColors.green,
  };
}
