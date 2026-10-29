import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:safeplant_mobile/features/safety/presentation/active_alerts_polling.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  test('initial load moves from initial to loading to data', () async {
    final pending = Completer<Result<List<EnvironmentalAlert>>>();
    final container = _container(_Pending(pending.future));
    final controller = container.read(activeAlertsControllerProvider.notifier);

    expect(
      container.read(activeAlertsControllerProvider),
      isA<ActiveAlertsInitial>(),
    );
    final loading = controller.load();
    expect(
      container.read(activeAlertsControllerProvider),
      isA<ActiveAlertsLoading>(),
    );
    pending.complete(Success([_alert('alert-1')]));
    await loading;

    final state = container.read(activeAlertsControllerProvider);
    expect(state, isA<ActiveAlertsData>());
    expect((state as ActiveAlertsData).alerts.single.alertId, 'alert-1');
  });

  test('an empty list becomes empty', () async {
    final pending = Completer<Result<List<EnvironmentalAlert>>>();
    final container = _container(_Pending(pending.future));
    final loading = container
        .read(activeAlertsControllerProvider.notifier)
        .load();
    pending.complete(const Success([]));
    await loading;

    expect(
      container.read(activeAlertsControllerProvider),
      isA<ActiveAlertsEmpty>(),
    );
  });

  test('a network failure becomes network error', () async {
    final pending = Completer<Result<List<EnvironmentalAlert>>>();
    final container = _container(_Pending(pending.future));
    final loading = container
        .read(activeAlertsControllerProvider.notifier)
        .load();
    pending.complete(const FailureResult(NetworkFailure()));
    await loading;

    expect(
      container.read(activeAlertsControllerProvider),
      isA<ActiveAlertsNetworkError>(),
    );
  });

  test('startPolling refreshes on each interval', () {
    fakeAsync((async) {
      final repository = _Sequence([
        Success([_alert('alert-1')]),
        Success([_alert('alert-2')]),
      ]);
      final container = _container(repository);
      final controller = container.read(
        activeAlertsControllerProvider.notifier,
      );
      controller.load();
      async.flushMicrotasks();
      controller.startPolling();

      async.elapse(activeAlertsPollingInterval);
      async.flushMicrotasks();

      final state =
          container.read(activeAlertsControllerProvider) as ActiveAlertsData;
      expect(repository.calls, 2);
      expect(state.alerts.single.alertId, 'alert-2');
      container.dispose();
    });
  });

  test('startPolling twice keeps a single cycle', () {
    fakeAsync((async) {
      final repository = _Sequence([
        const Success([]),
        const Success([]),
        const Success([]),
      ]);
      final container = _container(repository);
      final controller = container.read(
        activeAlertsControllerProvider.notifier,
      );
      controller.load();
      async.flushMicrotasks();
      controller.startPolling();
      controller.startPolling();

      async.elapse(activeAlertsPollingInterval);
      async.flushMicrotasks();

      expect(repository.calls, 2);
      container.dispose();
    });
  });

  test('dispose stops polling', () {
    fakeAsync((async) {
      final repository = _Sequence(const [Success([])]);
      final container = _container(repository);
      container.read(activeAlertsControllerProvider.notifier).startPolling();

      container.dispose();
      async.elapse(activeAlertsPollingInterval * 3);

      expect(repository.calls, 0);
    });
  });

  test('a tick does not overlap an active request', () {
    fakeAsync((async) {
      final gate = Completer<Result<List<EnvironmentalAlert>>>();
      final repository = _Gate(gate.future);
      final container = _container(repository);
      final controller = container.read(
        activeAlertsControllerProvider.notifier,
      );
      controller.load();
      controller.startPolling();

      async.elapse(activeAlertsPollingInterval);

      expect(repository.calls, 1);
      gate.complete(Success([_alert('alert-1')]));
      async.flushMicrotasks();
      container.dispose();
    });
  });

  test('a polling failure keeps the previous data', () {
    fakeAsync((async) {
      final repository = _Sequence([
        Success([_alert('alert-1')]),
        const FailureResult(NetworkFailure()),
      ]);
      final container = _container(repository);
      final controller = container.read(
        activeAlertsControllerProvider.notifier,
      );
      controller.load();
      async.flushMicrotasks();
      controller.startPolling();

      async.elapse(activeAlertsPollingInterval);
      async.flushMicrotasks();

      final state =
          container.read(activeAlertsControllerProvider) as ActiveAlertsData;
      expect(state.alerts.single.alertId, 'alert-1');
      expect(state.refreshError, isTrue);
      container.dispose();
    });
  });

  test('the next successful poll replaces the preserved data', () {
    fakeAsync((async) {
      final repository = _Sequence([
        Success([_alert('alert-1')]),
        const FailureResult(NetworkFailure()),
        Success([_alert('alert-2')]),
      ]);
      final container = _container(repository);
      final controller = container.read(
        activeAlertsControllerProvider.notifier,
      );
      controller.load();
      async.flushMicrotasks();
      controller.startPolling();
      async.elapse(activeAlertsPollingInterval);
      async.flushMicrotasks();

      async.elapse(activeAlertsPollingInterval);
      async.flushMicrotasks();

      final state =
          container.read(activeAlertsControllerProvider) as ActiveAlertsData;
      expect(state.alerts.single.alertId, 'alert-2');
      expect(state.refreshError, isFalse);
      container.dispose();
    });
  });
}

ProviderContainer _container(SafetyRepository repository) {
  final container = ProviderContainer(
    overrides: [
      getActiveAlertsUseCaseProvider.overrideWithValue(
        GetActiveAlerts(repository),
      ),
    ],
  );
  container.listen(activeAlertsControllerProvider, (_, _) {});
  return container;
}

EnvironmentalAlert _alert(String alertId) {
  return EnvironmentalAlert(
    alertId: alertId,
    areaId: 'area-1',
    severity: ExposureSeverity.medium,
    recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
  );
}

class _Pending implements SafetyRepository {
  _Pending(this.pending);

  final Future<Result<List<EnvironmentalAlert>>> pending;

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() => pending;

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
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
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

class _Gate implements SafetyRepository {
  _Gate(this.first);

  final Future<Result<List<EnvironmentalAlert>>> first;
  var calls = 0;

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() {
    calls += 1;
    if (calls == 1) {
      return first;
    }
    return Future.value(const Success([]));
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
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
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

class _Sequence implements SafetyRepository {
  _Sequence(this.results);

  final List<Result<List<EnvironmentalAlert>>> results;
  var calls = 0;

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() {
    final result = results[calls];
    calls += 1;
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
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
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
