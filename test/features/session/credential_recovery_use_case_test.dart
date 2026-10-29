import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/request_credential_recovery.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/reset_credentials.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';

void main() {
  test('RequestCredentialRecovery forwards the email', () async {
    final repository = _RecordingRepository();
    final useCase = RequestCredentialRecovery(repository);

    final result = await useCase.call(email: 'supervisor@plant.test');

    expect(repository.email, 'supervisor@plant.test');
    expect(result, isA<Success<Unit>>());
  });

  test('ResetCredentials forwards token and password', () async {
    final repository = _RecordingRepository();
    final useCase = ResetCredentials(repository);

    final result = await useCase.call(
      token: 'recovery-token',
      password: 'new-secret',
    );

    expect(repository.token, 'recovery-token');
    expect(repository.password, 'new-secret');
    expect(result, isA<Success<Unit>>());
  });
}

class _RecordingRepository implements SessionRepository {
  String? email;
  String? token;
  String? password;

  @override
  Future<Result<Unit>> requestCredentialRecovery({
    required String email,
  }) async {
    this.email = email;
    return const Success(Unit());
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) async {
    this.token = token;
    this.password = password;
    return const Success(Unit());
  }

  @override
  Future<void> clearPersistedSession() => throw UnimplementedError();

  @override
  Future<void> persistSession(Session session) => throw UnimplementedError();

  @override
  Future<Session?> readPersistedSession() => throw UnimplementedError();

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> signOut() => throw UnimplementedError();
}
