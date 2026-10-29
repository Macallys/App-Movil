import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/override_actuator.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';

void main() {
  test('accepts extractor and siren on or off', () async {
    final repository = _Repository(Success(_state(ActuatorRunState.on)));
    final useCase = OverrideActuator(repository);

    for (final type in [ActuatorType.extractor, ActuatorType.siren]) {
      for (final target in [ActuatorRunState.on, ActuatorRunState.off]) {
        final result = await useCase.call(
          areaId: 'area-1',
          type: type,
          targetState: target,
        );
        expect(result, isA<Success<ActuatorState>>());
      }
    }
    expect(repository.calls, 4);
  });

  test('accepts barrier deployed or retracted', () async {
    final repository = _Repository(Success(_state(ActuatorRunState.deployed)));
    final useCase = OverrideActuator(repository);

    for (final target in [
      ActuatorRunState.deployed,
      ActuatorRunState.retracted,
    ]) {
      final result = await useCase.call(
        areaId: 'area-1',
        type: ActuatorType.barrier,
        targetState: target,
      );
      expect(result, isA<Success<ActuatorState>>());
    }
    expect(repository.calls, 2);
  });

  test('rejects invalid type and target combinations', () async {
    final repository = _Repository(Success(_state(ActuatorRunState.on)));
    final useCase = OverrideActuator(repository);
    const rejected = [
      (ActuatorType.barrier, ActuatorRunState.on),
      (ActuatorType.extractor, ActuatorRunState.deployed),
      (ActuatorType.siren, ActuatorRunState.retracted),
      (ActuatorType.extractor, ActuatorRunState.failed),
      (ActuatorType.siren, ActuatorRunState.failed),
      (ActuatorType.barrier, ActuatorRunState.failed),
    ];

    for (final (type, target) in rejected) {
      final result = await useCase.call(
        areaId: 'area-1',
        type: type,
        targetState: target,
      );
      expect(
        (result as FailureResult<ActuatorState>).failure,
        isA<ValidationFailure>(),
      );
    }
    expect(repository.calls, 0);
  });
}

ActuatorState _state(ActuatorRunState runState) {
  return ActuatorState(
    type: ActuatorType.extractor,
    runState: runState,
    mode: ActuatorMode.overridden,
    lastChangedAt: DateTime.utc(2026, 5, 20, 16),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<ActuatorState> result;
  var calls = 0;

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    calls += 1;
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
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    throw UnimplementedError();
  }
}
