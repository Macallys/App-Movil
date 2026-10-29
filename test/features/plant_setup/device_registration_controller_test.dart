import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  final device = Device(
    deviceId: 'dev-1',
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: DateTime.utc(2026, 2, 1),
  );
  const association = DeviceAssociation(
    id: 'assoc-1',
    areaId: 'area-1',
    deviceId: 'dev-1',
    kind: DeviceKind.sensor,
  );

  test('success moves through issuing and associating', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <DeviceRegistrationState>[];
    container.listen(deviceRegistrationControllerProvider, (_, next) {
      seen.add(next);
    });

    final pending = container
        .read(deviceRegistrationControllerProvider.notifier)
        .submit(deviceId: 'dev-1', areaId: 'area-1', kind: DeviceKind.sensor);
    expect(
      container.read(deviceRegistrationControllerProvider),
      isA<DeviceRegistrationIssuing>(),
    );

    repository.issue.complete(Success(device));
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(deviceRegistrationControllerProvider),
      isA<DeviceRegistrationAssociating>(),
    );

    repository.associate.complete(const Success(association));
    await pending;

    expect(seen.first, isA<DeviceRegistrationIssuing>());
    expect(seen[1], isA<DeviceRegistrationAssociating>());
    expect(seen.last, isA<DeviceRegistrationSuccess>());
  });

  test('an issue conflict stops at deviceAlreadyExists', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <DeviceRegistrationState>[];
    container.listen(deviceRegistrationControllerProvider, (_, next) {
      seen.add(next);
    });

    final pending = container
        .read(deviceRegistrationControllerProvider.notifier)
        .submit(deviceId: 'dev-1', areaId: 'area-1', kind: DeviceKind.sensor);
    repository.issue.complete(const FailureResult(ConflictFailure()));
    await pending;

    expect(seen.first, isA<DeviceRegistrationIssuing>());
    expect(seen.last, isA<DeviceRegistrationAlreadyExists>());
    expect(repository.associateCalls, 0);
  });

  test('association failure keeps the issued device', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <DeviceRegistrationState>[];
    container.listen(deviceRegistrationControllerProvider, (_, next) {
      seen.add(next);
    });

    final pending = container
        .read(deviceRegistrationControllerProvider.notifier)
        .submit(deviceId: 'dev-1', areaId: 'area-1', kind: DeviceKind.sensor);
    repository.issue.complete(Success(device));
    await Future<void>.delayed(Duration.zero);
    repository.associate.complete(const FailureResult(NetworkFailure()));
    await pending;

    expect(seen[0], isA<DeviceRegistrationIssuing>());
    expect(seen[1], isA<DeviceRegistrationAssociating>());
    expect(seen.last, isA<DeviceRegistrationAssociationFailed>());
    expect(repository.issueCalls, 1);

    repository.associate = Completer<Result<DeviceAssociation>>();
    final retry = container
        .read(deviceRegistrationControllerProvider.notifier)
        .retryAssociation();
    expect(
      container.read(deviceRegistrationControllerProvider),
      isA<DeviceRegistrationAssociating>(),
    );
    repository.associate.complete(const Success(association));
    await retry;

    expect(
      container.read(deviceRegistrationControllerProvider),
      isA<DeviceRegistrationSuccess>(),
    );
    expect(repository.issueCalls, 1);
    expect(repository.associateCalls, 2);
  });
}

ProviderContainer _container(_Repository repository) {
  return ProviderContainer(
    overrides: [plantSetupRepositoryProvider.overrideWithValue(repository)],
  );
}

class _Repository implements PlantSetupRepository {
  Completer<Result<Device>> issue = Completer<Result<Device>>();
  Completer<Result<DeviceAssociation>> associate =
      Completer<Result<DeviceAssociation>>();
  var issueCalls = 0;
  var associateCalls = 0;

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) {
    issueCalls += 1;
    return issue.future;
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) {
    associateCalls += 1;
    return associate.future;
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

  @override
  Future<Result<List<Device>>> listDevices() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    throw UnimplementedError();
  }
}
