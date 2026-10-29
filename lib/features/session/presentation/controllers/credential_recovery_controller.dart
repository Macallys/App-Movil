part of '../providers/session_providers.dart';

sealed class RecoveryState {
  const RecoveryState();
}

final class RecoveryIdle extends RecoveryState {
  const RecoveryIdle();
}

final class RecoveryLoading extends RecoveryState {
  const RecoveryLoading();
}

final class RecoveryRequested extends RecoveryState {
  const RecoveryRequested();
}

final class RecoveryNetworkError extends RecoveryState {
  const RecoveryNetworkError();
}

final class RecoveryFailed extends RecoveryState {
  const RecoveryFailed();
}

sealed class ResetCredentialsState {
  const ResetCredentialsState();
}

final class ResetCredentialsIdle extends ResetCredentialsState {
  const ResetCredentialsIdle();
}

final class ResetCredentialsLoading extends ResetCredentialsState {
  const ResetCredentialsLoading();
}

final class ResetCredentialsCompleted extends ResetCredentialsState {
  const ResetCredentialsCompleted();
}

final class ResetCredentialsValidationError extends ResetCredentialsState {
  const ResetCredentialsValidationError();
}

final class ResetCredentialsNetworkError extends ResetCredentialsState {
  const ResetCredentialsNetworkError();
}

final class ResetCredentialsFailed extends ResetCredentialsState {
  const ResetCredentialsFailed();
}

class RecoveryRequestController extends Notifier<RecoveryState> {
  @override
  RecoveryState build() => const RecoveryIdle();

  Future<void> submit({required String email}) async {
    if (state is RecoveryLoading) {
      return;
    }
    state = const RecoveryLoading();
    final result = await ref
        .read(requestCredentialRecoveryUseCaseProvider)
        .call(email: email);
    state = switch (result) {
      Success() => const RecoveryRequested(),
      FailureResult(:final failure) => switch (failure) {
        NetworkFailure() => const RecoveryNetworkError(),
        _ => const RecoveryFailed(),
      },
    };
  }
}

class ResetCredentialsController extends Notifier<ResetCredentialsState> {
  @override
  ResetCredentialsState build() => const ResetCredentialsIdle();

  Future<void> submit({required String token, required String password}) async {
    if (state is ResetCredentialsLoading) {
      return;
    }
    state = const ResetCredentialsLoading();
    final result = await ref
        .read(resetCredentialsUseCaseProvider)
        .call(token: token, password: password);
    state = switch (result) {
      Success() => const ResetCredentialsCompleted(),
      FailureResult(:final failure) => switch (failure) {
        ValidationFailure() => const ResetCredentialsValidationError(),
        NetworkFailure() => const ResetCredentialsNetworkError(),
        _ => const ResetCredentialsFailed(),
      },
    };
  }
}
