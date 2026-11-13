import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/exposure.dart';
import '../safety_labels.dart';

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
            Text(
              exposure.isOpen ? 'Exposición abierta' : 'Exposición retirada',
              style: TextStyle(
                color: exposure.isOpen ? AppColors.amber : AppColors.slate,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Inicio: ${formatStatusDate(exposure.raisedAt)}'),
            if (exposure.withdrawnAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Retiro: ${formatStatusDate(exposure.withdrawnAt!)}'),
            ],
          ],
        ),
      ),
    );
  }
}
