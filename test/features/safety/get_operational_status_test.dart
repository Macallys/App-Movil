import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';

void main() {
  final area = _area();

  test('areas from the repository are returned', () async {
    final repository = _Repository(Success([area]));

    final result = await GetOperationalStatus(repository).call();

    expect((result as Success<List<AreaOperationalStatus>>).value, [area]);
  });

  test('an empty list stays a success', () async {
    final repository = _Repository(const Success([]));

    final result = await GetOperationalStatus(repository).call();

    expect((result as Success<List<AreaOperationalStatus>>).value, isEmpty);
  });

  test('a network failure is propagated', () async {
    final repository = _Repository(const FailureResult(NetworkFailure()));

    final result = await GetOperationalStatus(repository).call();

    expect(
      (result as FailureResult<List<AreaOperationalStatus>>).failure,
      isA<NetworkFailure>(),
    );
  });
}

AreaOperationalStatus _area() {
  return AreaOperationalStatus(
    areaId: 'area-1',
    name: 'Horno',
    co2Ppm: 800,
    noiseDb: 85.5,
    presenceState: PresenceState.detected,
    severity: ExposureSeverity.high,
    alertActive: true,
    highlighted: true,
    actuators: [
      ActuatorState(
        type: ActuatorType.extractor,
        runState: ActuatorRunState.on,
        mode: ActuatorMode.auto,
        lastChangedAt: DateTime.utc(2026, 3, 1),
      ),
    ],
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<List<AreaOperationalStatus>> result;

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() async {
    return result;
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

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
