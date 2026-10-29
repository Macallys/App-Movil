part of '../providers/safety_providers.dart';

sealed class ActuatorActionsState {
  const ActuatorActionsState();
}

final class ActuatorActionsInitial extends ActuatorActionsState {
  const ActuatorActionsInitial();
}

final class ActuatorActionsLoading extends ActuatorActionsState {
  const ActuatorActionsLoading();
}

final class ActuatorActionsEmpty extends ActuatorActionsState {
  const ActuatorActionsEmpty({this.refreshError = false});

  final bool refreshError;
}

final class ActuatorActionsData extends ActuatorActionsState {
  const ActuatorActionsData({required this.actions, this.refreshError = false});

  final List<ActuatorAction> actions;
  final bool refreshError;
}

final class ActuatorActionsNetworkError extends ActuatorActionsState {
  const ActuatorActionsNetworkError();
}

final class ActuatorActionsFailure extends ActuatorActionsState {
  const ActuatorActionsFailure();
}

class ActuatorActionsController extends Notifier<ActuatorActionsState> {
  String? _areaId;
  var _inFlight = false;

  @override
  ActuatorActionsState build() {
    return const ActuatorActionsInitial();
  }

  Future<void> load(String areaId, {bool refresh = false}) async {
    final sameArea = _areaId == areaId;
    if (_inFlight && sameArea) {
      return;
    }
    _areaId = areaId;
    final preserved = refresh && sameArea ? state : null;
    final keepVisible =
        preserved is ActuatorActionsData || preserved is ActuatorActionsEmpty;
    if (!keepVisible) {
      state = const ActuatorActionsLoading();
    }
    _inFlight = true;
    try {
      final result = await ref
          .read(getActuatorActionsUseCaseProvider)
          .call(areaId: areaId);
      if (!ref.mounted || _areaId != areaId) {
        return;
      }
      final current = state;
      state = switch (result) {
        Success(:final value) when value.isEmpty =>
          const ActuatorActionsEmpty(),
        Success(:final value) => ActuatorActionsData(actions: value),
        FailureResult() when current is ActuatorActionsData =>
          ActuatorActionsData(actions: current.actions, refreshError: true),
        FailureResult() when current is ActuatorActionsEmpty =>
          const ActuatorActionsEmpty(refreshError: true),
        FailureResult(:final failure) => switch (failure) {
          NetworkFailure() => const ActuatorActionsNetworkError(),
          _ => const ActuatorActionsFailure(),
        },
      };
    } finally {
      _inFlight = false;
    }
  }
}
