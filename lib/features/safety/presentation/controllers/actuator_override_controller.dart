part of '../providers/safety_providers.dart';

sealed class ActuatorOverrideState {
  const ActuatorOverrideState();
}

final class ActuatorOverrideInitial extends ActuatorOverrideState {
  const ActuatorOverrideInitial();
}

final class ActuatorOverrideConfirming extends ActuatorOverrideState {
  const ActuatorOverrideConfirming();
}

final class ActuatorOverrideSubmitting extends ActuatorOverrideState {
  const ActuatorOverrideSubmitting();
}

final class ActuatorOverrideSuccess extends ActuatorOverrideState {
  const ActuatorOverrideSuccess(this.actuator);

  final ActuatorState actuator;
}

final class ActuatorOverrideEdgeUnavailable extends ActuatorOverrideState {
  const ActuatorOverrideEdgeUnavailable();
}

final class ActuatorOverrideValidationError extends ActuatorOverrideState {
  const ActuatorOverrideValidationError();
}

final class ActuatorOverrideNetworkError extends ActuatorOverrideState {
  const ActuatorOverrideNetworkError();
}

final class ActuatorOverrideFailure extends ActuatorOverrideState {
  const ActuatorOverrideFailure();
}

class ActuatorOverrideController extends Notifier<ActuatorOverrideState> {
  var _inFlight = false;

  @override
  ActuatorOverrideState build() {
    return const ActuatorOverrideInitial();
  }

  void beginConfirmation() {
    if (_inFlight || state is ActuatorOverrideSubmitting) {
      return;
    }
    state = const ActuatorOverrideConfirming();
  }

  void cancelConfirmation() {
    if (state is ActuatorOverrideConfirming) {
      state = const ActuatorOverrideInitial();
    }
  }

  Future<void> submit({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const ActuatorOverrideSubmitting();
    try {
      final result = await ref
          .read(overrideActuatorUseCaseProvider)
          .call(areaId: areaId, type: type, targetState: targetState);
      if (!ref.mounted) {
        return;
      }
      state = switch (result) {
        Success(:final value) => ActuatorOverrideSuccess(value),
        FailureResult(:final failure) => switch (failure) {
          EdgeUnavailableFailure() => const ActuatorOverrideEdgeUnavailable(),
          ValidationFailure() => const ActuatorOverrideValidationError(),
          NetworkFailure() => const ActuatorOverrideNetworkError(),
          _ => const ActuatorOverrideFailure(),
        },
      };
    } finally {
      _inFlight = false;
    }
  }
}
