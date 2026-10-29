import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../../../../core/shared/widgets/safeplant_status_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/plant_setup_providers.dart';
import '../widgets/device_card.dart';

class DeviceInventoryPage extends ConsumerStatefulWidget {
  const DeviceInventoryPage({super.key});

  @override
  ConsumerState<DeviceInventoryPage> createState() =>
      _DeviceInventoryPageState();
}

class _DeviceInventoryPageState extends ConsumerState<DeviceInventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceInventoryControllerProvider.notifier).loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceInventoryControllerProvider);
    return switch (state) {
      DeviceInventoryInitial() || DeviceInventoryLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      DeviceInventoryEmpty() => const SafePlantStatusView(
        icon: Icons.devices_outlined,
        message: 'No hay dispositivos registrados.',
      ),
      DeviceInventoryNetworkError() => const _InventoryMessage(
        'No se pudo conectar con el servidor.',
      ),
      DeviceInventoryNotFound() => const _InventoryMessage(
        'El inventario no se encuentra disponible.',
      ),
      DeviceInventoryFailure() => const _InventoryMessage(
        'No se pudo completar la solicitud.',
      ),
      DeviceInventoryData() => _InventoryList(
        state: state,
        onRevoke: (device) => _confirmRevoke(device),
      ),
    };
  }

  Future<void> _confirmRevoke(Device device) async {
    final current = ref.read(deviceInventoryControllerProvider);
    if (current is DeviceInventoryData && current.revokingDeviceId != null) {
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Revocar este dispositivo?'),
          content: const Text(
            'El dispositivo dejará de tener credenciales válidas.',
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
              child: const Text('Revocar'),
            ),
          ],
        );
      },
    );
    if (accepted == true && mounted) {
      await ref
          .read(deviceInventoryControllerProvider.notifier)
          .revokeDevice(device.deviceId);
    }
  }
}

class _InventoryMessage extends StatelessWidget {
  const _InventoryMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafePlantStatusView(icon: Icons.error_outline, message: message),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.state, required this.onRevoke});

  final DeviceInventoryData state;
  final ValueChanged<Device> onRevoke;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final feedback = switch (state.revokeFeedback) {
      DeviceRevokeFeedback.notFound =>
        'El dispositivo ya no se encuentra disponible.',
      DeviceRevokeFeedback.network => 'No se pudo conectar con el servidor.',
      DeviceRevokeFeedback.forbidden =>
        'No tiene permiso para revocar este dispositivo.',
      DeviceRevokeFeedback.unauthorized =>
        'La sesión no permite completar la solicitud.',
      DeviceRevokeFeedback.failure => 'No se pudo revocar el dispositivo.',
      null => null,
    };
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.devices.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventario de dispositivos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (feedback != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(feedback, style: const TextStyle(color: AppColors.red)),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          );
        }
        final device = state.devices[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: DeviceCard(
            key: ValueKey(device.deviceId),
            device: device,
            now: now,
            revoking: state.revokingDeviceId == device.deviceId,
            onRevoke: device.isRevoked || state.revokingDeviceId != null
                ? null
                : () => onRevoke(device),
          ),
        );
      },
    );
  }
}
