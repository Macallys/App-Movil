import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/area_setup.dart';
import '../providers/plant_setup_providers.dart';

class AreaSetupPage extends ConsumerStatefulWidget {
  const AreaSetupPage({required this.areaId, super.key});

  final String areaId;

  @override
  ConsumerState<AreaSetupPage> createState() => _AreaSetupPageState();
}

class _AreaSetupPageState extends ConsumerState<AreaSetupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(areaSetupControllerProvider.notifier).load(widget.areaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(areaSetupControllerProvider);
    return switch (state) {
      AreaSetupInitial() ||
      AreaSetupLoading() => const Center(child: CircularProgressIndicator()),
      AreaSetupData(:final setup) => _AreaSetupBody(setup: setup),
      AreaSetupNotFound() => const _AreaSetupMessage(
        'El área ya no se encuentra disponible.',
      ),
      AreaSetupNetworkError() => _AreaSetupMessage(
        'No se pudo conectar con el servidor.',
        onRetry: () {
          ref.read(areaSetupControllerProvider.notifier).load(widget.areaId);
        },
      ),
      AreaSetupFailure() => _AreaSetupMessage(
        'No se pudo completar la solicitud.',
        onRetry: () {
          ref.read(areaSetupControllerProvider.notifier).load(widget.areaId);
        },
      ),
    };
  }
}

class _AreaSetupBody extends StatelessWidget {
  const _AreaSetupBody({required this.setup});

  final AreaSetup setup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(setup.name, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(setup.location, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        Text('Límite de CO₂', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(_co2(setup.co2LimitPpm)),
        const SizedBox(height: AppSpacing.md),
        Text('Límite de ruido', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(_noise(setup.noiseLimitDb)),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () {
            context.push(
              RouteNames.configureThresholds(
                setup.id,
                co2LimitPpm: setup.co2LimitPpm,
                noiseLimitDb: setup.noiseLimitDb,
              ),
            );
          },
          child: const Text('Configurar umbrales'),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () {
            context.push(RouteNames.registerDevice(setup.id));
          },
          child: const Text('Agregar dispositivo'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Dispositivos', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (setup.devices.isEmpty)
          const Text('No hay dispositivos asociados.')
        else
          ...setup.devices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('${device.deviceId} · ${_kindLabel(device.kind)}'),
            ),
          ),
      ],
    );
  }

  String _co2(num? value) {
    if (value == null) {
      return 'No configurado';
    }
    return 'CO₂: $value ppm';
  }

  String _noise(num? value) {
    if (value == null) {
      return 'No configurado';
    }
    return 'Ruido: $value dB';
  }

  String _kindLabel(DeviceKind kind) {
    return switch (kind) {
      DeviceKind.sensor => 'Sensor',
      DeviceKind.actuator => 'Actuador',
    };
  }
}

class _AreaSetupMessage extends StatelessWidget {
  const _AreaSetupMessage(this.message, {this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
