part of '../providers/plant_setup_providers.dart';

sealed class DeviceRegistrationState {
  const DeviceRegistrationState();
}

final class DeviceRegistrationInitial extends DeviceRegistrationState {
  const DeviceRegistrationInitial();
}

final class DeviceRegistrationIssuing extends DeviceRegistrationState {
  const DeviceRegistrationIssuing();
}

final class DeviceRegistrationAssociating extends DeviceRegistrationState {
  const DeviceRegistrationAssociating();
}

final class DeviceRegistrationSuccess extends DeviceRegistrationState {
  const DeviceRegistrationSuccess(this.association);

  final DeviceAssociation association;
}

final class DeviceRegistrationAlreadyExists extends DeviceRegistrationState {
  const DeviceRegistrationAlreadyExists();
}

final class DeviceRegistrationAreaNotFound extends DeviceRegistrationState {
  const DeviceRegistrationAreaNotFound();
}

final class DeviceRegistrationAssociationFailed
    extends DeviceRegistrationState {
  const DeviceRegistrationAssociationFailed({
    required this.device,
    required this.areaId,
    required this.deviceId,
    required this.kind,
  });

  final Device device;
  final String areaId;
  final String deviceId;
  final DeviceKind kind;
}

final class DeviceRegistrationNetworkError extends DeviceRegistrationState {
  const DeviceRegistrationNetworkError();
}

final class DeviceRegistrationFailure extends DeviceRegistrationState {
  const DeviceRegistrationFailure();
}

class DeviceRegistrationController extends Notifier<DeviceRegistrationState> {
  @override
  DeviceRegistrationState build() {
    return const DeviceRegistrationInitial();
  }

  Future<void> submit({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) async {
    if (_busy) {
      return;
    }
    state = const DeviceRegistrationIssuing();
    final result = await ref
        .read(registerDeviceUseCaseProvider)
        .call(
          deviceId: deviceId,
          areaId: areaId,
          kind: kind,
          onPhase: (phase) {
            state = switch (phase) {
              RegisterDevicePhase.issuing => const DeviceRegistrationIssuing(),
              RegisterDevicePhase.associating =>
                const DeviceRegistrationAssociating(),
            };
          },
        );
    state = switch (result) {
      RegisterDeviceSuccess(:final association) => DeviceRegistrationSuccess(
        association,
      ),
      RegisterDeviceIssueFailed(:final failure) => switch (failure) {
        ConflictFailure() => const DeviceRegistrationAlreadyExists(),
        NotFoundFailure() => const DeviceRegistrationAreaNotFound(),
        NetworkFailure() => const DeviceRegistrationNetworkError(),
        _ => const DeviceRegistrationFailure(),
      },
      RegisterDeviceAssociationFailed(:final device) =>
        DeviceRegistrationAssociationFailed(
          device: device,
          areaId: areaId,
          deviceId: deviceId,
          kind: kind,
        ),
    };
  }

  Future<void> retryAssociation() async {
    final current = state;
    if (current is! DeviceRegistrationAssociationFailed || _busy) {
      return;
    }
    state = const DeviceRegistrationAssociating();
    final result = await ref
        .read(registerDeviceUseCaseProvider)
        .associate(
          areaId: current.areaId,
          deviceId: current.deviceId,
          kind: current.kind,
        );
    state = switch (result) {
      Success(:final value) => DeviceRegistrationSuccess(value),
      FailureResult() => current,
    };
  }

  bool get _busy {
    return state is DeviceRegistrationIssuing ||
        state is DeviceRegistrationAssociating;
  }
}
