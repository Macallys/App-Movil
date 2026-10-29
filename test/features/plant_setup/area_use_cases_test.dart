import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/create_area.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/get_area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';

void main() {
  test('CreateArea forwards name and location and returns the area', () async {
    final repository = _Repository(
      createResult: const Success(
        IndustrialArea(id: 'area-1', name: 'Horno', location: 'Nave 1'),
      ),
    );

    final result = await CreateArea(repository)
        .call(name: 'Horno', location: 'Nave 1');

    expect(repository.createdName, 'Horno');
    expect(repository.createdLocation, 'Nave 1');
    expect(
      result,
      isA<Success<IndustrialArea>>().having(
        (value) => value.value.id,
        'id',
        'area-1',
      ),
    );
  });

  test('CreateArea propagates ConflictFailure', () async {
    final repository = _Repository(
      createResult: const FailureResult(ConflictFailure()),
    );

    final result = await CreateArea(repository)
        .call(name: 'Horno', location: 'Nave 1');

    expect(result, isA<FailureResult<IndustrialArea>>());
    expect(
      (result as FailureResult<IndustrialArea>).failure,
      isA<ConflictFailure>(),
    );
  });

  test('GetAreaSetup uses the requested area id', () async {
    final repository = _Repository(setup: _setup());

    final result = await GetAreaSetup(repository).call(areaId: 'area-9');

    expect(repository.requestedAreaId, 'area-9');
    expect(result, isA<Success<AreaSetup>>());
    expect((result as Success<AreaSetup>).value.name, 'Horno');
  });

  test('GetAreaSetup propagates NotFoundFailure', () async {
    final repository = _Repository(setupFailure: const NotFoundFailure());

    final result = await GetAreaSetup(repository).call(areaId: 'missing');

    expect(result, isA<FailureResult<AreaSetup>>());
    expect(
      (result as FailureResult<AreaSetup>).failure,
      isA<NotFoundFailure>(),
    );
  });
}

AreaSetup _setup() {
  return const AreaSetup(
    id: 'area-9',
    name: 'Horno',
    location: 'Nave 1',
    co2LimitPpm: null,
    noiseLimitDb: null,
    devices: [],
  );
}

class _Repository implements PlantSetupRepository {
  _Repository({this.createResult, this.setup, this.setupFailure});

  final Result<IndustrialArea>? createResult;
  final AreaSetup? setup;
  final Failure? setupFailure;
  String? createdName;
  String? createdLocation;
  String? requestedAreaId;

  @override
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  }) async {
    createdName = name;
    createdLocation = location;
    return createResult!;
  }

  @override
  Future<Result<AreaSetup>> getAreaSetup({required String areaId}) async {
    requestedAreaId = areaId;
    if (setupFailure != null) {
      return FailureResult(setupFailure!);
    }
    return Success(setup!);
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
