import '../../../../core/error/result.dart';
import '../../domain/repositories/session_repository.dart';

class RequestCredentialRecovery {
  const RequestCredentialRecovery(this._repository);

  final SessionRepository _repository;

  Future<Result<Unit>> call({required String email}) {
    return _repository.requestCredentialRecovery(email: email);
  }
}
