import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_thresholds_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/device_association_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/device_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/industrial_area_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/issue_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/list_devices_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/revoke_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/area_setup_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/area_thresholds_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_association_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/industrial_area_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/repositories/plant_setup_repository_impl.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';

import 'support/fake_plant_setup_remote.dart';

void main() {
  test('201 becomes an industrial area', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        created: const IndustrialAreaDto(
          id: 'area-1',
          name: 'Horno',
          location: 'Nave 1',
        ),
      ),
    );

    final result = await repository.createArea(
      name: 'Horno',
      location: 'Nave 1',
    );

    expect(result, isA<Success<IndustrialArea>>());
    expect((result as Success<IndustrialArea>).value.location, 'Nave 1');
  });

  test('409 area_name_duplicate becomes ConflictFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        createError: const ApiException(
          message: 'Request failed',
          statusCode: 409,
          code: 'area_name_duplicate',
        ),
      ),
    );

    final result = await repository.createArea(
      name: 'Horno',
      location: 'Nave 1',
    );

    expect(result, isA<FailureResult<IndustrialArea>>());
    expect(
      (result as FailureResult<IndustrialArea>).failure,
      isA<ConflictFailure>(),
    );
  });

  test('404 becomes NotFoundFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        setupError: const ApiException(
          message: 'Request failed',
          statusCode: 404,
          code: 'area_not_found',
        ),
      ),
    );

    final result = await repository.getAreaSetup(areaId: 'missing');

    expect(result, isA<FailureResult<AreaSetup>>());
    expect(
      (result as FailureResult<AreaSetup>).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('a response without status becomes NetworkFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        createError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.createArea(
      name: 'Horno',
      location: 'Nave 1',
    );

    expect(
      (result as FailureResult<IndustrialArea>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('200 becomes area thresholds', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        thresholds: const AreaThresholdsDto(
          areaId: 'area-1',
          co2LimitPpm: 800,
          noiseLimitDb: 85.5,
        ),
      ),
    );

    final result = await repository.configureEnvironmentalThresholds(
      areaId: 'area-1',
      co2LimitPpm: 800,
      noiseLimitDb: 85.5,
    );

    final thresholds = (result as Success<AreaThresholds>).value;
    expect(thresholds.co2LimitPpm, 800);
    expect(thresholds.noiseLimitDb, 85.5);
  });

  test('404 becomes NotFoundFailure for thresholds', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        thresholdsError: const ApiException(
          message: 'Request failed',
          statusCode: 404,
          code: 'area_not_found',
        ),
      ),
    );

    final result = await repository.configureEnvironmentalThresholds(
      areaId: 'missing',
      co2LimitPpm: 800,
      noiseLimitDb: 85,
    );

    expect(
      (result as FailureResult<AreaThresholds>).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('422 becomes ValidationFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        thresholdsError: const ApiException(
          message: 'Request failed',
          statusCode: 422,
        ),
      ),
    );

    final result = await repository.configureEnvironmentalThresholds(
      areaId: 'area-1',
      co2LimitPpm: 800,
      noiseLimitDb: 85,
    );

    expect(
      (result as FailureResult<AreaThresholds>).failure,
      isA<ValidationFailure>(),
    );
  });

  test('a threshold request without status becomes NetworkFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        thresholdsError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.configureEnvironmentalThresholds(
      areaId: 'area-1',
      co2LimitPpm: 800,
      noiseLimitDb: 85,
    );

    expect(
      (result as FailureResult<AreaThresholds>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('201 issue becomes a device', () async {
    final issuedAt = DateTime.utc(2026, 1, 1);
    final expiresAt = DateTime.utc(2026, 2, 1);
    final repository = _repository(
      FakePlantSetupRemote(
        issued: IssueDeviceResponseDto(
          deviceId: 'dev-1',
          issuedAt: issuedAt,
          expiresAt: expiresAt,
        ),
      ),
    );

    final result = await repository.issueDevice(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: DeviceKind.sensor,
    );

    final device = (result as Success<Device>).value;
    expect(device.deviceId, 'dev-1');
    expect(device.issuedAt, issuedAt);
    expect(device.expiresAt, expiresAt);
  });

  test('409 device_already_exists becomes ConflictFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        issueError: const ApiException(
          message: 'Request failed',
          statusCode: 409,
          code: 'device_already_exists',
        ),
      ),
    );

    final result = await repository.issueDevice(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: DeviceKind.sensor,
    );

    expect((result as FailureResult<Device>).failure, isA<ConflictFailure>());
  });

  test('422 area_not_found becomes NotFoundFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        issueError: const ApiException(
          message: 'Request failed',
          statusCode: 422,
          code: 'area_not_found',
        ),
      ),
    );

    final result = await repository.issueDevice(
      deviceId: 'dev-1',
      areaId: 'missing',
      kind: DeviceKind.actuator,
    );

    expect((result as FailureResult<Device>).failure, isA<NotFoundFailure>());
  });

  test('an issue request without status becomes NetworkFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        issueError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.issueDevice(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: DeviceKind.sensor,
    );

    expect((result as FailureResult<Device>).failure, isA<NetworkFailure>());
  });

  test('201 association becomes a device association', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        association: const DeviceAssociationDto(
          id: 'assoc-1',
          areaId: 'area-1',
          deviceId: 'dev-1',
          kind: 'Actuator',
        ),
      ),
    );

    final result = await repository.associateDeviceToArea(
      areaId: 'area-1',
      deviceId: 'dev-1',
      kind: DeviceKind.actuator,
    );

    final association = (result as Success<DeviceAssociation>).value;
    expect(association.id, 'assoc-1');
    expect(association.areaId, 'area-1');
    expect(association.deviceId, 'dev-1');
    expect(association.kind, DeviceKind.actuator);
  });

  test('200 with items becomes a device list', () async {
    final issuedAt = DateTime.utc(2026, 1, 1);
    final expiresAt = DateTime.utc(2026, 2, 1);
    final repository = _repository(
      FakePlantSetupRemote(
        devices: ListDevicesResponseDto(
          items: [
            DeviceDto(
              deviceId: 'dev-1',
              areaId: 'area-1',
              kind: 'Sensor',
              issuedAt: issuedAt,
              expiresAt: expiresAt,
              revokedAt: null,
            ),
          ],
        ),
      ),
    );

    final result = await repository.listDevices();
    final devices = (result as Success<List<Device>>).value;

    expect(devices, hasLength(1));
    expect(devices.single.deviceId, 'dev-1');
    expect(devices.single.areaId, 'area-1');
    expect(devices.single.kind, DeviceKind.sensor);
    expect(devices.single.revokedAt, isNull);
    expect(devices.single.issuedAt, issuedAt);
  });

  test('200 with an empty item list stays empty', () async {
    final repository = _repository(
      FakePlantSetupRemote(devices: const ListDevicesResponseDto(items: [])),
    );

    final result = await repository.listDevices();

    expect((result as Success<List<Device>>).value, isEmpty);
  });

  test('a device list without status becomes NetworkFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        devicesError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.listDevices();

    expect(
      (result as FailureResult<List<Device>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('200 revoke becomes a revocation', () async {
    final revokedAt = DateTime.utc(2026, 3, 1);
    final repository = _repository(
      FakePlantSetupRemote(
        revocation: RevokeDeviceResponseDto(
          deviceId: 'dev-1',
          revokedAt: revokedAt,
        ),
      ),
    );

    final result = await repository.revokeDevice(deviceId: 'dev-1');
    final revocation = (result as Success<DeviceRevocation>).value;

    expect(revocation.deviceId, 'dev-1');
    expect(revocation.revokedAt, revokedAt);
  });

  test('401 revoke becomes UnauthorizedFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        revokeError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
        ),
      ),
    );

    final result = await repository.revokeDevice(deviceId: 'dev-1');

    expect(
      (result as FailureResult<DeviceRevocation>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 role_not_allowed revoke becomes ForbiddenFailure', () async {
    final repository = _repository(
      FakePlantSetupRemote(
        revokeError: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.revokeDevice(deviceId: 'dev-1');

    expect(
      (result as FailureResult<DeviceRevocation>).failure,
      isA<ForbiddenFailure>(),
    );
  });
}

PlantSetupRepositoryImpl _repository(FakePlantSetupRemote remote) {
  return PlantSetupRepositoryImpl(
    remote: remote,
    areaMapper: const IndustrialAreaMapper(),
    setupMapper: const AreaSetupMapper(),
    thresholdsMapper: const AreaThresholdsMapper(),
    deviceMapper: const DeviceMapper(),
    associationMapper: const DeviceAssociationMapper(),
  );
}
