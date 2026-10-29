import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/session/data/datasources/session_local_data_source.dart';
import 'package:safeplant_mobile/features/session/data/datasources/session_remote_data_source.dart';
import 'package:safeplant_mobile/features/session/data/dtos/session_dto.dart';
import 'package:safeplant_mobile/features/session/data/mappers/session_mapper.dart';
import 'package:safeplant_mobile/features/session/data/repositories/session_repository_impl.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';

import '../../support/memory_token_storage.dart';

void main() {
  test('401 invalid_credentials becomes UnauthorizedFailure', () async {
    final repository = _repository(
      remote: _FakeRemote(
        () async => throw const ApiException(
          message: 'Request failed',
          statusCode: 401,
          code: 'invalid_credentials',
        ),
      ),
    );

    final result = await repository.signIn(
      email: 'supervisor@plant.test',
      password: 'wrong',
    );

    expect(
      (result as FailureResult<Session>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('a response without status becomes NetworkFailure', () async {
    final repository = _repository(
      remote: _FakeRemote(
        () async => throw const ApiException(message: 'Network failure'),
      ),
    );

    final result = await repository.signIn(
      email: 'supervisor@plant.test',
      password: 'secret',
    );

    expect((result as FailureResult<Session>).failure, isA<NetworkFailure>());
  });

  test('sign out deletes the local session', () async {
    final storage = MemoryTokenStorage();
    final repository = _repository(storage: storage);
    await repository.persistSession(_session());

    final failure = await repository.signOut();

    expect(failure, isNull);
    expect(storage.accessToken, isNull);
    expect(storage.clears, 1);
  });

  test('local session is deleted when remote logout fails', () async {
    final storage = MemoryTokenStorage();
    final repository = _repository(
      storage: storage,
      remote: _FakeRemote(
        () async => throw UnimplementedError(),
        signOutError: const ApiException(message: 'Network failure'),
      ),
    );
    await repository.persistSession(_session());

    final failure = await repository.signOut();

    expect(failure, isA<NetworkFailure>());
    expect(storage.accessToken, isNull);
    expect(await repository.readPersistedSession(), isNull);
  });
}

Session _session() {
  return Session(
    accessToken: 'token',
    role: UserRole.supervisor,
    expiresAt: DateTime.utc(2026, 10, 23, 20),
  );
}

SessionRepositoryImpl _repository({
  SessionRemoteDataSource? remote,
  MemoryTokenStorage? storage,
}) {
  return SessionRepositoryImpl(
    remote: remote ?? _FakeRemote(() async => throw UnimplementedError()),
    local: SessionLocalDataSource(
      storage: storage ?? MemoryTokenStorage(),
      mapper: const SessionMapper(),
    ),
    mapper: const SessionMapper(),
  );
}

class _FakeRemote extends SessionRemoteDataSource {
  _FakeRemote(this._signIn, {this.signOutError}) : super(ApiClient(dio: Dio()));

  final Future<SessionDto> Function() _signIn;
  final Object? signOutError;

  @override
  Future<SessionDto> signIn({required String email, required String password}) {
    return _signIn();
  }

  @override
  Future<void> signOut() async {
    final error = signOutError;
    if (error != null) {
      throw error;
    }
  }
}
