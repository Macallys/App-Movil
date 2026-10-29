import 'package:dio/dio.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_actions_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_state_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/active_alerts_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/latest_readings_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/operational_status_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/override_actuator_request_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/short_exposure_history_response_dto.dart';

class FakeSafetyRemote extends SafetyRemoteDataSource {
  FakeSafetyRemote({
    this.status,
    this.error,
    this.readings,
    this.readingsError,
    this.alerts,
    this.alertsError,
    this.history,
    this.historyError,
    this.actions,
    this.actionsError,
    this.overrideState,
    this.overrideError,
  }) : super(ApiClient(dio: Dio()));

  final OperationalStatusResponseDto? status;
  final ApiException? error;
  final LatestReadingsDto? readings;
  final ApiException? readingsError;
  final ActiveAlertsResponseDto? alerts;
  final ApiException? alertsError;
  final ShortExposureHistoryResponseDto? history;
  final ApiException? historyError;
  final ActuatorActionsResponseDto? actions;
  final ApiException? actionsError;
  final ActuatorStateDto? overrideState;
  final ApiException? overrideError;
  var overrideCalls = 0;
  String? overrideAreaId;
  OverrideActuatorRequestDto? overrideRequest;

  @override
  Future<OperationalStatusResponseDto> getOperationalStatus() async {
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return status!;
  }

  @override
  Future<LatestReadingsDto> getLatestReadings({required String areaId}) async {
    final failure = readingsError;
    if (failure != null) {
      throw failure;
    }
    return readings!;
  }

  @override
  Future<ActiveAlertsResponseDto> getActiveAlerts() async {
    final failure = alertsError;
    if (failure != null) {
      throw failure;
    }
    return alerts!;
  }

  @override
  Future<ShortExposureHistoryResponseDto> getShortExposureHistory({
    required String areaId,
  }) async {
    final failure = historyError;
    if (failure != null) {
      throw failure;
    }
    return history!;
  }

  @override
  Future<ActuatorActionsResponseDto> getActuatorActions({
    required String areaId,
  }) async {
    final failure = actionsError;
    if (failure != null) {
      throw failure;
    }
    return actions!;
  }

  @override
  Future<ActuatorStateDto> overrideActuator({
    required String areaId,
    required OverrideActuatorRequestDto request,
  }) async {
    overrideCalls += 1;
    overrideAreaId = areaId;
    overrideRequest = request;
    final failure = overrideError;
    if (failure != null) {
      throw failure;
    }
    return overrideState!;
  }
}
