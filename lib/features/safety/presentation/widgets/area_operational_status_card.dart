import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/area_operational_status.dart';
import '../safety_labels.dart';
import 'severity_label.dart';

class AreaOperationalStatusCard extends StatelessWidget {
  const AreaOperationalStatusCard({
    required this.status,
    required this.onOpen,
    super.key,
  });

  final AreaOperationalStatus status;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.control);
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: status.highlighted ? scheme.primary : scheme.outlineVariant,
          width: status.highlighted ? 2 : 1,
        ),
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status.name, style: theme.textTheme.titleMedium),
              if (status.highlighted) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Destacada', style: TextStyle(color: scheme.primary)),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text('CO₂: ${measureLabel(status.co2Ppm, 'ppm')}'),
              Text('Ruido: ${measureLabel(status.noiseDb, 'dB')}'),
              Text('Presencia: ${presenceLabel(status.presenceState)}'),
              const SizedBox(height: AppSpacing.sm),
              SeverityLabel(severity: status.severity),
              if (status.alertActive) ...[
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      color: AppColors.red,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Alerta activa',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ],
              if (status.actuators.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                for (final actuator in status.actuators)
                  Text(actuatorSummary(actuator)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
