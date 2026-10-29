import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';

import '../entities/session.dart';

abstract class SessionRepository {
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  });

  Future<void> persistSession(Session session);

  Future<Session?> readPersistedSession();

  Future<void> clearPersistedSession();

  /// Remote logout may fail. The local session is cleared either way.
  /// The returned failure is that remote result, when there is one.
  Future<Failure?> signOut();

  Future<Result<Unit>> requestCredentialRecovery({required String email});

  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  });
}
