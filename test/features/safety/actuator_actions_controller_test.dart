import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';

void main() {
  test('load moves from initial to loading to data', () async {
    final pending = Completer<Result<List<ActuatorAction>>>();
    final container = _container(_Queue([pending.future]));
    final controller = container.read(
      actuatorActionsControllerProvider.notifier,
    );

    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsInitial>(),
    );
    final loading = controller.load('area-1');
    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsLoading>(),
    );
    pending.complete(Success([_action('action-1')]));
    await loading;

    final state = container.read(
      actuatorActionsControllerProvider,
    ) as ActuatorActionsData;
    expect(state.actions.single.actionId, 'action-1');
  });

  test('an empty list becomes empty', () async {
    final pending = Completer<Result<List<ActuatorAction>>>();
    final container = _container(_Queue([pending.future]));
    final loading = container
        .read(actuatorActionsControllerProvider.notifier)
        .load('area-1');
    pending.complete(const Success([]));
    await loading;

    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsEmpty>(),
    );
  });

  test('a network failure becomes network error', () async {
    final pending = Completer<Result<List<ActuatorAction>>>();
    final container = _container(_Queue([pending.future]));
    final loading = container
        .read(actuatorActionsControllerProvider.notifier)
        .load('area-1');
    pending.complete(const FailureResult(NetworkFailure()));
    await loading;

    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsNetworkError>(),
    );
  });

  test('retry moves from network error back to data', () async {
    final first = Completer<Result<List<ActuatorAction>>>();
    final second = Completer<Result<List<ActuatorAction>>>();
    final container = _container(_Queue([first.future, second.future]));
    final controller = container.read(
      actuatorActionsControllerProvider.notifier,
    );
    final failed = controller.load('area-1');
    first.complete(const FailureResult(NetworkFailure()));
    await failed;
    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsNetworkError>(),
    );

    final retried = controller.load('area-1');
    expect(
      container.read(actuatorActionsControllerProvider),
      isA<ActuatorActionsLoading>(),
    );
    second.complete(Success([_action('action-2')]));
    await retried;

    final state = container.read(
      actuatorActionsControllerProvider,
    ) as ActuatorActionsData;
    expect(state.actions.single.actionId, 'action-2');
  });
}

ProviderContainer _container(SafetyRepository repository) {
  final container = ProviderContainer(
    overrides: [
      getActuatorActionsUseCaseProvider.overrideWithValue(
        GetActuatorActions(repository),
      ),
    ],
  );
  container.listen(actuatorActionsControllerProvider, (_, _) {});
  return container;
}

ActuatorAction _action(String actionId) {
  return ActuatorAction(
    actionId: actionId,
    areaId: 'area-1',
    type: ActuatorType.siren,
    runState: ActuatorRunState.on,
    executedAt: DateTime.utc(2026, 5, 20, 15, 45),
  );
}

class _Queue implements SafetyRepository {
  _Queue(this.pending);

  final List<Future<Result<List<ActuatorAction>>>> pending;
  var calls = 0;

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    final result = pending[calls];
    calls += 1;
    return result;
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
