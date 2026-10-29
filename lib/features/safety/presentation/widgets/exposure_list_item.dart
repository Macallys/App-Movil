import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/exposure.dart';
import '../safety_labels.dart';
import 'severity_label.dart';

class ExposureListItem extends StatelessWidget {
  const ExposureListItem({required this.exposure, super.key});

  final Exposure exposure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Área: ${exposure.areaId}'),
            const SizedBox(height: AppSpacing.sm),
            SeverityLabel(severity: exposure.severity),
            const SizedBox(height: AppSpacing.sm),
            Text(formatStatusDate(exposure.recordedAt)),
          ],
        ),
      ),
    );
  }
}
