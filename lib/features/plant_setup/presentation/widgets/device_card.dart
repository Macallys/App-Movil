import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_spacing.dart';
import 'plant_setup_visuals.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    required this.device,
    required this.now,
    required this.revoking,
    required this.onRevoke,
    super.key,
  });

  final Device device;
  final DateTime now;
  final bool revoking;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlantSetupIconLine(
              icon: Icons.devices_outlined,
              child: Text(device.deviceId, style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            PlantSetupIconLine(
              icon: Icons.settings_input_component,
              child: Text(_kindLabel(device.kind)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Área: ${device.areaId ?? 'Sin área'}'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Emitido: ${_format(device.issuedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vence: ${_format(device.expiresAt)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            PlantSetupStatusChip(
              icon: device.revokedAt != null
                  ? Icons.block
                  : !device.expiresAt.isAfter(now)
                  ? Icons.schedule
                  : Icons.check_circle_outline,
              color: _statusColor(device, now),
              child: Text(
                _status(device, now),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ),
            if (device.revokedAt == null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                ),
                onPressed: revoking ? null : onRevoke,
                child: revoking
                    ? const SafePlantButtonProgress()
                    : const Text('Revocar dispositivo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _kindLabel(DeviceKind? kind) {
  return switch (kind) {
    DeviceKind.sensor => 'Sensor',
    DeviceKind.actuator => 'Actuador',
    null => 'Tipo no disponible',
  };
}

String _status(Device device, DateTime now) {
  if (device.revokedAt != null) {
    return 'Revocado';
  }
  if (!device.expiresAt.isAfter(now)) {
    return 'Vencido';
  }
  return 'Activo';
}

Color _statusColor(Device device, DateTime now) {
  if (device.revokedAt != null) {
    return AppColors.slate;
  }
  if (!device.expiresAt.isAfter(now)) {
    return AppColors.amber;
  }
  return AppColors.green;
}

String _format(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}
