import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/area_operational_status.dart';
import '../safety_labels.dart';

/// Severity is named and iconed. Color reinforces the label.
class SeverityLabel extends StatelessWidget {
  const SeverityLabel({required this.severity, super.key});

  final ExposureSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(severity, Theme.of(context).colorScheme);
    final icon = switch (severity) {
      ExposureSeverity.none => Icons.check_circle_outline,
      ExposureSeverity.medium => Icons.warning_amber_outlined,
      ExposureSeverity.high => Icons.error_outline,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Severidad: ${severityLabel(severity)}',
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
