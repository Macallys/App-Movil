import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_short_exposure_history.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('returns exposures from the repository', () async {
    final exposures = [_exposure()];
    final useCase = GetShortExposureHistory(_Repository(Success(exposures)));

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<List<Exposure>>).value, exposures);
  });

  test('returns an empty list as success', () async {
    final useCase = GetShortExposureHistory(
      _Repository(const Success(<Exposure>[])),
    );

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<List<Exposure>>).value, isEmpty);
  });

  test('propagates a network failure', () async {
    final useCase = GetShortExposureHistory(
      _Repository(const FailureResult(NetworkFailure())),
    );

    final result = await useCase.call(areaId: 'area-1');

    expect(
      (result as FailureResult<List<Exposure>>).failure,
      isA<NetworkFailure>(),
    );
  });
}

Exposure _exposure() {
  return Exposure(
    exposureId: 'exposure-1',
    areaId: 'area-1',
    severity: ExposureSeverity.medium,
    recordedAt: DateTime.utc(2026, 5, 20, 15, 40),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<List<Exposure>> result;

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) {
    return Future.value(result);
  }

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    throw UnimplementedError();
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
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
