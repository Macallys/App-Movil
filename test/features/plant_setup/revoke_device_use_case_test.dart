import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/revoke_device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';

void main() {
  test('the same device id reaches the repository', () async {
    final repository = _Repository(result: _revocation());

    await RevokeDevice(repository).call(deviceId: 'dev-9');

    expect(repository.deviceId, 'dev-9');
  });

  test('success returns the revocation', () async {
    final repository = _Repository(result: _revocation());

    final result = await RevokeDevice(repository).call(deviceId: 'dev-1');

    expect(
      (result as Success<DeviceRevocation>).value.revokedAt,
      DateTime.utc(2026, 3, 1),
    );
  });

  test('failure is propagated', () async {
    final repository = _Repository(
      result: const FailureResult(NetworkFailure()),
    );

    final result = await RevokeDevice(repository).call(deviceId: 'dev-1');

    expect(
      (result as FailureResult<DeviceRevocation>).failure,
      isA<NetworkFailure>(),
    );
  });
}

Success<DeviceRevocation> _revocation() {
  return Success(
    DeviceRevocation(deviceId: 'dev-1', revokedAt: DateTime.utc(2026, 3, 1)),
  );
}

class _Repository implements PlantSetupRepository {
  _Repository({required this.result});

  final Result<DeviceRevocation> result;
  String? deviceId;

  @override
  Future<Result<DeviceRevocation>> revokeDevice({
    required String deviceId,
  }) async {
    this.deviceId = deviceId;
    return result;
  }

  @override
  Future<Result<List<Device>>> listDevices() {
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
