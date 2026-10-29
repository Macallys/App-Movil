import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('load moves from initial to loading to data', () async {
    final pending = Completer<Result<List<Exposure>>>();
    final container = _container(_Queue([pending.future]));
    final controller = container.read(
      exposureHistoryControllerProvider.notifier,
    );

    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryInitial>(),
    );
    final loading = controller.load('area-1');
    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryLoading>(),
    );
    pending.complete(Success([_exposure('exposure-1')]));
    await loading;

    final state = container.read(
      exposureHistoryControllerProvider,
    ) as ExposureHistoryData;
    expect(state.exposures.single.exposureId, 'exposure-1');
  });

  test('an empty list becomes empty', () async {
    final pending = Completer<Result<List<Exposure>>>();
    final container = _container(_Queue([pending.future]));
    final loading = container
        .read(exposureHistoryControllerProvider.notifier)
        .load('area-1');
    pending.complete(const Success([]));
    await loading;

    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryEmpty>(),
    );
  });

  test('a network failure becomes network error', () async {
    final pending = Completer<Result<List<Exposure>>>();
    final container = _container(_Queue([pending.future]));
    final loading = container
        .read(exposureHistoryControllerProvider.notifier)
        .load('area-1');
    pending.complete(const FailureResult(NetworkFailure()));
    await loading;

    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryNetworkError>(),
    );
  });

  test('retry moves from network error back to data', () async {
    final first = Completer<Result<List<Exposure>>>();
    final second = Completer<Result<List<Exposure>>>();
    final container = _container(_Queue([first.future, second.future]));
    final controller = container.read(
      exposureHistoryControllerProvider.notifier,
    );
    final failed = controller.load('area-1');
    first.complete(const FailureResult(NetworkFailure()));
    await failed;
    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryNetworkError>(),
    );

    final retried = controller.load('area-1');
    expect(
      container.read(exposureHistoryControllerProvider),
      isA<ExposureHistoryLoading>(),
    );
    second.complete(Success([_exposure('exposure-2')]));
    await retried;

    final state = container.read(
      exposureHistoryControllerProvider,
    ) as ExposureHistoryData;
    expect(state.exposures.single.exposureId, 'exposure-2');
  });
}

ProviderContainer _container(SafetyRepository repository) {
  final container = ProviderContainer(
    overrides: [
      getShortExposureHistoryUseCaseProvider.overrideWithValue(
        GetShortExposureHistory(repository),
      ),
    ],
  );
  container.listen(exposureHistoryControllerProvider, (_, _) {});
  return container;
}

Exposure _exposure(String exposureId) {
  return Exposure(
    exposureId: exposureId,
    areaId: 'area-1',
    severity: ExposureSeverity.high,
    recordedAt: DateTime.utc(2026, 5, 20, 15, 40),
  );
}

class _Queue implements SafetyRepository {
  _Queue(this.pending);

  final List<Future<Result<List<Exposure>>>> pending;
  var calls = 0;

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) {
    final result = pending[calls];
    calls += 1;
    return result;
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
