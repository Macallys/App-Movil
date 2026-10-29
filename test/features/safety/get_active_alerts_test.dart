import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_active_alerts.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('returns alerts from the repository', () async {
    final alerts = [_alert()];
    final useCase = GetActiveAlerts(_Repository(Success(alerts)));

    final result = await useCase.call();

    expect((result as Success<List<EnvironmentalAlert>>).value, alerts);
  });

  test('returns an empty list as success', () async {
    final useCase = GetActiveAlerts(
      _Repository(const Success(<EnvironmentalAlert>[])),
    );

    final result = await useCase.call();

    expect((result as Success<List<EnvironmentalAlert>>).value, isEmpty);
  });

  test('propagates a network failure', () async {
    final useCase = GetActiveAlerts(
      _Repository(const FailureResult(NetworkFailure())),
    );

    final result = await useCase.call();

    expect(
      (result as FailureResult<List<EnvironmentalAlert>>).failure,
      isA<NetworkFailure>(),
    );
  });
}

EnvironmentalAlert _alert() {
  return EnvironmentalAlert(
    alertId: 'alert-1',
    areaId: 'area-1',
    severity: ExposureSeverity.high,
    recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<List<EnvironmentalAlert>> result;

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
    return Future.value(result);
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

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
