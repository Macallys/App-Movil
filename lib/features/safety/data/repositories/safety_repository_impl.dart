import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/actuator_action.dart';
import '../../domain/entities/actuator_state.dart';
import '../../domain/entities/area_operational_status.dart';
import '../../domain/entities/environmental_alert.dart';
import '../../domain/entities/exposure.dart';
import '../../domain/entities/latest_readings.dart';
import '../../domain/repositories/safety_repository.dart';
import '../datasources/safety_remote_data_source.dart';
import '../dtos/override_actuator_request_dto.dart';
import '../mappers/actuator_action_mapper.dart';
import '../mappers/actuator_state_mapper.dart';
import '../mappers/area_operational_status_mapper.dart';
import '../mappers/environmental_alert_mapper.dart';
import '../mappers/exposure_mapper.dart';
import '../mappers/latest_readings_mapper.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  SafetyRepositoryImpl({
    required this.remote,
    required this.statusMapper,
    required this.readingsMapper,
    required this.alertMapper,
    required this.exposureMapper,
    required this.actionMapper,
  });

  final SafetyRemoteDataSource remote;
  final AreaOperationalStatusMapper statusMapper;
  final LatestReadingsMapper readingsMapper;
  final EnvironmentalAlertMapper alertMapper;
  final ExposureMapper exposureMapper;
  final ActuatorActionMapper actionMapper;

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() async {
    try {
      final dto = await remote.getOperationalStatus();
      return Success([
        for (final item in dto.items) statusMapper.toEntity(item),
      ]);
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({
    required String areaId,
  }) async {
    try {
      final dto = await remote.getLatestReadings(areaId: areaId);
      return Success(readingsMapper.toEntity(dto));
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return const FailureResult(NotFoundFailure());
      }
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() async {
    try {
      final dto = await remote.getActiveAlerts();
      return Success([
        for (final item in dto.items) alertMapper.toEntity(item),
      ]);
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) async {
    try {
      final dto = await remote.getShortExposureHistory(areaId: areaId);
      return Success([
        for (final item in dto.items) exposureMapper.toEntity(item),
      ]);
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) async {
    try {
      final dto = await remote.getActuatorActions(areaId: areaId);
      return Success([
        for (final item in dto.items) actionMapper.toEntity(item),
      ]);
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) async {
    try {
      final dto = await remote.overrideActuator(
        areaId: areaId,
        request: OverrideActuatorRequestDto(
          type: actuatorTypeToWire(type),
          runState: actuatorRunStateToWire(targetState),
        ),
      );
      return Success(const ActuatorStateMapper().toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_mapOverride(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    } on UnimplementedError {
      return const FailureResult(UnknownFailure());
    }
  }

  Failure _mapOverride(ApiException error) {
    if (error.statusCode == null) {
      return const NetworkFailure();
    }
    if (error.statusCode == 401) {
      return const UnauthorizedFailure();
    }
    if (error.statusCode == 403 && error.code == 'role_not_allowed') {
      return const ForbiddenFailure();
    }
    if (error.statusCode == 503 && error.code == 'edge_unreachable') {
      return const EdgeUnavailableFailure();
    }
    return const UnknownFailure();
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
    return const UnknownFailure();
  }
}
