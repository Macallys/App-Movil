part of '../providers/plant_setup_providers.dart';

sealed class DeviceInventoryState {
  const DeviceInventoryState();
}

final class DeviceInventoryInitial extends DeviceInventoryState {
  const DeviceInventoryInitial();
}

final class DeviceInventoryLoading extends DeviceInventoryState {
  const DeviceInventoryLoading();
}

final class DeviceInventoryEmpty extends DeviceInventoryState {
  const DeviceInventoryEmpty();
}

final class DeviceInventoryNetworkError extends DeviceInventoryState {
  const DeviceInventoryNetworkError();
}

final class DeviceInventoryNotFound extends DeviceInventoryState {
  const DeviceInventoryNotFound();
}

final class DeviceInventoryFailure extends DeviceInventoryState {
  const DeviceInventoryFailure();
}

enum DeviceRevokeFeedback {
  notFound,
  network,
  forbidden,
  unauthorized,
  failure,
}

final class DeviceInventoryData extends DeviceInventoryState {
  const DeviceInventoryData({
    required this.devices,
    this.revokingDeviceId,
    this.revokeFeedback,
  });

  final List<Device> devices;
  final String? revokingDeviceId;
  final DeviceRevokeFeedback? revokeFeedback;
}

class DeviceInventoryController extends Notifier<DeviceInventoryState> {
  @override
  DeviceInventoryState build() {
    return const DeviceInventoryInitial();
  }

  Future<void> loadDevices() async {
    if (state is DeviceInventoryLoading) {
      return;
    }
    state = const DeviceInventoryLoading();
    final result = await ref.read(listDevicesUseCaseProvider).call();
    state = switch (result) {
      Success(:final value) when value.isEmpty => const DeviceInventoryEmpty(),
      Success(:final value) => DeviceInventoryData(devices: value),
      FailureResult(:final failure) => switch (failure) {
        NetworkFailure() => const DeviceInventoryNetworkError(),
        NotFoundFailure() => const DeviceInventoryNotFound(),
        _ => const DeviceInventoryFailure(),
      },
    };
  }

  Future<void> revokeDevice(String deviceId) async {
    final current = state;
    if (current is! DeviceInventoryData || current.revokingDeviceId != null) {
      return;
    }
    final target = current.devices.where((device) {
      return device.deviceId == deviceId;
    });
    if (target.isEmpty || target.first.isRevoked) {
      return;
    }
    state = DeviceInventoryData(
      devices: current.devices,
      revokingDeviceId: deviceId,
    );
    final result = await ref
        .read(revokeDeviceUseCaseProvider)
        .call(deviceId: deviceId);
    final latest = state;
    if (latest is! DeviceInventoryData) {
      return;
    }
    state = switch (result) {
      Success(:final value) => DeviceInventoryData(
        devices: [
          for (final device in latest.devices)
            if (device.deviceId == value.deviceId)
              device.withRevocation(value.revokedAt)
            else
              device,
        ],
      ),
      FailureResult(:final failure) => DeviceInventoryData(
        devices: latest.devices,
        revokeFeedback: switch (failure) {
          NotFoundFailure() => DeviceRevokeFeedback.notFound,
          NetworkFailure() => DeviceRevokeFeedback.network,
          ForbiddenFailure() => DeviceRevokeFeedback.forbidden,
          UnauthorizedFailure() => DeviceRevokeFeedback.unauthorized,
          _ => DeviceRevokeFeedback.failure,
        },
      ),
    };
  }
}
