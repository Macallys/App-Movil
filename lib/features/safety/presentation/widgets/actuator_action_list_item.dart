import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_action.dart';
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
              action.succeeded ? 'Resultado: Aplicado' : 'Resultado: Fallo',
              style: TextStyle(
                color: action.succeeded ? AppColors.green : AppColors.red,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(formatStatusDate(action.recordedAt)),
          ],
        ),
      ),
    );
  }
}
