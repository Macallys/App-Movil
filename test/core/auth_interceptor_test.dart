import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';

import '../support/memory_token_storage.dart';

void main() {
  test(
    'protected requests receive a bearer token and login does not',
    () async {
      final storage = MemoryTokenStorage();
      await storage.saveAccessToken('abc');
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      final client = ApiClient(dio: dio, tokenStorage: storage);
      final seen = <String, String?>{};
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            seen[options.path] = options.headers['Authorization'] as String?;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: options.path.endsWith('/login')
                    ? {
                        'accessToken': 'abc',
                        'role': 'Supervisor',
                        'expiresAt': '2026-10-23T20:00:00Z',
                      }
                    : '',
              ),
            );
          },
        ),
      );

      await client.post('/api/v1/areas', body: const {}, requiresBody: false);
      await client.post(
        '/api/v1/auth/login',
        body: const {'email': 'a@b.c', 'password': 'secret'},
        authenticated: false,
      );

      expect(seen['/api/v1/areas'], 'Bearer abc');
      expect(seen['/api/v1/auth/login'], isNull);
    },
  );

  test('a protected 401 clears the persisted session', () async {
    final storage = MemoryTokenStorage();
    await storage.saveAccessToken('abc');
    await storage.saveRole('Supervisor');
    await storage.saveExpiresAt('2026-10-23T20:00:00Z');
    var revoked = false;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final client = ApiClient(
      dio: dio,
      tokenStorage: storage,
      onUnauthorized: () => revoked = true,
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 401,
                data: const {'code': 'invalid'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );

    await expectLater(
      client.post('/api/v1/areas', body: const {}),
      throwsA(isA<Exception>()),
    );

    expect(storage.accessToken, isNull);
    expect(storage.role, isNull);
    expect(storage.expiresAt, isNull);
    expect(revoked, isTrue);
  });
}
