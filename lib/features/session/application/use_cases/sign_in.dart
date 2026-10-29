import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class SignIn {
  const SignIn(this._repository);

  final SessionRepository _repository;

  Future<Result<Session>> call({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signIn(email: email, password: password);
    if (result case Success(:final value)
        when value.role == UserRole.supervisor) {
      try {
        await _repository.persistSession(value);
      } on Exception {
        await _repository.clearPersistedSession();
        return const FailureResult(UnknownFailure());
      }
    }
    return result;
  }
}
