import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/register_device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';

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

  test('issue and association success returns register success', () async {
    final repository = _Repository(
      issueResult: Success(device),
      associationResult: const Success(association),
    );

    final result = await RegisterDevice(repository)
        .call(deviceId: 'dev-1', areaId: 'area-1', kind: DeviceKind.sensor);

    expect(result, isA<RegisterDeviceSuccess>());
    expect(repository.issueCalls, 1);
    expect(repository.associateCalls, 1);
  });

  test('issue failure does not associate', () async {
    final repository = _Repository(
      issueResult: const FailureResult(ConflictFailure()),
      associationResult: const Success(association),
    );

    final result = await RegisterDevice(repository)
        .call(deviceId: 'dev-1', areaId: 'area-1', kind: DeviceKind.sensor);

    expect(result, isA<RegisterDeviceIssueFailed>());
    expect(repository.associateCalls, 0);
  });

  test('association failure after issue is a partial failure', () async {
    final repository = _Repository(
      issueResult: Success(device),
      associationResult: const FailureResult(NetworkFailure()),
    );

    final result = await RegisterDevice(repository).call(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: DeviceKind.sensor,
    ) as RegisterDeviceAssociationFailed;

    expect(result.device.deviceId, 'dev-1');
    expect(result.failure, isA<NetworkFailure>());
    expect(repository.issueCalls, 1);
    expect(repository.associateCalls, 1);
  });

  test('retry association does not issue the device again', () async {
    final repository = _Repository(
      issueResult: Success(device),
      associationResult: const FailureResult(NetworkFailure()),
    );
    final useCase = RegisterDevice(repository);

    await useCase.call(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: DeviceKind.sensor,
    );
    repository.associationResult = const Success(association);
    final retried = await useCase.associate(
      areaId: 'area-1',
      deviceId: 'dev-1',
      kind: DeviceKind.sensor,
    );

    expect(retried, isA<Success<DeviceAssociation>>());
    expect(repository.issueCalls, 1);
    expect(repository.associateCalls, 2);
  });
}

class _Repository implements PlantSetupRepository {
  _Repository({required this.issueResult, required this.associationResult});

  Result<Device> issueResult;
  Result<DeviceAssociation> associationResult;
  var issueCalls = 0;
  var associateCalls = 0;

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) async {
    issueCalls += 1;
    return issueResult;
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) async {
    associateCalls += 1;
    return associationResult;
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
