import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/environmental_alert.dart';
import '../safety_labels.dart';
import 'severity_label.dart';

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
            SeverityLabel(severity: alert.severity),
            const SizedBox(height: AppSpacing.sm),
            Text(formatStatusDate(alert.recordedAt)),
          ],
        ),
      ),
    );
  }
}
