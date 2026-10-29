import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('full readings move from initial to loading to data', () async {
    final pending = Completer<Result<LatestReadings>>();
    final container = _container(pending.future);
    final controller = container.read(
      latestReadingsControllerProvider.notifier,
    );

    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsInitial>(),
    );
    final loading = controller.load('area-1');
    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsLoading>(),
    );
    pending.complete(Success(_readings()));
    await loading;

    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsData>(),
    );
  });

  test('partial readings stay data', () async {
    final pending = Completer<Result<LatestReadings>>();
    final container = _container(pending.future);
    final loading = container
        .read(latestReadingsControllerProvider.notifier)
        .load('area-1');
    pending.complete(Success(_readings(noise: false)));
    await loading;

    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsData>(),
    );
  });

  test('all null readings become no telemetry', () async {
    final pending = Completer<Result<LatestReadings>>();
    final container = _container(pending.future);
    final loading = container
        .read(latestReadingsControllerProvider.notifier)
        .load('area-1');
    pending.complete(
      const Success(
        LatestReadings(carbonDioxide: null, noise: null, presence: null),
      ),
    );
    await loading;

    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsNoTelemetry>(),
    );
  });

  test('a network failure becomes network error', () async {
    final pending = Completer<Result<LatestReadings>>();
    final container = _container(pending.future);
    final loading = container
        .read(latestReadingsControllerProvider.notifier)
        .load('area-1');
    pending.complete(const FailureResult(NetworkFailure()));
    await loading;

    expect(
      container.read(latestReadingsControllerProvider),
      isA<LatestReadingsNetworkError>(),
    );
  });
}

ProviderContainer _container(Future<Result<LatestReadings>> result) {
  final container = ProviderContainer(
    overrides: [
      getLatestReadingsUseCaseProvider.overrideWithValue(
        GetLatestReadings(_Repository(result)),
      ),
    ],
  );
  container.listen(latestReadingsControllerProvider, (_, _) {});
  return container;
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
      state: PresenceState.cleared,
      recordedAt: DateTime.utc(2026, 5, 20, 15, 36),
    ),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.pending);

  final Future<Result<LatestReadings>> pending;

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    return pending;
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
