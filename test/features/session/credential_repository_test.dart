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

import '../../support/memory_token_storage.dart';

void main() {
  test('recovery network error becomes NetworkFailure', () async {
    final repository = _repository(
      onRecovery: () async =>
          throw const ApiException(message: 'Network failure'),
    );

    final result = await repository.requestCredentialRecovery(
      email: 'supervisor@plant.test',
    );

    expect((result as FailureResult<Unit>).failure, isA<NetworkFailure>());
  });

  test('invalid reset becomes ValidationFailure', () async {
    final repository = _repository(
      onReset: () async =>
          throw const ApiException(message: 'Request failed', statusCode: 422),
    );

    final result = await repository.resetCredentials(
      token: 'used-token',
      password: 'new-secret',
    );

    expect((result as FailureResult<Unit>).failure, isA<ValidationFailure>());
  });
}

SessionRepositoryImpl _repository({
  Future<void> Function()? onRecovery,
  Future<void> Function()? onReset,
}) {
  return SessionRepositoryImpl(
    remote: _FakeRemote(onRecovery: onRecovery, onReset: onReset),
    local: SessionLocalDataSource(
      storage: MemoryTokenStorage(),
      mapper: const SessionMapper(),
    ),
    mapper: const SessionMapper(),
  );
}

class _FakeRemote extends SessionRemoteDataSource {
  _FakeRemote({this.onRecovery, this.onReset}) : super(ApiClient(dio: Dio()));

  final Future<void> Function()? onRecovery;
  final Future<void> Function()? onReset;

  @override
  Future<SessionDto> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestCredentialRecovery({required String email}) {
    return (onRecovery ?? () async => throw UnimplementedError())();
  }

  @override
  Future<void> resetCredentials({
    required String token,
    required String password,
  }) {
    return (onReset ?? () async => throw UnimplementedError())();
  }
}
