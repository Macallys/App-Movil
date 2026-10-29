import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'base_url_policy.dart';

final class ApiJson {
  const ApiJson({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    TokenStorage? tokenStorage,
    this.onUnauthorized,
  }) : _blocked = dio != null
           ? false
           : assessBaseUrl(
                   baseUrl ?? const String.fromEnvironment('API_BASE_URL'),
                   release: kReleaseMode,
                 ) !=
                 BaseUrlDecision.allowed,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl:
                   (baseUrl ?? const String.fromEnvironment('API_BASE_URL'))
                       .trim(),
               headers: const {'Accept': 'application/json'},
               responseType: ResponseType.json,
               connectTimeout: connectTimeout,
               sendTimeout: sendTimeout,
               receiveTimeout: receiveTimeout,
             ),
           ),
       _tokenStorage = tokenStorage {
    if (tokenStorage != null) {
      _dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));
    }
  }

  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 20);

  final Dio _dio;
  final TokenStorage? _tokenStorage;
  final void Function()? onUnauthorized;
  final bool _blocked;

  void _ensureConfigured() {
    if (_blocked) {
      throw const ApiException(message: 'Network failure');
    }
  }

  /// [authenticated] stays false for login. Recovery and password reset must
  /// use the same flag once their paths leave To discuss.
  Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool requiresBody = true,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(
          extra: {'authenticated': authenticated},
          responseType: requiresBody ? ResponseType.json : ResponseType.plain,
        ),
      );
      if (!requiresBody) {
        return null;
      }
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  /// JSON object plus status. No request body is sent.
  Future<ApiJson> getJson(String path, {bool authenticated = true}) async {
    _ensureConfigured();
    try {
      final response = await _dio.get<dynamic>(
        path,
        options: Options(extra: {'authenticated': authenticated}),
      );
      return _jsonResponse(response);
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  /// JSON body plus status. Used when the caller must accept one success code.
  Future<ApiJson> postJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(extra: {'authenticated': authenticated}),
      );
      return _jsonResponse(response);
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  /// Authenticated POST that expects a JSON object and does not send a body.
  Future<ApiJson> postWithoutBody(
    String path, {
    bool authenticated = true,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.post<dynamic>(
        path,
        options: Options(extra: {'authenticated': authenticated}),
      );
      return _jsonResponse(response);
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  Future<ApiJson> putJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: body,
        options: Options(extra: {'authenticated': authenticated}),
      );
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('Unexpected response');
      }
      return ApiJson(
        statusCode: response.statusCode ?? 0,
        body: Map<String, dynamic>.from(data),
      );
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  /// Returns the HTTP status. Recovery and reset use [authenticated] false.
  Future<int> postStatus(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(
          extra: {'authenticated': authenticated},
          responseType: ResponseType.plain,
        ),
      );
      return response.statusCode ?? 0;
    } on DioException catch (error) {
      throw await _asException(error);
    }
  }

  ApiJson _jsonResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Unexpected response');
    }
    return ApiJson(
      statusCode: response.statusCode ?? 0,
      body: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ApiException(message: 'Unexpected response');
  }

  Future<ApiException> _asException(DioException error) async {
    final exception = _fromDio(error);
    final authenticated = error.requestOptions.extra['authenticated'] != false;
    if (_tokenStorage != null && authenticated && exception.statusCode == 401) {
      await _tokenStorage.clearSession();
      onUnauthorized?.call();
    }
    return exception;
  }

  ApiException _fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(message: 'Network failure');
    }
    return ApiException(
      message: 'Request failed',
      statusCode: response.statusCode,
      code: _readCode(response.data),
    );
  }

  String? _readCode(Object? data) {
    if (data is! Map) {
      return null;
    }
    final code = data['code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }
    return null;
  }
}
