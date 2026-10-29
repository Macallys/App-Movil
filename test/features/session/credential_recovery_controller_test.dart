import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/request_credential_recovery.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/reset_credentials.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

void main() {
  test('recovery moves from loading to recoveryRequested', () async {
    final completer = Completer<Result<Unit>>();
    final container = _recoveryContainer(completer);
    addTearDown(container.dispose);
    container.listen(recoveryRequestControllerProvider, (_, _) {});

    final pending = container
        .read(recoveryRequestControllerProvider.notifier)
        .submit(email: 'supervisor@plant.test');

    expect(
      container.read(recoveryRequestControllerProvider),
      isA<RecoveryLoading>(),
    );

    completer.complete(const Success(Unit()));
    await pending;

    expect(
      container.read(recoveryRequestControllerProvider),
      isA<RecoveryRequested>(),
    );
  });

  test('recovery network failure moves to networkError', () async {
    final container = _recoveryContainer(
      Completer<Result<Unit>>()
        ..complete(const FailureResult(NetworkFailure())),
    );
    addTearDown(container.dispose);

    await container
        .read(recoveryRequestControllerProvider.notifier)
        .submit(email: 'supervisor@plant.test');

    expect(
      container.read(recoveryRequestControllerProvider),
      isA<RecoveryNetworkError>(),
    );
  });

  test('reset moves from loading to resetCompleted', () async {
    final completer = Completer<Result<Unit>>();
    final container = _resetContainer(completer);
    addTearDown(container.dispose);
    container.listen(resetCredentialsControllerProvider, (_, _) {});

    final pending = container
        .read(resetCredentialsControllerProvider.notifier)
        .submit(token: 'recovery-token', password: 'new-secret');

    expect(
      container.read(resetCredentialsControllerProvider),
      isA<ResetCredentialsLoading>(),
    );

    completer.complete(const Success(Unit()));
    await pending;

    expect(
      container.read(resetCredentialsControllerProvider),
      isA<ResetCredentialsCompleted>(),
    );
  });

  test('invalid recovery token moves to validationError', () async {
    final container = _resetContainer(
      Completer<Result<Unit>>()
        ..complete(const FailureResult(ValidationFailure())),
    );
    addTearDown(container.dispose);

    await container
        .read(resetCredentialsControllerProvider.notifier)
        .submit(token: 'used-token', password: 'new-secret');

    expect(
      container.read(resetCredentialsControllerProvider),
      isA<ResetCredentialsValidationError>(),
    );
  });
}

ProviderContainer _recoveryContainer(Completer<Result<Unit>> completer) {
  return ProviderContainer(
    overrides: [
      requestCredentialRecoveryUseCaseProvider.overrideWithValue(
        RequestCredentialRecovery(_PendingRepository(completer)),
      ),
    ],
  );
}

ProviderContainer _resetContainer(Completer<Result<Unit>> completer) {
  return ProviderContainer(
    overrides: [
      resetCredentialsUseCaseProvider.overrideWithValue(
        ResetCredentials(_PendingRepository(completer)),
      ),
    ],
  );
}

class _PendingRepository implements SessionRepository {
  _PendingRepository(this.completer);

  final Completer<Result<Unit>> completer;

  @override
  Future<Result<Unit>> requestCredentialRecovery({required String email}) {
    return completer.future;
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) {
    return completer.future;
  }

  @override
  Future<void> clearPersistedSession() => throw UnimplementedError();

  @override
  Future<void> persistSession(Session session) => throw UnimplementedError();

  @override
  Future<Session?> readPersistedSession() => throw UnimplementedError();

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> signOut() => throw UnimplementedError();
}
