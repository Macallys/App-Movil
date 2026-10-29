import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/entities/area_thresholds.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_association.dart';
import '../../domain/entities/device_revocation.dart';
import '../../domain/entities/industrial_area.dart';
import '../../domain/repositories/plant_setup_repository.dart';
import '../datasources/plant_setup_remote_data_source.dart';
import '../mappers/area_setup_mapper.dart';
import '../mappers/area_thresholds_mapper.dart';
import '../mappers/device_association_mapper.dart';
import '../mappers/device_mapper.dart';
import '../mappers/industrial_area_mapper.dart';

class PlantSetupRepositoryImpl implements PlantSetupRepository {
  PlantSetupRepositoryImpl({
    required this.remote,
    required this.areaMapper,
    required this.setupMapper,
    required this.thresholdsMapper,
    required this.deviceMapper,
    required this.associationMapper,
  });

  final PlantSetupRemoteDataSource remote;
  final IndustrialAreaMapper areaMapper;
  final AreaSetupMapper setupMapper;
  final AreaThresholdsMapper thresholdsMapper;
  final DeviceMapper deviceMapper;
  final DeviceAssociationMapper associationMapper;

  @override
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  }) async {
    try {
      final dto = await remote.createArea(name: name, location: location);
      return Success(areaMapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<AreaSetup>> getAreaSetup({required String areaId}) async {
    try {
      final dto = await remote.getAreaSetup(areaId: areaId);
      return Success(setupMapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    try {
      final dto = await remote.configureEnvironmentalThresholds(
        areaId: areaId,
        co2LimitPpm: co2LimitPpm,
        noiseLimitDb: noiseLimitDb,
      );
      return Success(thresholdsMapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) async {
    try {
      final dto = await remote.issueDevice(
        deviceId: deviceId,
        areaId: areaId,
        kind: kind,
      );
      return Success(deviceMapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) async {
    try {
      final dto = await remote.associateDeviceToArea(
        areaId: areaId,
        deviceId: deviceId,
        kind: kind,
      );
      return Success(associationMapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<List<Device>>> listDevices() async {
    try {
      final dto = await remote.listDevices();
      return Success([
        for (final item in dto.items) deviceMapper.fromInventory(item),
      ]);
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({
    required String deviceId,
  }) async {
    try {
      final dto = await remote.revokeDevice(deviceId: deviceId);
      return Success(deviceMapper.toRevocation(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  Failure _map(ApiException error) {
    if (error.statusCode == null) {
      return const NetworkFailure();
    }
    if (error.statusCode == 401) {
      return const UnauthorizedFailure();
    }
    if (error.statusCode == 403 && error.code == 'role_not_allowed') {
      return const ForbiddenFailure();
    }
    if (error.statusCode == 404 || error.code == 'area_not_found') {
      return const NotFoundFailure();
    }
    if (error.statusCode == 422) {
      return const ValidationFailure();
    }
    if (error.statusCode == 409 &&
        (error.code == 'area_name_duplicate' ||
            error.code == 'device_already_exists')) {
      return const ConflictFailure();
    }
    return const UnknownFailure();
  }
}
