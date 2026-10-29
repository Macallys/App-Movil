import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  test('load moves from loading to data', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <DeviceInventoryState>[];
    container.listen(deviceInventoryControllerProvider, (_, next) {
      seen.add(next);
    });

    final pending = container
        .read(deviceInventoryControllerProvider.notifier)
        .loadDevices();
    expect(
      container.read(deviceInventoryControllerProvider),
      isA<DeviceInventoryLoading>(),
    );
    repository.list.complete(Success([_device()]));
    await pending;

    expect(seen.first, isA<DeviceInventoryLoading>());
    final data = container.read(
      deviceInventoryControllerProvider,
    ) as DeviceInventoryData;
    expect(data.devices.single.deviceId, 'dev-1');
    expect(data.devices.single.isRevoked, isFalse);
  });

  test('an empty list becomes empty', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);

    final pending = container
        .read(deviceInventoryControllerProvider.notifier)
        .loadDevices();
    repository.list.complete(const Success([]));
    await pending;

    expect(
      container.read(deviceInventoryControllerProvider),
      isA<DeviceInventoryEmpty>(),
    );
  });

  test('revoke updates only the returned device', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <DeviceInventoryState>[];
    container.listen(deviceInventoryControllerProvider, (_, next) {
      seen.add(next);
    });

    final loading = container
        .read(deviceInventoryControllerProvider.notifier)
        .loadDevices();
    repository.list.complete(Success([_device(), _other()]));
    await loading;

    final revoking = container
        .read(deviceInventoryControllerProvider.notifier)
        .revokeDevice('dev-1');
    final during = container.read(deviceInventoryControllerProvider);
    expect(during, isA<DeviceInventoryData>());
    expect((during as DeviceInventoryData).revokingDeviceId, 'dev-1');
    expect(during.devices, hasLength(2));

    repository.revoke.complete(
      Success(
        DeviceRevocation(
          deviceId: 'dev-1',
          revokedAt: DateTime.utc(2026, 3, 1),
        ),
      ),
    );
    await revoking;

    final data = container.read(
      deviceInventoryControllerProvider,
    ) as DeviceInventoryData;
    expect(data.devices.first.isRevoked, isTrue);
    expect(data.devices.first.revokedAt, DateTime.utc(2026, 3, 1));
    expect(data.devices.last.isRevoked, isFalse);
    expect(data.revokingDeviceId, isNull);
    expect(seen.whereType<DeviceInventoryLoading>(), isNotEmpty);
  });

  test('a revoke failure leaves the device active', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);

    final loading = container
        .read(deviceInventoryControllerProvider.notifier)
        .loadDevices();
    repository.list.complete(Success([_device()]));
    await loading;

    final revoking = container
        .read(deviceInventoryControllerProvider.notifier)
        .revokeDevice('dev-1');
    repository.revoke.complete(const FailureResult(NetworkFailure()));
    await revoking;

    final data = container.read(
      deviceInventoryControllerProvider,
    ) as DeviceInventoryData;
    expect(data.devices.single.isRevoked, isFalse);
    expect(data.revokeFeedback, DeviceRevokeFeedback.network);
    expect(repository.revokeCalls, 1);
  });
}

ProviderContainer _container(_Repository repository) {
  return ProviderContainer(
    overrides: [plantSetupRepositoryProvider.overrideWithValue(repository)],
  );
}

Device _device() {
  return Device(
    deviceId: 'dev-1',
    areaId: 'area-1',
    kind: DeviceKind.sensor,
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: DateTime.utc(2027, 1, 1),
  );
}

Device _other() {
  return Device(
    deviceId: 'dev-2',
    areaId: 'area-2',
    kind: DeviceKind.actuator,
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: DateTime.utc(2027, 1, 1),
  );
}

class _Repository implements PlantSetupRepository {
  Completer<Result<List<Device>>> list = Completer<Result<List<Device>>>();
  Completer<Result<DeviceRevocation>> revoke =
      Completer<Result<DeviceRevocation>>();
  var revokeCalls = 0;

  @override
  Future<Result<List<Device>>> listDevices() => list.future;

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    revokeCalls += 1;
    return revoke.future;
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
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    throw UnimplementedError();
  }
}
