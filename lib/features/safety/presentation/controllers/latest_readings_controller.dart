part of '../providers/safety_providers.dart';

sealed class LatestReadingsState {
  const LatestReadingsState();
}

final class LatestReadingsInitial extends LatestReadingsState {
  const LatestReadingsInitial();
}

final class LatestReadingsLoading extends LatestReadingsState {
  const LatestReadingsLoading();
}

final class LatestReadingsData extends LatestReadingsState {
  const LatestReadingsData(this.readings);

  final LatestReadings readings;
}

final class LatestReadingsNoTelemetry extends LatestReadingsState {
  const LatestReadingsNoTelemetry();
}

final class LatestReadingsNotFound extends LatestReadingsState {
  const LatestReadingsNotFound();
}

final class LatestReadingsNetworkError extends LatestReadingsState {
  const LatestReadingsNetworkError();
}

final class LatestReadingsFailure extends LatestReadingsState {
  const LatestReadingsFailure();
}

class LatestReadingsController extends Notifier<LatestReadingsState> {
  String? _areaId;

  @override
  LatestReadingsState build() {
    return const LatestReadingsInitial();
  }

  Future<void> load(String areaId, {bool refresh = false}) async {
    final sameArea = _areaId == areaId;
    if (state is LatestReadingsLoading && sameArea) {
      return;
    }
    _areaId = areaId;
    final preserved = refresh && sameArea && state is LatestReadingsData
        ? state as LatestReadingsData
        : null;
    if (preserved == null) {
      state = const LatestReadingsLoading();
    }
    final result = await ref
        .read(getLatestReadingsUseCaseProvider)
        .call(areaId: areaId);
    if (!ref.mounted || _areaId != areaId) {
      return;
    }
    state = switch (result) {
      Success(:final value) when !value.hasTelemetry =>
        const LatestReadingsNoTelemetry(),
      Success(:final value) => LatestReadingsData(value),
      FailureResult() when preserved != null => preserved,
      FailureResult(:final failure) => switch (failure) {
        NotFoundFailure() => const LatestReadingsNotFound(),
        NetworkFailure() => const LatestReadingsNetworkError(),
        UnauthorizedFailure() => const LatestReadingsFailure(),
        _ => const LatestReadingsFailure(),
      },
    };
  }
}
