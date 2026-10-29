import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/configure_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  test('configure moves from loading to saved', () async {
    final completer = Completer<Result<AreaThresholds>>();
    final container = _container(_Pending(completer));
    addTearDown(container.dispose);
    container.listen(configureThresholdsControllerProvider, (_, _) {});

    final pending = container
        .read(configureThresholdsControllerProvider.notifier)
        .submit(areaId: 'area-1', co2LimitPpm: 800, noiseLimitDb: 85.5);

    expect(
      container.read(configureThresholdsControllerProvider),
      isA<ConfigureThresholdsLoading>(),
    );

    completer.complete(
      const Success(
        AreaThresholds(areaId: 'area-1', co2LimitPpm: 800, noiseLimitDb: 85.5),
      ),
    );
    await pending;

    final state = container.read(
      configureThresholdsControllerProvider,
    ) as ConfigureThresholdsSaved;
    expect(state.thresholds.noiseLimitDb, 85.5);
  });

  test('validation leaves validationError', () async {
    final container = _container(
      _Fixed(const FailureResult(ValidationFailure())),
    );
    addTearDown(container.dispose);
    container.listen(configureThresholdsControllerProvider, (_, _) {});

    await container
        .read(configureThresholdsControllerProvider.notifier)
        .submit(areaId: 'area-1', co2LimitPpm: 1, noiseLimitDb: 1);

    expect(
      container.read(configureThresholdsControllerProvider),
      isA<ConfigureThresholdsValidationError>(),
    );
  });

  test('network failure leaves networkError', () async {
    final container = _container(_Fixed(const FailureResult(NetworkFailure())));
    addTearDown(container.dispose);
    container.listen(configureThresholdsControllerProvider, (_, _) {});

    await container
        .read(configureThresholdsControllerProvider.notifier)
        .submit(areaId: 'area-1', co2LimitPpm: 1, noiseLimitDb: 1);

    expect(
      container.read(configureThresholdsControllerProvider),
      isA<ConfigureThresholdsNetworkError>(),
    );
  });
}

ProviderContainer _container(ConfigureThresholds useCase) {
  return ProviderContainer(
    overrides: [configureThresholdsUseCaseProvider.overrideWithValue(useCase)],
  );
}

class _Pending extends ConfigureThresholds {
  _Pending(this.completer) : super(_IdleRepository());

  final Completer<Result<AreaThresholds>> completer;

  @override
  Future<Result<AreaThresholds>> call({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    return completer.future;
  }
}

class _Fixed extends ConfigureThresholds {
  _Fixed(this.result) : super(_IdleRepository());

  final Result<AreaThresholds> result;

  @override
  Future<Result<AreaThresholds>> call({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    return result;
  }
}

class _IdleRepository implements PlantSetupRepository {
  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaSetup>> getAreaSetup({required String areaId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Device>>> listDevices() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    throw UnimplementedError();
  }
}
