part of '../providers/plant_setup_providers.dart';

sealed class AreaSetupState {
  const AreaSetupState();
}

final class AreaSetupInitial extends AreaSetupState {
  const AreaSetupInitial();
}

final class AreaSetupLoading extends AreaSetupState {
  const AreaSetupLoading();
}

final class AreaSetupData extends AreaSetupState {
  const AreaSetupData(this.setup);

  final AreaSetup setup;
}

final class AreaSetupNotFound extends AreaSetupState {
  const AreaSetupNotFound();
}

final class AreaSetupNetworkError extends AreaSetupState {
  const AreaSetupNetworkError();
}

final class AreaSetupFailure extends AreaSetupState {
  const AreaSetupFailure();
}

class AreaSetupController extends Notifier<AreaSetupState> {
  @override
  AreaSetupState build() {
    return const AreaSetupInitial();
  }

  Future<void> load(String areaId) async {
    if (state is AreaSetupLoading) {
      return;
    }
    state = const AreaSetupLoading();
    final result = await ref
        .read(getAreaSetupUseCaseProvider)
        .call(areaId: areaId);
    state = switch (result) {
      Success(:final value) => AreaSetupData(value),
      FailureResult(:final failure) => switch (failure) {
        NotFoundFailure() => const AreaSetupNotFound(),
        NetworkFailure() => const AreaSetupNetworkError(),
        _ => const AreaSetupFailure(),
      },
    };
  }

  void applyThresholds(AreaThresholds thresholds) {
    final current = state;
    if (current is! AreaSetupData || current.setup.id != thresholds.areaId) {
      return;
    }
    state = AreaSetupData(
      AreaSetup(
        id: current.setup.id,
        name: current.setup.name,
        location: current.setup.location,
        co2LimitPpm: thresholds.co2LimitPpm,
        noiseLimitDb: thresholds.noiseLimitDb,
        devices: current.setup.devices,
      ),
    );
  }

  void applyAssociatedDevice(DeviceAssociation association) {
    final current = state;
    if (current is! AreaSetupData || current.setup.id != association.areaId) {
      return;
    }
    final alreadyListed = current.setup.devices.any(
      (device) => device.id == association.id,
    );
    if (alreadyListed) {
      return;
    }
    state = AreaSetupData(
      AreaSetup(
        id: current.setup.id,
        name: current.setup.name,
        location: current.setup.location,
        co2LimitPpm: current.setup.co2LimitPpm,
        noiseLimitDb: current.setup.noiseLimitDb,
        devices: [
          ...current.setup.devices,
          AreaDevice(
            id: association.id,
            deviceId: association.deviceId,
            kind: association.kind,
          ),
        ],
      ),
    );
  }
}
