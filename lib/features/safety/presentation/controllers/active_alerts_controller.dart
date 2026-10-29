part of '../providers/safety_providers.dart';

sealed class ActiveAlertsState {
  const ActiveAlertsState();
}

final class ActiveAlertsInitial extends ActiveAlertsState {
  const ActiveAlertsInitial();
}

final class ActiveAlertsLoading extends ActiveAlertsState {
  const ActiveAlertsLoading();
}

final class ActiveAlertsEmpty extends ActiveAlertsState {
  const ActiveAlertsEmpty({this.refreshError = false});

  final bool refreshError;
}

final class ActiveAlertsData extends ActiveAlertsState {
  const ActiveAlertsData({required this.alerts, this.refreshError = false});

  final List<EnvironmentalAlert> alerts;
  final bool refreshError;
}

final class ActiveAlertsNetworkError extends ActiveAlertsState {
  const ActiveAlertsNetworkError();
}

final class ActiveAlertsFailure extends ActiveAlertsState {
  const ActiveAlertsFailure();
}

class ActiveAlertsController extends Notifier<ActiveAlertsState> {
  Timer? _timer;
  var _inFlight = false;

  @override
  ActiveAlertsState build() {
    ref.onDispose(stopPolling);
    return const ActiveAlertsInitial();
  }

  void startPolling() {
    if (!ref.read(activeAlertsPollingEnabledProvider) || _timer != null) {
      return;
    }
    _timer = Timer.periodic(activeAlertsPollingInterval, (_) {
      load(background: true);
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> load({bool background = false}) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    try {
      final visible = state is ActiveAlertsData || state is ActiveAlertsEmpty;
      if (!background && !visible) {
        state = const ActiveAlertsLoading();
      }
      final result = await ref.read(getActiveAlertsUseCaseProvider).call();
      if (!ref.mounted) {
        return;
      }
      final current = state;
      state = switch (result) {
        Success(:final value) when value.isEmpty => const ActiveAlertsEmpty(),
        Success(:final value) => ActiveAlertsData(alerts: value),
        FailureResult() when current is ActiveAlertsData => ActiveAlertsData(
          alerts: current.alerts,
          refreshError: true,
        ),
        FailureResult() when current is ActiveAlertsEmpty =>
          const ActiveAlertsEmpty(refreshError: true),
        FailureResult(:final failure) => switch (failure) {
          NetworkFailure() => const ActiveAlertsNetworkError(),
          _ => const ActiveAlertsFailure(),
        },
      };
    } finally {
      _inFlight = false;
    }
  }
}
