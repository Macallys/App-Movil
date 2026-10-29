part of '../providers/plant_setup_providers.dart';

sealed class ConfigureThresholdsState {
  const ConfigureThresholdsState();
}

final class ConfigureThresholdsInitial extends ConfigureThresholdsState {
  const ConfigureThresholdsInitial();
}

final class ConfigureThresholdsLoading extends ConfigureThresholdsState {
  const ConfigureThresholdsLoading();
}

final class ConfigureThresholdsSaved extends ConfigureThresholdsState {
  const ConfigureThresholdsSaved(this.thresholds);

  final AreaThresholds thresholds;
}

final class ConfigureThresholdsValidationError
    extends ConfigureThresholdsState {
  const ConfigureThresholdsValidationError();
}

final class ConfigureThresholdsNotFound extends ConfigureThresholdsState {
  const ConfigureThresholdsNotFound();
}

final class ConfigureThresholdsNetworkError extends ConfigureThresholdsState {
  const ConfigureThresholdsNetworkError();
}

final class ConfigureThresholdsFailure extends ConfigureThresholdsState {
  const ConfigureThresholdsFailure();
}

class ConfigureThresholdsController extends Notifier<ConfigureThresholdsState> {
  @override
  ConfigureThresholdsState build() {
    return const ConfigureThresholdsInitial();
  }

  Future<void> submit({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    if (state is ConfigureThresholdsLoading) {
      return;
    }
    state = const ConfigureThresholdsLoading();
    final result = await ref
        .read(configureThresholdsUseCaseProvider)
        .call(
          areaId: areaId,
          co2LimitPpm: co2LimitPpm,
          noiseLimitDb: noiseLimitDb,
        );
    state = switch (result) {
      Success(:final value) => ConfigureThresholdsSaved(value),
      FailureResult(:final failure) => switch (failure) {
        ValidationFailure() => const ConfigureThresholdsValidationError(),
        NotFoundFailure() => const ConfigureThresholdsNotFound(),
        NetworkFailure() => const ConfigureThresholdsNetworkError(),
        _ => const ConfigureThresholdsFailure(),
      },
    };
  }
}
