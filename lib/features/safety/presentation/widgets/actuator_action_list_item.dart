import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_action.dart';
import '../../domain/entities/actuator_state.dart';
import '../safety_labels.dart';

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
            Text(actuatorTypeLabel(action.type)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Estado: ${runStateLabel(action.runState)}',
              style: TextStyle(color: _stateColor(action.runState)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(formatStatusDate(action.executedAt)),
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
