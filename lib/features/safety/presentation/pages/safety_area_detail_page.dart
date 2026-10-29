import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_state.dart';
import '../../domain/entities/area_operational_status.dart';
import '../../domain/entities/latest_readings.dart';
import '../providers/safety_providers.dart';
import '../safety_labels.dart';
import '../widgets/severity_label.dart';
import 'actuator_override_page.dart';

class SafetyAreaDetailPage extends ConsumerStatefulWidget {
  const SafetyAreaDetailPage({required this.status, super.key});

  final AreaOperationalStatus? status;

  @override
  ConsumerState<SafetyAreaDetailPage> createState() =>
      _SafetyAreaDetailPageState();
}

class _SafetyAreaDetailPageState extends ConsumerState<SafetyAreaDetailPage> {
  List<ActuatorState> _actuators = const [];

  @override
  void initState() {
    super.initState();
    _actuators = [...?widget.status?.actuators];
    final areaId = widget.status?.areaId;
    if (areaId == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(latestReadingsControllerProvider.notifier).load(areaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.status;
    if (area == null) {
      return const Center(
        child: Text('No hay información operativa disponible.'),
      );
    }
    final readings = ref.watch(latestReadingsControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(latestReadingsControllerProvider.notifier)
            .load(area.areaId, refresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(area.name, style: Theme.of(context).textTheme.headlineSmall),
            if (area.highlighted) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Destacada', style: TextStyle(color: scheme.primary)),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('CO₂: ${measureLabel(area.co2Ppm, 'ppm')}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Ruido: ${measureLabel(area.noiseDb, 'dB')}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Presencia: ${presenceLabel(area.presenceState)}'),
            const SizedBox(height: AppSpacing.sm),
            SeverityLabel(severity: area.severity),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  area.alertActive
                      ? Icons.campaign_outlined
                      : Icons.campaign_outlined,
                  color: area.alertActive ? AppColors.red : AppColors.slate,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    area.alertActive ? 'Alerta activa' : 'Sin alerta activa',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  context.push(
                    Uri(
                      path: RouteNames.activeAlerts,
                      queryParameters: {'areaId': area.areaId},
                    ).toString(),
                  );
                },
                child: const Text('Alertas de esta área'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Últimas lecturas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _LatestReadingsBody(state: readings),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Exposición reciente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  context.push(RouteNames.shortExposureHistory(area.areaId));
                },
                child: const Text('Ver historial reciente'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Actuadores', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (area.actuators.isEmpty)
              const Text('Sin actuadores')
            else
              for (final actuator in _actuators) ...[
                Text(actuatorSummary(actuator)),
                Text('Cambio: ${formatStatusDate(actuator.lastChangedAt)}'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _openOverride(area, actuator),
                    child: const Text('Control manual'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Actividad de actuadores',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  context.push(RouteNames.actuatorActions(area.areaId));
                },
                child: const Text('Ver actividad'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOverride(
    AreaOperationalStatus area,
    ActuatorState actuator,
  ) async {
    final updated = await context.push<ActuatorState>(
      RouteNames.actuatorOverride(area.areaId),
      extra: ActuatorOverrideTarget(
        areaId: area.areaId,
        areaName: area.name,
        actuator: actuator,
      ),
    );
    if (!mounted || updated == null) {
      return;
    }
    setState(() {
      _actuators = [
        for (final current in _actuators)
          if (current.type == updated.type) updated else current,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comando aplicado correctamente.')),
    );
  }
}

class _LatestReadingsBody extends StatelessWidget {
  const _LatestReadingsBody({required this.state});

  final LatestReadingsState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      LatestReadingsInitial() || LatestReadingsLoading() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      LatestReadingsNoTelemetry() => const Text(
        'No hay telemetría reciente disponible para esta área.',
      ),
      LatestReadingsNotFound() => const Text(
        'El área ya no se encuentra disponible.',
      ),
      LatestReadingsNetworkError() => const Text(
        'No se pudo obtener las lecturas recientes.',
      ),
      LatestReadingsFailure() => const Text(
        'No se pudo completar la solicitud.',
      ),
      LatestReadingsData(:final readings) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CarbonDioxideCard(reading: readings.carbonDioxide),
          const SizedBox(height: AppSpacing.md),
          _NoiseCard(reading: readings.noise),
          const SizedBox(height: AppSpacing.md),
          _PresenceCard(reading: readings.presence),
        ],
      ),
    };
  }
}

class _CarbonDioxideCard extends StatelessWidget {
  const _CarbonDioxideCard({required this.reading});

  final CarbonDioxideReading? reading;

  @override
  Widget build(BuildContext context) {
    final value = reading;
    return _ReadingCard(
      title: 'CO₂',
      value: value == null ? null : measureLabel(value.ppm, 'ppm'),
      deviceId: value?.deviceId,
      recordedAt: value?.recordedAt,
    );
  }
}

class _NoiseCard extends StatelessWidget {
  const _NoiseCard({required this.reading});

  final NoiseReading? reading;

  @override
  Widget build(BuildContext context) {
    final value = reading;
    return _ReadingCard(
      title: 'Ruido',
      value: value == null ? null : measureLabel(value.decibels, 'dB'),
      deviceId: value?.deviceId,
      recordedAt: value?.recordedAt,
    );
  }
}

class _PresenceCard extends StatelessWidget {
  const _PresenceCard({required this.reading});

  final PresenceReading? reading;

  @override
  Widget build(BuildContext context) {
    final value = reading;
    return _ReadingCard(
      title: 'Presencia',
      value: value == null ? null : presenceLabel(value.state),
      deviceId: value?.deviceId,
      recordedAt: value?.recordedAt,
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.title,
    required this.value,
    required this.deviceId,
    required this.recordedAt,
  });

  final String title;
  final String? value;
  final String? deviceId;
  final DateTime? recordedAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(value ?? 'Sin lectura reciente'),
            if (deviceId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Dispositivo: $deviceId'),
            ],
            if (recordedAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(formatStatusDate(recordedAt!)),
            ],
          ],
        ),
      ),
    );
  }
}

void openSafetyArea(BuildContext context, AreaOperationalStatus status) {
  context.push(RouteNames.safetyArea(status.areaId), extra: status);
}
