import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';

void main() {
  test('submit moves from initial to submitting to success', () async {
    final pending = Completer<Result<ActuatorState>>();
    final repository = _Repository([pending.future]);
    final container = _container(repository);
    final controller = container.read(
      actuatorOverrideControllerProvider.notifier,
    );

    expect(
      container.read(actuatorOverrideControllerProvider),
      isA<ActuatorOverrideInitial>(),
    );
    final submitting = controller.submit(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.off,
    );
    expect(
      container.read(actuatorOverrideControllerProvider),
      isA<ActuatorOverrideSubmitting>(),
    );
    pending.complete(Success(_state(ActuatorRunState.off)));
    await submitting;

    final state = container.read(
      actuatorOverrideControllerProvider,
    ) as ActuatorOverrideSuccess;
    expect(state.actuator.runState, ActuatorRunState.off);
    expect(state.actuator.mode, ActuatorMode.overridden);
  });

  test('edge failure becomes edge unavailable', () async {
    final container = _container(
      _Repository([
        Future.value(const FailureResult(EdgeUnavailableFailure())),
      ]),
    );
    await container
        .read(actuatorOverrideControllerProvider.notifier)
        .submit(
          areaId: 'area-1',
          type: ActuatorType.extractor,
          targetState: ActuatorRunState.off,
        );

    expect(
      container.read(actuatorOverrideControllerProvider),
      isA<ActuatorOverrideEdgeUnavailable>(),
    );
  });

  test('network failure becomes network error', () async {
    final container = _container(
      _Repository([Future.value(const FailureResult(NetworkFailure()))]),
    );
    await container
        .read(actuatorOverrideControllerProvider.notifier)
        .submit(
          areaId: 'area-1',
          type: ActuatorType.extractor,
          targetState: ActuatorRunState.off,
        );

    expect(
      container.read(actuatorOverrideControllerProvider),
      isA<ActuatorOverrideNetworkError>(),
    );
  });

  test('an invalid command becomes validation error', () async {
    final repository = _Repository(const []);
    final container = _container(repository);
    await container
        .read(actuatorOverrideControllerProvider.notifier)
        .submit(
          areaId: 'area-1',
          type: ActuatorType.barrier,
          targetState: ActuatorRunState.on,
        );

    expect(
      container.read(actuatorOverrideControllerProvider),
      isA<ActuatorOverrideValidationError>(),
    );
    expect(repository.calls, 0);
  });

  test('a second submit while one is active is ignored', () async {
    final pending = Completer<Result<ActuatorState>>();
    final repository = _Repository([pending.future]);
    final container = _container(repository);
    final controller = container.read(
      actuatorOverrideControllerProvider.notifier,
    );
    final first = controller.submit(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.off,
    );
    final second = controller.submit(
      areaId: 'area-1',
      type: ActuatorType.extractor,
      targetState: ActuatorRunState.on,
    );
    pending.complete(Success(_state(ActuatorRunState.off)));
    await first;
    await second;

    expect(repository.calls, 1);
    expect(repository.targets, [ActuatorRunState.off]);
  });
}

ProviderContainer _container(SafetyRepository repository) {
  final container = ProviderContainer(
    overrides: [
      overrideActuatorUseCaseProvider.overrideWithValue(
        OverrideActuator(repository),
      ),
    ],
  );
  container.listen(actuatorOverrideControllerProvider, (_, _) {});
  return container;
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
  _Repository(this.pending);

  final List<Future<Result<ActuatorState>>> pending;
  final targets = <ActuatorRunState>[];
  var calls = 0;

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    targets.add(targetState);
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
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    throw UnimplementedError();
  }
}
