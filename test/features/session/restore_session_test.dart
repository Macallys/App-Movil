import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/restore_session.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';

void main() {
  final referenceTime = DateTime.utc(2026, 10, 23, 12);

  test(
    'valid Supervisor session with a future expiresAt is restored',
    () async {
      final repository = _Repository(
        Session(
          accessToken: 'token',
          role: UserRole.supervisor,
          expiresAt: DateTime.utc(2026, 10, 23, 20),
        ),
      );

      final outcome = await RestoreSession(repository)
          .call(referenceTime: referenceTime);

      expect(outcome, isA<SessionRestored>());
      expect(repository.clears, 0);
    },
  );

  test('expired session is cleared and reported as expired', () async {
    final repository = _Repository(
      Session(
        accessToken: 'token',
        role: UserRole.supervisor,
        expiresAt: referenceTime,
      ),
    );

    final outcome = await RestoreSession(repository)
        .call(referenceTime: referenceTime);

    expect(outcome, isA<SessionExpiredOutcome>());
    expect(repository.session, isNull);
    expect(repository.clears, 1);
  });

  test('PlantManager does not restore an operational session', () async {
    final repository = _Repository(
      Session(
        accessToken: 'token',
        role: UserRole.plantManager,
        expiresAt: DateTime.utc(2026, 10, 23, 20),
      ),
    );

    final outcome = await RestoreSession(repository)
        .call(referenceTime: referenceTime);

    expect(outcome, isA<SessionNotAllowed>());
    expect(repository.session, isNull);
    expect(repository.clears, 1);
  });

  test('missing session stays unauthenticated', () async {
    final repository = _Repository(null);

    final outcome = await RestoreSession(repository)
        .call(referenceTime: referenceTime);

    expect(outcome, isA<NoPersistedSession>());
    expect(repository.clears, 0);
  });
}

class _Repository implements SessionRepository {
  _Repository(this.session);

  Session? session;
  var clears = 0;

  @override
  Future<void> clearPersistedSession() async {
    clears += 1;
    session = null;
  }

  @override
  Future<void> persistSession(Session session) async {
    this.session = session;
  }

  @override
  Future<Session?> readPersistedSession() async => session;

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> signOut() {
    throw UnimplementedError();
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
