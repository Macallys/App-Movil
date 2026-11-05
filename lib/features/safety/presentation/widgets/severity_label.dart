import 'package:flutter/material.dart';

import '../../domain/entities/area_operational_status.dart';
import '../safety_labels.dart';
import 'safety_visuals.dart';

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
    return SafetyStatusChip(
      icon: icon,
      color: color,
      child: Text('Severidad: ${severityLabel(severity)}'),
    );
  }
}
