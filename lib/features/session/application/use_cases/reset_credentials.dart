import '../../../../core/error/result.dart';
import '../../domain/repositories/session_repository.dart';

class ResetCredentials {
  const ResetCredentials(this._repository);

  final SessionRepository _repository;

  Future<Result<Unit>> call({required String token, required String password}) {
    return _repository.resetCredentials(token: token, password: password);
  }
}
