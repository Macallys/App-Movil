import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

sealed class RestoreSessionOutcome {
  const RestoreSessionOutcome();
}

final class SessionRestored extends RestoreSessionOutcome {
  const SessionRestored(this.session);

  final Session session;
}

final class NoPersistedSession extends RestoreSessionOutcome {
  const NoPersistedSession();
}

final class SessionExpiredOutcome extends RestoreSessionOutcome {
  const SessionExpiredOutcome();
}

final class SessionNotAllowed extends RestoreSessionOutcome {
  const SessionNotAllowed();
}

class RestoreSession {
  const RestoreSession(this._repository);

  final SessionRepository _repository;

  Future<RestoreSessionOutcome> call({required DateTime referenceTime}) async {
    final session = await _repository.readPersistedSession();
    if (session == null) {
      return const NoPersistedSession();
    }
    if (session.isExpired(referenceTime)) {
      await _repository.clearPersistedSession();
      return const SessionExpiredOutcome();
    }
    if (session.role != UserRole.supervisor) {
      await _repository.clearPersistedSession();
      return const SessionNotAllowed();
    }
    return SessionRestored(session);
  }
}
