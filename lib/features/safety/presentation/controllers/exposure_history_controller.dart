part of '../providers/safety_providers.dart';

sealed class ExposureHistoryState {
  const ExposureHistoryState();
}

final class ExposureHistoryInitial extends ExposureHistoryState {
  const ExposureHistoryInitial();
}

final class ExposureHistoryLoading extends ExposureHistoryState {
  const ExposureHistoryLoading();
}

final class ExposureHistoryEmpty extends ExposureHistoryState {
  const ExposureHistoryEmpty({this.refreshError = false});

  final bool refreshError;
}

final class ExposureHistoryData extends ExposureHistoryState {
  const ExposureHistoryData({
    required this.exposures,
    this.refreshError = false,
  });

  final List<Exposure> exposures;
  final bool refreshError;
}

final class ExposureHistoryNetworkError extends ExposureHistoryState {
  const ExposureHistoryNetworkError();
}

final class ExposureHistoryFailure extends ExposureHistoryState {
  const ExposureHistoryFailure();
}

class ExposureHistoryController extends Notifier<ExposureHistoryState> {
  String? _areaId;
  var _inFlight = false;

  @override
  ExposureHistoryState build() {
    return const ExposureHistoryInitial();
  }

  Future<void> load(String areaId, {bool refresh = false}) async {
    final sameArea = _areaId == areaId;
    if (_inFlight && sameArea) {
      return;
    }
    _areaId = areaId;
    final preserved = refresh && sameArea ? state : null;
    final keepVisible =
        preserved is ExposureHistoryData || preserved is ExposureHistoryEmpty;
    if (!keepVisible) {
      state = const ExposureHistoryLoading();
    }
    _inFlight = true;
    try {
      final result = await ref
          .read(getShortExposureHistoryUseCaseProvider)
          .call(areaId: areaId);
      if (!ref.mounted || _areaId != areaId) {
        return;
      }
      final current = state;
      state = switch (result) {
        Success(:final value) when value.isEmpty =>
          const ExposureHistoryEmpty(),
        Success(:final value) => ExposureHistoryData(exposures: value),
        FailureResult() when current is ExposureHistoryData =>
          ExposureHistoryData(exposures: current.exposures, refreshError: true),
        FailureResult() when current is ExposureHistoryEmpty =>
          const ExposureHistoryEmpty(refreshError: true),
        FailureResult(:final failure) => switch (failure) {
          NetworkFailure() => const ExposureHistoryNetworkError(),
          _ => const ExposureHistoryFailure(),
        },
      };
    } finally {
      _inFlight = false;
    }
  }
}
