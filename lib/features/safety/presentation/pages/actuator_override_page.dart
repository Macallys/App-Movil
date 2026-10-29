import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/actuator_state.dart';
import '../providers/safety_providers.dart';
import '../safety_labels.dart';

class ActuatorOverrideTarget {
  const ActuatorOverrideTarget({
    required this.areaId,
    required this.areaName,
    required this.actuator,
  });

  final String areaId;
  final String areaName;
  final ActuatorState actuator;
}

class ActuatorOverridePage extends ConsumerWidget {
  const ActuatorOverridePage({required this.target, super.key});

  final ActuatorOverrideTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(actuatorOverrideControllerProvider);
    ref.listen(actuatorOverrideControllerProvider, (previous, next) {
      if (next is! ActuatorOverrideSuccess || !Navigator.of(context).canPop()) {
        return;
      }
      Navigator.of(context).pop(next.actuator);
    });
    final shown = switch (state) {
      ActuatorOverrideSuccess(:final actuator) => actuator,
      _ => target.actuator,
    };
    final submitting = state is ActuatorOverrideSubmitting;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Control manual',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Área: ${target.areaName}'),
                const SizedBox(height: AppSpacing.sm),
                Text(actuatorTypeLabel(shown.type)),
                const SizedBox(height: AppSpacing.sm),
                Text('Estado actual: ${runStateLabel(shown.runState)}'),
                const SizedBox(height: AppSpacing.sm),
                Text('Modo: ${modeLabel(shown.mode)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Feedback(state: state),
        for (final command in _commands(shown.type)) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: submitting || command.state == shown.runState
                ? null
                : () => _confirm(context, ref, command),
            child: Text(command.label),
          ),
        ],
        if (submitting) ...[
          const SizedBox(height: AppSpacing.lg),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    _Command command,
  ) async {
    final controller = ref.read(actuatorOverrideControllerProvider.notifier);
    controller.beginConfirmation();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar control manual'),
          content: Text(
            'Se enviará el comando ${command.label} '
            '${_actuatorPhrase(target.actuator.type)} '
            'del área ${target.areaName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      controller.cancelConfirmation();
      return;
    }
    await controller.submit(
      areaId: target.areaId,
      type: target.actuator.type,
      targetState: command.state,
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.state});

  final ActuatorOverrideState state;

  @override
  Widget build(BuildContext context) {
    final message = switch (state) {
      ActuatorOverrideEdgeUnavailable() =>
        'No se pudo entregar el comando al dispositivo Edge. '
            'Verifica la conectividad del Edge e inténtalo nuevamente.',
      ActuatorOverrideNetworkError() => 'No se pudo conectar con el servidor.',
      ActuatorOverrideValidationError() =>
        'Ese comando no es válido para este actuador.',
      ActuatorOverrideFailure() => 'No se pudo completar la solicitud.',
      ActuatorOverrideSuccess() => 'Comando aplicado correctamente.',
      _ => null,
    };
    if (message == null) {
      return const SizedBox.shrink();
    }
    final failed =
        state is ActuatorOverrideEdgeUnavailable ||
        state is ActuatorOverrideNetworkError ||
        state is ActuatorOverrideValidationError ||
        state is ActuatorOverrideFailure;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        message,
        style: TextStyle(color: failed ? AppColors.red : AppColors.green),
      ),
    );
  }
}

class _Command {
  const _Command(this.state, this.label);

  final ActuatorRunState state;
  final String label;
}

List<_Command> _commands(ActuatorType type) {
  return switch (type) {
    ActuatorType.extractor => const [
      _Command(ActuatorRunState.on, 'Encender'),
      _Command(ActuatorRunState.off, 'Apagar'),
    ],
    ActuatorType.siren => const [
      _Command(ActuatorRunState.on, 'Activar'),
      _Command(ActuatorRunState.off, 'Desactivar'),
    ],
    ActuatorType.barrier => const [
      _Command(ActuatorRunState.deployed, 'Desplegar'),
      _Command(ActuatorRunState.retracted, 'Replegar'),
    ],
  };
}

String _actuatorPhrase(ActuatorType type) {
  return switch (type) {
    ActuatorType.extractor => 'al extractor',
    ActuatorType.siren => 'a la sirena',
    ActuatorType.barrier => 'a la barrera',
  };
}
