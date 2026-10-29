import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/session/data/datasources/session_remote_data_source.dart';

import '../../support/memory_token_storage.dart';

void main() {
  test('202 recovery is accepted without a bearer token', () async {
    final source = SessionRemoteDataSource(
      _client((options, handler) {
        expect(options.path, '/api/v1/auth/recovery');
        expect(options.extra['authenticated'], isFalse);
        expect(options.headers['Authorization'], isNull);
        expect(options.data, {'email': 'supervisor@plant.test'});
        handler.resolve(
          Response<dynamic>(requestOptions: options, statusCode: 202, data: ''),
        );
      }),
    );

    await source.requestCredentialRecovery(email: 'supervisor@plant.test');
  });

  test('204 reset is accepted without a bearer token', () async {
    final source = SessionRemoteDataSource(
      _client((options, handler) {
        expect(options.path, '/api/v1/auth/reset');
        expect(options.extra['authenticated'], isFalse);
        expect(options.headers['Authorization'], isNull);
        expect(options.data, {
          'token': 'recovery-token',
          'password': 'new-secret',
        });
        handler.resolve(
          Response<dynamic>(requestOptions: options, statusCode: 204, data: ''),
        );
      }),
    );

    await source.resetCredentials(
      token: 'recovery-token',
      password: 'new-secret',
    );
  });

  test('a network failure becomes an ApiException', () async {
    final source = SessionRemoteDataSource(
      _client((options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        );
      }),
    );

    expect(
      () => source.requestCredentialRecovery(email: 'supervisor@plant.test'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          isNull,
        ),
      ),
    );
  });
}

ApiClient _client(
  void Function(RequestOptions options, RequestInterceptorHandler handler)
  onRequest,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return ApiClient(
    dio: dio,
    tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
  );
}
