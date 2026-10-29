import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('load moves from loading to data', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <SafetyDashboardState>[];
    container.listen(safetyDashboardControllerProvider, (_, next) {
      seen.add(next);
    });

    final pending = container
        .read(safetyDashboardControllerProvider.notifier)
        .load();
    expect(
      container.read(safetyDashboardControllerProvider),
      isA<SafetyDashboardLoading>(),
    );
    repository.pending.complete(Success([_area()]));
    await pending;

    expect(seen.first, isA<SafetyDashboardLoading>());
    final data = container.read(
      safetyDashboardControllerProvider,
    ) as SafetyDashboardData;
    expect(data.areas.single.name, 'Horno');
  });

  test('an empty list becomes empty', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);

    final pending = container
        .read(safetyDashboardControllerProvider.notifier)
        .load();
    repository.pending.complete(const Success([]));
    await pending;

    expect(
      container.read(safetyDashboardControllerProvider),
      isA<SafetyDashboardEmpty>(),
    );
  });

  test('network failure can be retried into data', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final seen = <SafetyDashboardState>[];
    container.listen(safetyDashboardControllerProvider, (_, next) {
      seen.add(next);
    });

    final first = container
        .read(safetyDashboardControllerProvider.notifier)
        .load();
    repository.pending.complete(const FailureResult(NetworkFailure()));
    await first;
    expect(
      container.read(safetyDashboardControllerProvider),
      isA<SafetyDashboardNetworkError>(),
    );

    repository.pending = Completer<Result<List<AreaOperationalStatus>>>();
    final retry = container
        .read(safetyDashboardControllerProvider.notifier)
        .load();
    expect(
      container.read(safetyDashboardControllerProvider),
      isA<SafetyDashboardLoading>(),
    );
    repository.pending.complete(Success([_area()]));
    await retry;

    expect(seen, contains(isA<SafetyDashboardLoading>()));
    expect(
      container.read(safetyDashboardControllerProvider),
      isA<SafetyDashboardData>(),
    );
  });
}

ProviderContainer _container(_Repository repository) {
  return ProviderContainer(
    overrides: [safetyRepositoryProvider.overrideWithValue(repository)],
  );
}

AreaOperationalStatus _area() {
  return const AreaOperationalStatus(
    areaId: 'area-1',
    name: 'Horno',
    co2Ppm: null,
    noiseDb: null,
    presenceState: null,
    severity: ExposureSeverity.none,
    alertActive: false,
    highlighted: false,
    actuators: [],
  );
}

class _Repository implements SafetyRepository {
  Completer<Result<List<AreaOperationalStatus>>> pending =
      Completer<Result<List<AreaOperationalStatus>>>();

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    return pending.future;
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
