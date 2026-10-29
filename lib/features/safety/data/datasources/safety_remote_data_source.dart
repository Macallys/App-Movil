import '../../../../core/network/api_client.dart';
import '../dtos/active_alerts_response_dto.dart';
import '../dtos/actuator_actions_response_dto.dart';
import '../dtos/actuator_state_dto.dart';
import '../dtos/latest_readings_dto.dart';
import '../dtos/operational_status_response_dto.dart';
import '../dtos/override_actuator_request_dto.dart';
import '../dtos/short_exposure_history_response_dto.dart';

class SafetyRemoteDataSource {
  SafetyRemoteDataSource(this._client);

  final ApiClient _client;

  Future<OperationalStatusResponseDto> getOperationalStatus() {
    // TODO: Pending API/domain contract decision.
    // The operational-status path remains To discuss, so [_client] is not used
    // to perform HTTP.
    return Future<OperationalStatusResponseDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }

  Future<LatestReadingsDto> getLatestReadings({required String areaId}) {
    // TODO: Pending API/domain contract decision.
    // No documented path is closed for latest readings, so [_client] is not
    // used to perform HTTP. [areaId] stays with the caller until that path
    // exists.
    assert(areaId.isNotEmpty);
    return Future<LatestReadingsDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }

  Future<ActiveAlertsResponseDto> getActiveAlerts() {
    // TODO: Pending API/domain contract decision.
    // No documented path is closed for active alerts, so [_client] is not
    // used to perform HTTP. SSE stays out of this client.
    return Future<ActiveAlertsResponseDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }

  Future<ShortExposureHistoryResponseDto> getShortExposureHistory({
    required String areaId,
  }) {
    // TODO: Pending API/domain contract decision.
    // No documented path is closed for short exposure history, so [_client]
    // is not used to perform HTTP. [areaId] stays with the caller until that
    // path exists.
    assert(areaId.isNotEmpty);
    return Future<ShortExposureHistoryResponseDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }

  Future<ActuatorActionsResponseDto> getActuatorActions({
    required String areaId,
  }) {
    // TODO: Pending API/domain contract decision.
    // No documented path is closed for actuator actions, so [_client] is not
    // used to perform HTTP. [areaId] stays with the caller until that path
    // exists. This log is read-only.
    assert(areaId.isNotEmpty);
    return Future<ActuatorActionsResponseDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }

  Future<ActuatorStateDto> overrideActuator({
    required String areaId,
    required OverrideActuatorRequestDto request,
  }) {
    // TODO: Pending API/domain contract decision.
    // docs/api-dtos.md is not in this repository, so the override method and
    // path stay open. [_client] is not used to perform HTTP. [areaId] and
    // [request] stay with the caller. No command is queued.
    assert(areaId.isNotEmpty);
    assert(request.type.isNotEmpty && request.runState.isNotEmpty);
    return Future<ActuatorStateDto>.error(
      UnimplementedError(_pendingContract(_client)),
    );
  }
}

String _pendingContract(ApiClient client) {
  assert(identical(client, client));
  return 'Pending API/domain contract decision.';
}
