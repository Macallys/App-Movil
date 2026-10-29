import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/auth/token_storage.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/sign_in.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

import '../../support/memory_token_storage.dart';

void main() {
  test('controller moves from loading to authenticated', () async {
    final completer = Completer<Result<Session>>();
    final storage = MemoryTokenStorage();
    final repository = _FakeRepository((_) => completer.future);
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);
    container.listen(sessionControllerProvider, (_, _) {});

    final pending = container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'supervisor@plant.test', password: 'secret');

    expect(container.read(sessionControllerProvider), isA<SessionLoading>());

    completer.complete(Success(_session(UserRole.supervisor)));
    await pending;

    expect(
      container.read(sessionControllerProvider),
      isA<SessionAuthenticated>(),
    );
    expect(repository.persisted?.accessToken, 'token');
    expect(storage.saves, 0);
  });

  test('invalid credentials produce the matching state', () async {
    final storage = MemoryTokenStorage();
    final repository = _FakeRepository(
      (_) async => const FailureResult(UnauthorizedFailure()),
    );
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'supervisor@plant.test', password: 'wrong');

    expect(
      container.read(sessionControllerProvider),
      isA<SessionInvalidCredentials>(),
    );
    expect(repository.persisted, isNull);
    expect(storage.saves, 0);
  });

  test('PlantManager does not get operational access', () async {
    final storage = MemoryTokenStorage();
    final repository = _FakeRepository(
      (_) async => Success(_session(UserRole.plantManager)),
    );
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'manager@plant.test', password: 'secret');

    expect(container.read(sessionControllerProvider), isA<SessionForbidden>());
    expect(repository.persisted, isNull);
    expect(storage.saves, 0);
  });
}

ProviderContainer _container({
  required SessionRepository repository,
  required TokenStorage storage,
}) {
  return ProviderContainer(
    overrides: [
      signInUseCaseProvider.overrideWithValue(SignIn(repository)),
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}

Session _session(UserRole role) {
  return Session(
    accessToken: 'token',
    role: role,
    expiresAt: DateTime.utc(2026, 10, 23, 20),
  );
}

class _FakeRepository implements SessionRepository {
  _FakeRepository(this._signIn);

  final Future<Result<Session>> Function(_Credentials credentials) _signIn;
  Session? persisted;

  @override
  Future<void> clearPersistedSession() async {
    persisted = null;
  }

  @override
  Future<void> persistSession(Session session) async {
    persisted = session;
  }

  @override
  Future<Session?> readPersistedSession() async => persisted;

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    return _signIn((email: email, password: password));
  }

  @override
  Future<Failure?> signOut() async {
    await clearPersistedSession();
    return null;
  }

  @override
  Future<Result<Unit>> requestCredentialRecovery({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) {
    throw UnimplementedError();
  }
}

typedef _Credentials = ({String email, String password});
