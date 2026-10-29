import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_local_data_source.dart';
import '../datasources/session_remote_data_source.dart';
import '../mappers/session_mapper.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({
    required this.remote,
    required this.local,
    required this.mapper,
  });

  final SessionRemoteDataSource remote;
  final SessionLocalDataSource local;
  final SessionMapper mapper;

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await remote.signIn(email: email, password: password);
      return Success(mapper.toEntity(dto));
    } on ApiException catch (error) {
      return FailureResult(_map(error));
    } on FormatException {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<void> persistSession(Session session) {
    return local.save(session);
  }

  @override
  Future<Session?> readPersistedSession() {
    return local.read();
  }

  @override
  Future<void> clearPersistedSession() {
    return local.delete();
  }

  @override
  Future<Failure?> signOut() async {
    Failure? remoteFailure;
    try {
      await remote.signOut();
    } on ApiException catch (error) {
      remoteFailure = _map(error);
    } on FormatException {
      remoteFailure = const UnknownFailure();
    }
    await local.delete();
    return remoteFailure;
  }

  @override
  Future<Result<Unit>> requestCredentialRecovery({
    required String email,
  }) async {
    try {
      await remote.requestCredentialRecovery(email: email);
      return const Success(Unit());
    } on ApiException catch (error) {
      return FailureResult(_mapRecovery(error));
    }
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) async {
    try {
      await remote.resetCredentials(token: token, password: password);
      return const Success(Unit());
    } on ApiException catch (error) {
      return FailureResult(_mapReset(error));
    }
  }

  Failure _mapRecovery(ApiException error) {
    if (error.statusCode == null) {
      return const NetworkFailure();
    }
    return const UnknownFailure();
  }

  Failure _mapReset(ApiException error) {
    if (error.statusCode == null) {
      return const NetworkFailure();
    }
    if (error.statusCode == 422) {
      return const ValidationFailure();
    }
    return const UnknownFailure();
  }

  Failure _map(ApiException error) {
    if (error.statusCode == null) {
      return const NetworkFailure();
    }
    if (error.statusCode == 401 && error.code == 'invalid_credentials') {
      return const UnauthorizedFailure();
    }
    if (error.statusCode == 403 &&
        (error.code == 'account_disabled' ||
            error.code == 'role_not_allowed')) {
      return const ForbiddenFailure();
    }
    return const UnknownFailure();
  }
}
