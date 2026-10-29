import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/restore_session.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/sign_out.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';

class ScriptedRestore extends RestoreSession {
  ScriptedRestore(this.outcome) : super(_IdleSessionRepository());

  final RestoreSessionOutcome outcome;

  @override
  Future<RestoreSessionOutcome> call({required DateTime referenceTime}) async {
    return outcome;
  }
}

class ThrowingRestore extends RestoreSession {
  ThrowingRestore() : super(_IdleSessionRepository());

  @override
  Future<RestoreSessionOutcome> call({required DateTime referenceTime}) async {
    throw StateError('restore failed');
  }
}

class QuietSignOut extends SignOut {
  QuietSignOut() : super(_IdleSessionRepository());

  @override
  Future<Failure?> call() async => null;
}

class _IdleSessionRepository implements SessionRepository {
  @override
  Future<void> clearPersistedSession() async {}

  @override
  Future<void> persistSession(Session session) async {}

  @override
  Future<Session?> readPersistedSession() async => null;

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

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> signOut() async => null;
}
