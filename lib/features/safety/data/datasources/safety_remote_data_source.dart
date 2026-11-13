import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/active_alerts_response_dto.dart';
import '../dtos/actuator_actions_response_dto.dart';
import '../dtos/area_operational_status_dto.dart';
import '../dtos/latest_readings_dto.dart';
import '../dtos/operational_status_response_dto.dart';
import '../dtos/override_actuator_request_dto.dart';
import '../dtos/short_exposure_history_response_dto.dart';

class SafetyRemoteDataSource {
  SafetyRemoteDataSource(this._client);

  final ApiClient _client;

  Future<OperationalStatusResponseDto> getOperationalStatus() async {
    final response = await _client.getJson('/api/v1/areas/operational-status');
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return OperationalStatusResponseDto.fromJson(response.body);
  }

  Future<AreaOperationalStatusDto> getAreaOperationalStatus({
    required String areaId,
  }) async {
    final response = await _client.getJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/operational-status',
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return AreaOperationalStatusDto.fromJson(response.body);
  }

  Future<LatestReadingsDto> getLatestReadings({required String areaId}) async {
    final response = await _client.getJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/telemetry/latest',
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return LatestReadingsDto.fromJson(response.body);
  }

  Future<ActiveAlertsResponseDto> getActiveAlerts() async {
    final response = await _client.getJson('/api/v1/alerts/active');
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return ActiveAlertsResponseDto.fromJson(response.body);
  }

  Future<ShortExposureHistoryResponseDto> getShortExposureHistory({
    required String areaId,
  }) async {
    final response = await _client.getJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/exposures',
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return ShortExposureHistoryResponseDto.fromJson(response.body);
  }

  Future<ActuatorActionsResponseDto> getActuatorActions({
    required String areaId,
  }) async {
    final response = await _client.getJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/actuator-actions',
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return ActuatorActionsResponseDto.fromJson(response.body);
  }

  Future<void> overrideActuator({
    required String areaId,
    required OverrideActuatorRequestDto request,
  }) async {
    final status = await _client.postStatus(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/actuators/override',
      body: request.toJson(),
    );
    if (status != 204) {
      throw ApiException(message: 'Unexpected response', statusCode: status);
    }
  }
}
