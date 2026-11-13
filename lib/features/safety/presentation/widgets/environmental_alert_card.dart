import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/environmental_alert.dart';
import '../safety_labels.dart';

class EnvironmentalAlertCard extends StatelessWidget {
  const EnvironmentalAlertCard({required this.alert, super.key});

  final EnvironmentalAlert alert;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Área: ${alert.areaId}'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              alert.isOpen ? 'Alerta abierta' : 'Alerta retirada',
              style: TextStyle(
                color: alert.isOpen ? AppColors.red : AppColors.slate,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Inicio: ${formatStatusDate(alert.raisedAt)}'),
            if (alert.withdrawnAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Retiro: ${formatStatusDate(alert.withdrawnAt!)}'),
            ],
          ],
        ),
      ),
    );
  }
}
