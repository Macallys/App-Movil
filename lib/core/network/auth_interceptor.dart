import 'package:dio/dio.dart';

import '../auth/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStorage});

  final TokenStorage tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['authenticated'] == false) {
      handler.next(options);
      return;
    }
    tokenStorage
        .readAccessToken()
        .then((token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        })
        .catchError((Object error, StackTrace stackTrace) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        });
  }
}
