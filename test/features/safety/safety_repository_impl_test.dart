import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_action_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_actions_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_state_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/active_alerts_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/carbon_dioxide_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/environmental_alert_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/exposure_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/latest_readings_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/noise_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/operational_status_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/presence_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/short_exposure_history_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/actuator_action_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/area_operational_status_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/environmental_alert_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/exposure_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/latest_readings_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';

import 'support/fake_safety_remote.dart';

void main() {
  test('200 with items becomes operational areas', () async {
    final repository = _repository(
      FakeSafetyRemote(
        status: OperationalStatusResponseDto.fromJson({
          'items': [
            {
              'areaId': 'area-1',
              'name': 'Horno',
              'co2Ppm': null,
              'noiseDb': 70,
              'presenceState': null,
              'severity': 'None',
              'alertActive': false,
              'highlighted': false,
              'actuators': [
                {
                  'type': 'Extractor',
                  'runState': 'Failed',
                  'mode': 'Auto',
                  'lastChangedAt': '2026-03-01T00:00:00Z',
                },
              ],
            },
          ],
        }),
      ),
    );

    final result = await repository.getOperationalStatus();
    final area = (result as Success<List<AreaOperationalStatus>>).value.single;

    expect(area.co2Ppm, isNull);
    expect(area.noiseDb, 70);
    expect(area.presenceState, isNull);
    expect(area.severity, ExposureSeverity.none);
    expect(area.actuators.single.runState, ActuatorRunState.failed);
  });

  test('200 with an empty item list stays empty', () async {
    final repository = _repository(
      FakeSafetyRemote(status: const OperationalStatusResponseDto(items: [])),
    );

    final result = await repository.getOperationalStatus();

    expect((result as Success<List<AreaOperationalStatus>>).value, isEmpty);
  });

  test('401 becomes UnauthorizedFailure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        error: const ApiException(message: 'Request failed', statusCode: 401),
      ),
    );

    final result = await repository.getOperationalStatus();

    expect(
      (result as FailureResult<List<AreaOperationalStatus>>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 role_not_allowed becomes ForbiddenFailure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        error: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.getOperationalStatus();

    expect(
      (result as FailureResult<List<AreaOperationalStatus>>).failure,
      isA<ForbiddenFailure>(),
    );
  });

  test('a response without status becomes NetworkFailure', () async {
    final repository = _repository(
      FakeSafetyRemote(error: const ApiException(message: 'Network failure')),
    );

    final result = await repository.getOperationalStatus();

    expect(
      (result as FailureResult<List<AreaOperationalStatus>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('the open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {'items': []},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.getOperationalStatus();

    expect(calls, 0);
    expect(
      (result as FailureResult<List<AreaOperationalStatus>>).failure,
      isA<UnknownFailure>(),
    );
  });

  test('200 full maps each reading independently', () async {
    final repository = _repository(FakeSafetyRemote(readings: _readingsDto()));

    final result = await repository.getLatestReadings(areaId: 'area-1');

    final readings = (result as Success<LatestReadings>).value;
    expect(readings.carbonDioxide?.deviceId, 'co2-1');
    expect(readings.carbonDioxide?.ppm, 810);
    expect(readings.noise?.deviceId, 'noise-1');
    expect(readings.noise?.decibels, 85.5);
    expect(readings.presence?.deviceId, 'presence-1');
    expect(readings.presence?.state, PresenceState.detected);
    expect(
      readings.carbonDioxide?.recordedAt,
      isNot(readings.noise?.recordedAt),
    );
  });

  test('200 partial keeps the missing reading null', () async {
    final repository = _repository(
      FakeSafetyRemote(readings: _readingsDto(includeNoise: false)),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    final readings = (result as Success<LatestReadings>).value;
    expect(readings.carbonDioxide, isNotNull);
    expect(readings.noise, isNull);
    expect(readings.presence, isNotNull);
  });

  test('200 empty telemetry is success', () async {
    final repository = _repository(
      FakeSafetyRemote(
        readings: const LatestReadingsDto(
          carbonDioxide: null,
          noise: null,
          presence: null,
        ),
      ),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    final readings = (result as Success<LatestReadings>).value;
    expect(readings.carbonDioxide, isNull);
    expect(readings.noise, isNull);
    expect(readings.presence, isNull);
  });

  test('401 latest readings becomes unauthorized', () async {
    final repository = _repository(
      FakeSafetyRemote(
        readingsError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
          code: 'unauthorized',
        ),
      ),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    expect(
      (result as FailureResult<LatestReadings>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('network latest readings becomes network failure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        readingsError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    expect(
      (result as FailureResult<LatestReadings>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('404 latest readings becomes not found', () async {
    final repository = _repository(
      FakeSafetyRemote(
        readingsError: const ApiException(
          message: 'Missing area',
          statusCode: 404,
          code: 'area_not_found',
        ),
      ),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    expect(
      (result as FailureResult<LatestReadings>).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('latest readings open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.getLatestReadings(areaId: 'area-1');

    expect(calls, 0);
    expect(
      (result as FailureResult<LatestReadings>).failure,
      isA<UnknownFailure>(),
    );
  });

  test('200 items become active alerts', () async {
    final repository = _repository(FakeSafetyRemote(alerts: _alertsDto()));

    final result = await repository.getActiveAlerts();

    final alerts = (result as Success<List<EnvironmentalAlert>>).value;
    expect(alerts, hasLength(1));
    expect(alerts.single.alertId, 'alert-1');
    expect(alerts.single.areaId, 'area-1');
    expect(alerts.single.severity, ExposureSeverity.high);
    expect(alerts.single.recordedAt, DateTime.utc(2026, 5, 20, 15, 35));
  });

  test('200 empty alerts stay an empty success', () async {
    final repository = _repository(
      FakeSafetyRemote(alerts: const ActiveAlertsResponseDto(items: [])),
    );

    final result = await repository.getActiveAlerts();

    expect((result as Success<List<EnvironmentalAlert>>).value, isEmpty);
  });

  test('401 active alerts becomes unauthorized', () async {
    final repository = _repository(
      FakeSafetyRemote(
        alertsError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
        ),
      ),
    );

    final result = await repository.getActiveAlerts();

    expect(
      (result as FailureResult<List<EnvironmentalAlert>>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 active alerts becomes forbidden', () async {
    final repository = _repository(
      FakeSafetyRemote(
        alertsError: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.getActiveAlerts();

    expect(
      (result as FailureResult<List<EnvironmentalAlert>>).failure,
      isA<ForbiddenFailure>(),
    );
  });

  test('network active alerts becomes network failure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        alertsError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.getActiveAlerts();

    expect(
      (result as FailureResult<List<EnvironmentalAlert>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('active alerts open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{'items': []},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.getActiveAlerts();

    expect(calls, 0);
    expect(
      (result as FailureResult<List<EnvironmentalAlert>>).failure,
      isA<UnknownFailure>(),
    );
  });

  test('200 items become exposures', () async {
    final repository = _repository(FakeSafetyRemote(history: _historyDto()));

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    final exposures = (result as Success<List<Exposure>>).value;
    expect(exposures.single.exposureId, 'exposure-1');
    expect(exposures.single.areaId, 'area-1');
    expect(exposures.single.severity, ExposureSeverity.high);
    expect(exposures.single.recordedAt, DateTime.utc(2026, 5, 20, 15, 40));
  });

  test('200 empty exposure history stays an empty success', () async {
    final repository = _repository(
      FakeSafetyRemote(
        history: const ShortExposureHistoryResponseDto(items: []),
      ),
    );

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    expect((result as Success<List<Exposure>>).value, isEmpty);
  });

  test('401 exposure history becomes unauthorized', () async {
    final repository = _repository(
      FakeSafetyRemote(
        historyError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
        ),
      ),
    );

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    expect(
      (result as FailureResult<List<Exposure>>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 exposure history becomes forbidden', () async {
    final repository = _repository(
      FakeSafetyRemote(
        historyError: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    expect(
      (result as FailureResult<List<Exposure>>).failure,
      isA<ForbiddenFailure>(),
    );
  });

  test('network exposure history becomes network failure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        historyError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    expect(
      (result as FailureResult<List<Exposure>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('exposure history open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{'items': []},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.getShortExposureHistory(areaId: 'area-1');

    expect(calls, 0);
    expect(
      (result as FailureResult<List<Exposure>>).failure,
      isA<UnknownFailure>(),
    );
  });

  test('200 with items becomes actuator actions', () async {
    final repository = _repository(FakeSafetyRemote(actions: _actionsDto()));

    final result = await repository.getActuatorActions(areaId: 'area-1');

    final actions = (result as Success<List<ActuatorAction>>).value;
    expect(actions.single.actionId, 'action-1');
    expect(actions.single.type, ActuatorType.extractor);
    expect(actions.single.runState, ActuatorRunState.on);
  });

  test('200 with an empty actuator action list stays empty', () async {
    final repository = _repository(
      FakeSafetyRemote(actions: const ActuatorActionsResponseDto(items: [])),
    );

    final result = await repository.getActuatorActions(areaId: 'area-1');

    expect((result as Success<List<ActuatorAction>>).value, isEmpty);
  });

  test('401 on actuator actions becomes unauthorized', () async {
    final repository = _repository(
      FakeSafetyRemote(
        actionsError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
        ),
      ),
    );

    final result = await repository.getActuatorActions(areaId: 'area-1');

    expect(
      (result as FailureResult<List<ActuatorAction>>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 on actuator actions becomes forbidden', () async {
    final repository = _repository(
      FakeSafetyRemote(
        actionsError: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.getActuatorActions(areaId: 'area-1');

    expect(
      (result as FailureResult<List<ActuatorAction>>).failure,
      isA<ForbiddenFailure>(),
    );
  });

  test('network actuator actions become network failure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        actionsError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.getActuatorActions(areaId: 'area-1');

    expect(
      (result as FailureResult<List<ActuatorAction>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('actuator actions open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{'items': []},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.getActuatorActions(areaId: 'area-1');

    expect(calls, 0);
    expect(
      (result as FailureResult<List<ActuatorAction>>).failure,
      isA<UnknownFailure>(),
    );
  });

  test('successful override returns the actuator from the response', () async {
    final remote = FakeSafetyRemote(
      overrideState: _actuatorDto(mode: 'Overridden', runState: 'Off'),
    );
    final repository = _repository(remote);

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.off,
    );

    final actuator = (result as Success<ActuatorState>).value;
    expect(actuator.type, ActuatorType.extractor);
    expect(actuator.runState, ActuatorRunState.off);
    expect(actuator.mode, ActuatorMode.overridden);
    expect(remote.overrideCalls, 1);
    expect(remote.overrideAreaId, 'area-1');
    expect(remote.overrideRequest?.toJson().keys, ['type', 'runState']);
    expect(remote.overrideRequest?.toJson(), {
      'type': 'Extractor',
      'runState': 'Off',
    });
  });

  test('override keeps Auto when the response says Auto', () async {
    final repository = _repository(
      FakeSafetyRemote(
        overrideState: _actuatorDto(mode: 'Auto', runState: 'On'),
      ),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.siren,
      targetState: ActuatorRunState.on,
    );

    expect((result as Success<ActuatorState>).value.mode, ActuatorMode.auto);
  });

  test('503 edge_unreachable becomes edge unavailable', () async {
    final repository = _repository(
      FakeSafetyRemote(
        overrideError: const ApiException(
          message: 'Request failed',
          statusCode: 503,
          code: 'edge_unreachable',
        ),
      ),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.barrier,
      targetState: ActuatorRunState.deployed,
    );

    expect(
      (result as FailureResult<ActuatorState>).failure,
      isA<EdgeUnavailableFailure>(),
    );
  });

  test('401 on override becomes unauthorized', () async {
    final repository = _repository(
      FakeSafetyRemote(
        overrideError: const ApiException(
          message: 'Request failed',
          statusCode: 401,
        ),
      ),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.on,
    );

    expect(
      (result as FailureResult<ActuatorState>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('403 on override becomes forbidden', () async {
    final repository = _repository(
      FakeSafetyRemote(
        overrideError: const ApiException(
          message: 'Request failed',
          statusCode: 403,
          code: 'role_not_allowed',
        ),
      ),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.on,
    );

    expect(
      (result as FailureResult<ActuatorState>).failure,
      isA<ForbiddenFailure>(),
    );
  });

  test('network override becomes network failure', () async {
    final repository = _repository(
      FakeSafetyRemote(
        overrideError: const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.off,
    );

    final failure = (result as FailureResult<ActuatorState>).failure;
    expect(failure, isA<NetworkFailure>());
    expect(failure, isNot(isA<EdgeUnavailableFailure>()));
  });

  test('override open path does not perform HTTP', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{},
            ),
          );
        },
      ),
    );
    final repository = SafetyRepositoryImpl(
      remote: SafetyRemoteDataSource(ApiClient(dio: dio)),
      statusMapper: const AreaOperationalStatusMapper(),
      readingsMapper: const LatestReadingsMapper(),
      alertMapper: const EnvironmentalAlertMapper(),
      exposureMapper: const ExposureMapper(),
      actionMapper: const ActuatorActionMapper(),
    );

    final result = await repository.overrideActuator(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.off,
    );

    expect(calls, 0);
    expect(
      (result as FailureResult<ActuatorState>).failure,
      isA<UnknownFailure>(),
    );
  });
}

SafetyRepositoryImpl _repository(FakeSafetyRemote remote) {
  return SafetyRepositoryImpl(
    remote: remote,
    statusMapper: const AreaOperationalStatusMapper(),
    readingsMapper: const LatestReadingsMapper(),
    alertMapper: const EnvironmentalAlertMapper(),
    exposureMapper: const ExposureMapper(),
    actionMapper: const ActuatorActionMapper(),
  );
}

LatestReadingsDto _readingsDto({bool includeNoise = true}) {
  return LatestReadingsDto(
    carbonDioxide: CarbonDioxideReadingDto(
      deviceId: 'co2-1',
      ppm: 810,
      recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
    ),
    noise: includeNoise
        ? NoiseReadingDto(
            deviceId: 'noise-1',
            decibels: 85.5,
            recordedAt: DateTime.utc(2026, 5, 20, 15, 33),
          )
        : null,
    presence: PresenceReadingDto(
      deviceId: 'presence-1',
      state: 'Detected',
      recordedAt: DateTime.utc(2026, 5, 20, 15, 36),
    ),
  );
}

ActiveAlertsResponseDto _alertsDto() {
  return ActiveAlertsResponseDto(
    items: [
      EnvironmentalAlertDto(
        alertId: 'alert-1',
        areaId: 'area-1',
        severity: 'High',
        recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
      ),
    ],
  );
}

ActuatorActionsResponseDto _actionsDto() {
  return ActuatorActionsResponseDto(
    items: [
      ActuatorActionDto(
        actionId: 'action-1',
        areaId: 'area-1',
        type: 'Extractor',
        runState: 'On',
        executedAt: DateTime.utc(2026, 5, 20, 15, 45),
      ),
    ],
  );
}

ActuatorStateDto _actuatorDto({
  required String mode,
  required String runState,
}) {
  return ActuatorStateDto(
    type: 'Extractor',
    runState: runState,
    mode: mode,
    lastChangedAt: DateTime.utc(2026, 5, 20, 16),
  );
}

ShortExposureHistoryResponseDto _historyDto() {
  return ShortExposureHistoryResponseDto(
    items: [
      ExposureDto(
        exposureId: 'exposure-1',
        areaId: 'area-1',
        severity: 'High',
        recordedAt: DateTime.utc(2026, 5, 20, 15, 40),
      ),
    ],
  );
}
