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

void main() {
  test('ConfigureThresholds forwards the area and both limits', () async {
    final repository = _Repository(
      const Success(
        AreaThresholds(areaId: 'area-1', co2LimitPpm: 800, noiseLimitDb: 85.5),
      ),
    );

    final result = await ConfigureThresholds(repository)
        .call(areaId: 'area-1', co2LimitPpm: 800, noiseLimitDb: 85.5);

    expect(repository.areaId, 'area-1');
    expect(repository.co2LimitPpm, 800);
    expect(repository.noiseLimitDb, 85.5);
    expect(repository.noiseLimitDb, isNot(85));
    final saved = (result as Success<AreaThresholds>).value;
    expect(saved.co2LimitPpm, 800);
    expect(saved.noiseLimitDb, 85.5);
  });

  test('ConfigureThresholds propagates ValidationFailure', () async {
    final repository = _Repository(const FailureResult(ValidationFailure()));

    final result = await ConfigureThresholds(repository)
        .call(areaId: 'area-1', co2LimitPpm: 1, noiseLimitDb: 1);

    expect(
      (result as FailureResult<AreaThresholds>).failure,
      isA<ValidationFailure>(),
    );
  });
}

class _Repository implements PlantSetupRepository {
  _Repository(this.result);

  final Result<AreaThresholds> result;
  String? areaId;
  num? co2LimitPpm;
  num? noiseLimitDb;

  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    this.areaId = areaId;
    this.co2LimitPpm = co2LimitPpm;
    this.noiseLimitDb = noiseLimitDb;
    return result;
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
