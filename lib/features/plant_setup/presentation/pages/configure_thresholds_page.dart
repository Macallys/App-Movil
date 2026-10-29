import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/area_thresholds.dart';
import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/plant_setup_providers.dart';

class ConfigureThresholdsPage extends ConsumerStatefulWidget {
  const ConfigureThresholdsPage({
    required this.areaId,
    this.co2LimitPpm,
    this.noiseLimitDb,
    super.key,
  });

  final String areaId;
  final num? co2LimitPpm;
  final num? noiseLimitDb;

  @override
  ConsumerState<ConfigureThresholdsPage> createState() =>
      _ConfigureThresholdsPageState();
}

class _ConfigureThresholdsPageState
    extends ConsumerState<ConfigureThresholdsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _co2Controller;
  late final TextEditingController _noiseController;

  @override
  void initState() {
    super.initState();
    _co2Controller = TextEditingController(text: _initial(widget.co2LimitPpm));
    _noiseController = TextEditingController(
      text: _initial(widget.noiseLimitDb),
    );
  }

  @override
  void dispose() {
    _co2Controller.dispose();
    _noiseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final co2 = _parseLimit(_co2Controller.text);
    final noise = _parseLimit(_noiseController.text);
    if (co2 == null || noise == null) {
      return;
    }
    await ref
        .read(configureThresholdsControllerProvider.notifier)
        .submit(areaId: widget.areaId, co2LimitPpm: co2, noiseLimitDb: noise);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(configureThresholdsControllerProvider, (previous, next) {
      if (next is ConfigureThresholdsSaved) {
        ref
            .read(areaSetupControllerProvider.notifier)
            .applyThresholds(next.thresholds);
      }
    });
    final state = ref.watch(configureThresholdsControllerProvider);
    final loading = state is ConfigureThresholdsLoading;
    final saved = state is ConfigureThresholdsSaved ? state.thresholds : null;
    final message = switch (state) {
      ConfigureThresholdsValidationError() =>
        'Los valores ingresados no son válidos.',
      ConfigureThresholdsNotFound() => 'El área ya no se encuentra disponible.',
      ConfigureThresholdsNetworkError() =>
        'No se pudo conectar con el servidor.',
      ConfigureThresholdsFailure() => 'No se pudo completar la solicitud.',
      _ => null,
    };

    if (saved != null) {
      return _SavedThresholds(thresholds: saved);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configurar umbrales',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _co2Controller,
              decoration: const InputDecoration(
                labelText: 'Límite de CO₂ (ppm)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textInputAction: TextInputAction.next,
              enabled: !loading,
              validator: _validateLimit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _noiseController,
              decoration: const InputDecoration(
                labelText: 'Límite de ruido (dB)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textInputAction: TextInputAction.done,
              enabled: !loading,
              validator: _validateLimit,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(message, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SafePlantButtonProgress()
                  : const Text('Guardar configuración'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedThresholds extends StatelessWidget {
  const _SavedThresholds({required this.thresholds});

  final AreaThresholds thresholds;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Configuración guardada',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('CO₂: ${thresholds.co2LimitPpm} ppm'),
        const SizedBox(height: AppSpacing.sm),
        Text('Ruido: ${thresholds.noiseLimitDb} dB'),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Volver a la ficha'),
        ),
      ],
    );
  }
}

String _initial(num? value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String? _validateLimit(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return 'El valor es obligatorio';
  }
  if (_parseLimit(raw) == null) {
    return 'Los valores ingresados no son válidos.';
  }
  return null;
}

num? _parseLimit(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final normalized = trimmed.contains(',') && !trimmed.contains('.')
      ? trimmed.replaceAll(',', '.')
      : trimmed;
  return num.tryParse(normalized);
}
