import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/list_devices.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';

void main() {
  final device = _device();

  test('a repository list is returned as-is', () async {
    final repository = _Repository(listResult: Success([device]));

    final result = await ListDevices(repository).call();

    expect((result as Success<List<Device>>).value.single.deviceId, 'dev-1');
  });

  test('an empty list stays a success', () async {
    final repository = _Repository(listResult: const Success([]));

    final result = await ListDevices(repository).call();

    expect((result as Success<List<Device>>).value, isEmpty);
  });

  test('a network failure is propagated', () async {
    final repository = _Repository(
      listResult: const FailureResult(NetworkFailure()),
    );

    final result = await ListDevices(repository).call();

    expect(
      (result as FailureResult<List<Device>>).failure,
      isA<NetworkFailure>(),
    );
  });
}

Device _device() {
  return Device(
    deviceId: 'dev-1',
    areaId: 'area-1',
    kind: DeviceKind.sensor,
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: DateTime.utc(2026, 2, 1),
  );
}

class _Repository implements PlantSetupRepository {
  _Repository({required this.listResult});

  final Result<List<Device>> listResult;

  @override
  Future<Result<List<Device>>> listDevices() async => listResult;

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
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
