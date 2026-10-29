import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/entities/device_association.dart';
import '../providers/plant_setup_providers.dart';

class RegisterDevicePage extends ConsumerStatefulWidget {
  const RegisterDevicePage({required this.areaId, super.key});

  final String areaId;

  @override
  ConsumerState<RegisterDevicePage> createState() => _RegisterDevicePageState();
}

class _RegisterDevicePageState extends ConsumerState<RegisterDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  DeviceKind? _kind;
  var _submitted = false;
  var _retrying = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() == true;
    if (!valid || _kind == null) {
      return;
    }
    await ref
        .read(deviceRegistrationControllerProvider.notifier)
        .submit(
          deviceId: _deviceIdController.text.trim(),
          areaId: widget.areaId,
          kind: _kind!,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deviceRegistrationControllerProvider, (previous, next) {
      if (next is DeviceRegistrationSuccess) {
        ref
            .read(areaSetupControllerProvider.notifier)
            .applyAssociatedDevice(next.association);
      }
    });
    final state = ref.watch(deviceRegistrationControllerProvider);
    final busy =
        state is DeviceRegistrationIssuing ||
        state is DeviceRegistrationAssociating;
    final associationPending =
        state is DeviceRegistrationAssociationFailed ||
        (_retrying && state is DeviceRegistrationAssociating);

    if (state is DeviceRegistrationSuccess) {
      return _RegisteredDevice(association: state.association);
    }
    if (associationPending) {
      return _AssociationPending(
        retrying: state is DeviceRegistrationAssociating,
        onRetry: busy
            ? null
            : () {
                setState(() => _retrying = true);
                ref
                    .read(deviceRegistrationControllerProvider.notifier)
                    .retryAssociation();
              },
      );
    }
    return _RegisterDeviceForm(
      formKey: _formKey,
      areaId: widget.areaId,
      deviceIdController: _deviceIdController,
      kind: _kind,
      busy: busy,
      kindMissing: _submitted && _kind == null,
      progress: switch (state) {
        DeviceRegistrationIssuing() => 'Registrando dispositivo...',
        DeviceRegistrationAssociating() => 'Asociando al área...',
        _ => null,
      },
      message: switch (state) {
        DeviceRegistrationAlreadyExists() =>
          'Ya existe un dispositivo con ese identificador.',
        DeviceRegistrationAreaNotFound() =>
          'El área ya no se encuentra disponible.',
        DeviceRegistrationNetworkError() =>
          'No se pudo conectar con el servidor.',
        DeviceRegistrationFailure() => 'No se pudo completar la solicitud.',
        _ => null,
      },
      onKindChanged: busy
          ? null
          : (kind) {
              setState(() => _kind = kind);
            },
      onSubmit: busy ? null : _submit,
    );
  }
}

class _RegisterDeviceForm extends StatelessWidget {
  const _RegisterDeviceForm({
    required this.formKey,
    required this.areaId,
    required this.deviceIdController,
    required this.kind,
    required this.busy,
    required this.kindMissing,
    required this.progress,
    required this.message,
    required this.onKindChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String areaId;
  final TextEditingController deviceIdController;
  final DeviceKind? kind;
  final bool busy;
  final bool kindMissing;
  final String? progress;
  final String? message;
  final ValueChanged<DeviceKind>? onKindChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final errorColor = AppColors.red;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Registrar dispositivo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Área', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(areaId),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: deviceIdController,
              decoration: const InputDecoration(labelText: 'Identificador'),
              textInputAction: TextInputAction.done,
              enabled: !busy,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El identificador es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<DeviceKind>(
              emptySelectionAllowed: true,
              selected: {?kind},
              onSelectionChanged: onKindChanged == null
                  ? null
                  : (selection) {
                      if (selection.isEmpty) {
                        return;
                      }
                      onKindChanged!(selection.first);
                    },
              segments: const [
                ButtonSegment(value: DeviceKind.sensor, label: Text('Sensor')),
                ButtonSegment(
                  value: DeviceKind.actuator,
                  label: Text('Actuador'),
                ),
              ],
            ),
            if (kind == null && kindMissing) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'El tipo es obligatorio',
                style: TextStyle(color: errorColor),
              ),
            ],
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(progress!),
            ],
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(message!, style: TextStyle(color: errorColor)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onSubmit,
              child: busy
                  ? const SafePlantButtonProgress()
                  : const Text('Registrar dispositivo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisteredDevice extends StatelessWidget {
  const _RegisteredDevice({required this.association});

  final DeviceAssociation association;

  @override
  Widget build(BuildContext context) {
    final kind = switch (association.kind) {
      DeviceKind.sensor => 'Sensor',
      DeviceKind.actuator => 'Actuador',
    };
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Dispositivo registrado',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(association.deviceId),
        const SizedBox(height: AppSpacing.sm),
        Text(kind),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Volver a la ficha'),
        ),
      ],
    );
  }
}

class _AssociationPending extends StatelessWidget {
  const _AssociationPending({required this.onRetry, required this.retrying});

  final VoidCallback? onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'El dispositivo fue registrado, pero no pudo asociarse al área.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (retrying) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Asociando al área...'),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: onRetry,
          child: retrying
              ? const SafePlantButtonProgress()
              : const Text('Reintentar asociación'),
        ),
      ],
    );
  }
}
