part of '../providers/session_providers.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionRestoring extends SessionState {
  const SessionRestoring();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.session);

  final Session session;
}

final class SessionInvalidCredentials extends SessionState {
  const SessionInvalidCredentials();
}

final class SessionForbidden extends SessionState {
  const SessionForbidden();
}

final class SessionExpired extends SessionState {
  const SessionExpired();
}

final class SessionNetworkError extends SessionState {
  const SessionNetworkError();
}

final class SessionFailed extends SessionState {
  const SessionFailed();
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    final revocation = ref.read(sessionRevocationProvider);
    revocation.bind(() {
      state = const SessionUnauthenticated();
    });
    ref.onDispose(revocation.unbind);
    return const SessionRestoring();
  }

  Future<void> restoreSession() async {
    state = const SessionRestoring();
    try {
      final outcome = await ref
          .read(restoreSessionUseCaseProvider)
          .call(referenceTime: DateTime.now().toUtc());
      state = switch (outcome) {
        SessionRestored(:final session) => SessionAuthenticated(session),
        NoPersistedSession() => const SessionUnauthenticated(),
        SessionExpiredOutcome() => const SessionExpired(),
        SessionNotAllowed() => const SessionForbidden(),
      };
    } catch (_) {
      state = const SessionFailed();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state is SessionLoading) {
      return;
    }
    state = const SessionLoading();
    final result = await ref
        .read(signInUseCaseProvider)
        .call(email: email, password: password);
    switch (result) {
      case Success(:final value):
        if (value.role != UserRole.supervisor) {
          state = const SessionForbidden();
          return;
        }
        state = SessionAuthenticated(value);
      case FailureResult(:final failure):
        state = switch (failure) {
          UnauthorizedFailure() => const SessionInvalidCredentials(),
          ForbiddenFailure() => const SessionForbidden(),
          NetworkFailure() => const SessionNetworkError(),
          EdgeUnavailableFailure() => const SessionFailed(),
          ValidationFailure() => const SessionFailed(),
          NotFoundFailure() => const SessionFailed(),
          ConflictFailure() => const SessionFailed(),
          UnknownFailure() => const SessionFailed(),
        };
    }
  }

  Future<void> signOut() async {
    if (state is! SessionAuthenticated) {
      return;
    }
    await ref.read(signOutUseCaseProvider).call();
    state = const SessionUnauthenticated();
  }
}
