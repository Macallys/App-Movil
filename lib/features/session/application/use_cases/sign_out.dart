import '../../../../core/error/failure.dart';
import '../../domain/repositories/session_repository.dart';

class SignOut {
  const SignOut(this._repository);

  final SessionRepository _repository;

  Future<Failure?> call() {
    return _repository.signOut();
  }
}
