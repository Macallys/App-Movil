part of '../providers/plant_setup_providers.dart';

sealed class CreateAreaState {
  const CreateAreaState();
}

final class CreateAreaInitial extends CreateAreaState {
  const CreateAreaInitial();
}

final class CreateAreaLoading extends CreateAreaState {
  const CreateAreaLoading();
}

final class CreateAreaCreated extends CreateAreaState {
  const CreateAreaCreated(this.area);

  final IndustrialArea area;
}

final class CreateAreaDuplicateName extends CreateAreaState {
  const CreateAreaDuplicateName();
}

final class CreateAreaUnauthorized extends CreateAreaState {
  const CreateAreaUnauthorized();
}

final class CreateAreaNetworkError extends CreateAreaState {
  const CreateAreaNetworkError();
}

final class CreateAreaFailure extends CreateAreaState {
  const CreateAreaFailure();
}

class IndustrialAreaController extends Notifier<CreateAreaState> {
  @override
  CreateAreaState build() {
    return const CreateAreaInitial();
  }

  Future<void> submit({required String name, required String location}) async {
    if (state is CreateAreaLoading) {
      return;
    }
    state = const CreateAreaLoading();
    final result = await ref
        .read(createAreaUseCaseProvider)
        .call(name: name, location: location);
    state = switch (result) {
      Success(:final value) => CreateAreaCreated(value),
      FailureResult(:final failure) => switch (failure) {
        ConflictFailure() => const CreateAreaDuplicateName(),
        UnauthorizedFailure() => const CreateAreaUnauthorized(),
        NetworkFailure() => const CreateAreaNetworkError(),
        _ => const CreateAreaFailure(),
      },
    };
  }
}
