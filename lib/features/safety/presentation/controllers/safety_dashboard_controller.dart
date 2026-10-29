part of '../providers/safety_providers.dart';

sealed class SafetyDashboardState {
  const SafetyDashboardState();
}

final class SafetyDashboardInitial extends SafetyDashboardState {
  const SafetyDashboardInitial();
}

final class SafetyDashboardLoading extends SafetyDashboardState {
  const SafetyDashboardLoading();
}

final class SafetyDashboardEmpty extends SafetyDashboardState {
  const SafetyDashboardEmpty();
}

final class SafetyDashboardUnauthorized extends SafetyDashboardState {
  const SafetyDashboardUnauthorized();
}

final class SafetyDashboardNetworkError extends SafetyDashboardState {
  const SafetyDashboardNetworkError();
}

final class SafetyDashboardFailure extends SafetyDashboardState {
  const SafetyDashboardFailure();
}

final class SafetyDashboardData extends SafetyDashboardState {
  const SafetyDashboardData({required this.areas, this.refreshError = false});

  final List<AreaOperationalStatus> areas;
  final bool refreshError;
}

class SafetyDashboardController extends Notifier<SafetyDashboardState> {
  @override
  SafetyDashboardState build() {
    return const SafetyDashboardInitial();
  }

  Future<void> load({bool refresh = false}) async {
    if (state is SafetyDashboardLoading) {
      return;
    }
    final preserved = state is SafetyDashboardData
        ? state as SafetyDashboardData
        : null;
    if (!refresh || preserved == null) {
      state = const SafetyDashboardLoading();
    }
    final result = await ref.read(getOperationalStatusUseCaseProvider).call();
    final latest = state;
    final kept = latest is SafetyDashboardData ? latest : preserved;
    state = switch (result) {
      Success(:final value) when value.isEmpty => const SafetyDashboardEmpty(),
      Success(:final value) => SafetyDashboardData(areas: value),
      FailureResult() when refresh && kept != null => SafetyDashboardData(
        areas: kept.areas,
        refreshError: true,
      ),
      FailureResult(:final failure) => switch (failure) {
        UnauthorizedFailure() => const SafetyDashboardUnauthorized(),
        NetworkFailure() => const SafetyDashboardNetworkError(),
        _ => const SafetyDashboardFailure(),
      },
    };
  }
}
