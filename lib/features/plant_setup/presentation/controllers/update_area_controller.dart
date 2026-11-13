part of '../providers/plant_setup_providers.dart';

sealed class UpdateAreaState {
  const UpdateAreaState();
}

final class UpdateAreaInitial extends UpdateAreaState {
  const UpdateAreaInitial();
}

final class UpdateAreaLoading extends UpdateAreaState {
  const UpdateAreaLoading();
}

final class UpdateAreaSaved extends UpdateAreaState {
  const UpdateAreaSaved(this.area);

  final IndustrialArea area;
}

final class UpdateAreaDuplicateName extends UpdateAreaState {
  const UpdateAreaDuplicateName();
}

final class UpdateAreaNotFound extends UpdateAreaState {
  const UpdateAreaNotFound();
}

final class UpdateAreaNetworkError extends UpdateAreaState {
  const UpdateAreaNetworkError();
}

final class UpdateAreaFailure extends UpdateAreaState {
  const UpdateAreaFailure();
}

class UpdateAreaController extends Notifier<UpdateAreaState> {
  @override
  UpdateAreaState build() {
    return const UpdateAreaInitial();
  }

  void reset() {
    state = const UpdateAreaInitial();
  }

  Future<void> submit({
    required String areaId,
    required String name,
    required String location,
  }) async {
    if (state is UpdateAreaLoading) {
      return;
    }
    state = const UpdateAreaLoading();
    final result = await ref
        .read(updateAreaUseCaseProvider)
        .call(areaId: areaId, name: name, location: location);
    state = switch (result) {
      Success(:final value) => UpdateAreaSaved(value),
      FailureResult(:final failure) => switch (failure) {
        ConflictFailure() => const UpdateAreaDuplicateName(),
        NotFoundFailure() => const UpdateAreaNotFound(),
        NetworkFailure() => const UpdateAreaNetworkError(),
        _ => const UpdateAreaFailure(),
      },
    };
  }
}
