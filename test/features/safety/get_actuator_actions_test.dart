import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_actuator_actions.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';

void main() {
  test('returns actions from the repository', () async {
    final actions = [_action()];
    final useCase = GetActuatorActions(_Repository(Success(actions)));

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<List<ActuatorAction>>).value, actions);
  });

  test('returns an empty list as success', () async {
    final useCase = GetActuatorActions(
      _Repository(const Success(<ActuatorAction>[])),
    );

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<List<ActuatorAction>>).value, isEmpty);
  });

  test('propagates a network failure', () async {
    final useCase = GetActuatorActions(
      _Repository(const FailureResult(NetworkFailure())),
    );

    final result = await useCase.call(areaId: 'area-1');

    expect(
      (result as FailureResult<List<ActuatorAction>>).failure,
      isA<NetworkFailure>(),
    );
  });
}

ActuatorAction _action() {
  return ActuatorAction(
    actionId: 'action-1',
    areaId: 'area-1',
    type: ActuatorType.extractor,
    runState: ActuatorRunState.on,
    executedAt: DateTime.utc(2026, 5, 20, 15, 45),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<List<ActuatorAction>> result;

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    return Future.value(result);
  }

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
