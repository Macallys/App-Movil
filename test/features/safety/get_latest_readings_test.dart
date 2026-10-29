import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('returns every reading from the repository', () async {
    final readings = _readings();
    final useCase = GetLatestReadings(_Repository(Success(readings)));

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<LatestReadings>).value, readings);
  });

  test('returns a partial reading as success', () async {
    final readings = _readings(noise: false);
    final useCase = GetLatestReadings(_Repository(Success(readings)));

    final result = await useCase.call(areaId: 'area-1');

    final value = (result as Success<LatestReadings>).value;
    expect(value.carbonDioxide, isNotNull);
    expect(value.noise, isNull);
    expect(value.presence, isNotNull);
  });

  test('returns all null readings as success', () async {
    const readings = LatestReadings(
      carbonDioxide: null,
      noise: null,
      presence: null,
    );
    final useCase = GetLatestReadings(_Repository(const Success(readings)));

    final result = await useCase.call(areaId: 'area-1');

    expect((result as Success<LatestReadings>).value.hasTelemetry, isFalse);
  });

  test('returns a network failure', () async {
    final useCase = GetLatestReadings(
      _Repository(const FailureResult(NetworkFailure())),
    );

    final result = await useCase.call(areaId: 'area-1');

    expect(
      (result as FailureResult<LatestReadings>).failure,
      isA<NetworkFailure>(),
    );
  });
}

LatestReadings _readings({bool noise = true}) {
  return LatestReadings(
    carbonDioxide: CarbonDioxideReading(
      deviceId: 'co2-1',
      ppm: 810,
      recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
    ),
    noise: noise
        ? NoiseReading(
            deviceId: 'noise-1',
            decibels: 85.5,
            recordedAt: DateTime.utc(2026, 5, 20, 15, 33),
          )
        : null,
    presence: PresenceReading(
      deviceId: 'presence-1',
      state: PresenceState.detected,
      recordedAt: DateTime.utc(2026, 5, 20, 15, 36),
    ),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.readings);

  final Result<LatestReadings> readings;

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    return Future.value(readings);
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
